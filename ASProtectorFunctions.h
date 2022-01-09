//
//  ASProtectorFunctions.h
//
//  Created by AndyMu on 2020/6/1.
//

#ifndef ASProtectorFunctions_h
#define ASProtectorFunctions_h
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#pragma mark - 链表

typedef struct IMPNode *PtrToIMP;
typedef PtrToIMP IMPList;

struct IMPNode{
    IMP imp;
    PtrToIMP next;
};

/// 向IMP链表中追加imp
static inline void AS_InsertIMPToList(IMPList list, IMP imp){
    PtrToIMP nextNode = malloc(sizeof(struct IMPNode));
    nextNode->imp = imp;
    nextNode->next = list->next;
    list->next = nextNode;
}

/// 判断IMP链表中有没有此元素。
static inline BOOL AS_ImpExistInList(IMPList list, IMP imp){
    if (list->imp == imp) {
        return YES;
    }else{
        if (list->next != NULL) {
            return AS_ImpExistInList(list->next,imp);
        }else{
            return NO;
        }
    }
}

/// IMP链表初始化
static inline IMPList AS_ImpInit() {
    IMPList implist = malloc(sizeof(struct IMPNode));
    implist->next = NULL;
    return implist;
}

#pragma mark - 方法交换

/// 交换实例方法
static inline void AS_ExchangeInstanceMethod(Class _originalClass, SEL _originalSel, Class _targetClass, SEL _targetSel){
    /// 原有方法
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    /// 替换原有方法的新方法
    Method methodNew = class_getInstanceMethod(_targetClass, _targetSel);
    /// 先尝试给原SEL添加IMP，这里是为了避免原SEL没有实现IMP的情况
    BOOL didAddMethod = class_addMethod(_originalClass, _originalSel, method_getImplementation(methodNew), method_getTypeEncoding(methodNew));
    if (didAddMethod) {
        /// 添加成功：说明原SEL没有实现IMP，将原SEL的IMP替换到交换SEL的IMP
        class_replaceMethod(_targetClass, _targetSel, method_getImplementation(methodOriginal), method_getTypeEncoding(methodOriginal));
    }else{
        /// 添加失败：说明源SEL已经有IMP，直接将两个SEL的IMP交换即可
        method_exchangeImplementations(methodOriginal, methodNew);
    }
}

/// 交换类方法
static inline void AS_ExchangeClassMethod(Class _class, SEL _originalSel, SEL _exchangeSel){
    Method methodOriginal = class_getClassMethod(_class, _originalSel);
    Method methodNew = class_getClassMethod(_class, _exchangeSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

#pragma mark - 工具

/// 动态添加方法的imp
static inline void AS_DynamicAddMethodIMP(id self, SEL _cmd, ...){

}

///
static inline UIViewController * AS_SubTopViewController(UIViewController * vc) {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return AS_SubTopViewController([(UINavigationController *)vc topViewController]);
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return AS_SubTopViewController([(UITabBarController *)vc selectedViewController]);
    } else {
        return vc;
    }
    return nil;
}

/// 获取当前显示的视图控制器
static inline UIViewController * AS_TopViewController() {
    UIViewController *resultVC;
    resultVC = AS_SubTopViewController([[UIApplication sharedApplication].keyWindow rootViewController]);
    while (resultVC.presentedViewController) {
        resultVC = AS_SubTopViewController(resultVC.presentedViewController);
    }
    return resultVC;
}

/// 是否是系统类
static inline BOOL AS_IsSystemClass(Class cls){
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    if (bundle == [NSBundle mainBundle]) {
        return NO;
    }else{
        return YES;
    }
}

#endif /* ASProtectorFunctions_h */
