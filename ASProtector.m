//
//  ASProtector.m
//
//  Created by AndyMu on 2020/6/1.
//


#import "ASProtector.h"
#import "NSObject+UNRecognizedSelHandler.h"
#import "ASProtectorContainers.h"
#import "NSTimer+TimerProtector.h"
#import "NSObject+ASKVOProtector.h"
#import "NSObject+ASKVCProtector.h"


static NSString * const kUnrecognizedSelector = @"UnrecognizedSelector";
static NSString * const kContainersException = @"ContainersException";
static NSString * const kTimerException = @"TimerException";
static NSString * const kKVOException = @"KVOException";
static NSString * const kKVCException = @"KVCException";



///声明一个全局的IMP链表
static IMPList impList;

@interface ASProtector ()

@property(nonatomic, copy)NSArray *ignorePrefixes;
@property(nonatomic, copy)NSArray *onlyPrefixes;
@property(nonatomic, copy)NSArray *allClassTypes;

@end

@implementation ASProtector

+ (ASProtector *)shared{
    static ASProtector *protector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        protector = [[super allocWithZone:NULL]init];
    });
    return protector;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [ASProtector shared];
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [ASProtector shared];
}

+ (void)load{
    IMP mapping_ForwardingTarget_IMP = class_getMethodImplementation([ASProtector class], @selector(AS_mappingForwardingTargetForSelector));
    IMP mapping_KVO_IMP = class_getMethodImplementation([ASProtector class], @selector(AS_mappingAddObserverForKeyPathOptionsContext));
    IMP mapping_ScheduledTimer_IMP = class_getMethodImplementation([ASProtector class], @selector(AS_mappingScheduledTimerWithTimeInterval));
    IMP mapping_Containers_IMP = class_getMethodImplementation([ASProtector class], @selector(AS_mappingContainersMethods));
    IMP mapping_KVC_IMP = class_getMethodImplementation([ASProtector class], @selector(AS_mappingSetValueForKey));
    impList = AS_ImpInit();
    AS_InsertIMPToList(impList, mapping_ForwardingTarget_IMP);
    AS_InsertIMPToList(impList, mapping_KVO_IMP);
    AS_InsertIMPToList(impList, mapping_ScheduledTimer_IMP);
    AS_InsertIMPToList(impList, mapping_Containers_IMP);
    AS_InsertIMPToList(impList, mapping_KVC_IMP);
}

/// 开启崩溃保护
+ (void)openProtectionsOn:(ASProtectionType)protectionType {
    [self filterProtectionsOn:protectionType operation:YES];
}

/// 关闭崩溃保护
+ (void)closeProtectionsOn:(ASProtectionType)protectionType {
    [self filterProtectionsOn:protectionType operation:NO];
}

/// 捕获信息上报
+ (void)postErrorInfo:(ASProtectorCatchError *)error {
    if ([[ASProtector shared].delegate respondsToSelector:@selector(protectCatchInfo:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ASProtector shared].delegate protectCatchInfo:error];
        });
    }
}

/// 设置黑名单 作用：忽略对具有以下指定前缀的类的保护
- (void)ignoreProtectionsOnClassesWithPrefix:(NSArray *_Nonnull)ignorePrefixes {
    self.ignorePrefixes = ignorePrefixes;
}

/// 设置白名单 作用：只保护对具有以下指定前缀的类【优先级高于黑名单】
- (void)onlyProtectionsOnClassesWithPrefix:(NSArray *_Nonnull)onlyPrefixes {
    self.onlyPrefixes = onlyPrefixes;
}

/// 设置全部类白名单 作用：保护此类型下的全部类  默认：忽略系统类
/// 例如：@[@(ASProtectionTypeKVC)]
- (void)allProtectionsWithType:(NSArray *_Nonnull)types {
    self.allClassTypes = types;
}

/// 是否应该保护此类
/// 全部类保护状态 -> 检查是否系统类 -> 白名单 -> 黑名单
- (BOOL)isNeedProtectionWithClass:(Class)cls type:(ASProtectionType)type {
    /// 保护全部类
    BOOL isProtectionAllClass = [self.allClassTypes containsObject:@(type)];
    if (isProtectionAllClass) {
        return YES;
    }else {
        /// 系统类
        if (AS_IsSystemClass(cls)) {
            return NO;
        }
    }
    /// 优先判断白名单
    if (self.onlyPrefixes.count > 0) {
        for (NSString * str in self.onlyPrefixes) {
            if ([NSStringFromClass(cls) hasPrefix:str]) {
                return YES;
            }
        }
        return NO;
    }
    /// 判断黑名单
    else {
        for (NSString * str in self.ignorePrefixes) {
            if ([NSStringFromClass(cls) hasPrefix:str]) {
                return NO;
            }
        }
        return YES;
    }
}

#pragma mark - 私有方法

+ (void)filterProtectionsOn:(ASProtectionType)protectionType operation:(BOOL)openOperation{
    IMP imp;
    /// 全部
    if (protectionType == ASProtectionTypeAll) {
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingForwardingTargetForSelector));
        [self filterProtectionsOn:ASProtectionTypeUnrecognizedSelector protectionName:kUnrecognizedSelector operation:openOperation imp:imp];
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingAddObserverForKeyPathOptionsContext));
        [self filterProtectionsOn:ASProtectionTypeKVO protectionName:kKVOException operation:openOperation imp:imp];
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingScheduledTimerWithTimeInterval));
        [self filterProtectionsOn:ASProtectionTypeTimer protectionName:kTimerException operation:openOperation imp:imp];
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingContainersMethods));
        [self filterProtectionsOn:ASProtectionTypeContainers protectionName:kContainersException operation:openOperation imp:imp];
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingSetValueForKey));
        [self filterProtectionsOn:ASProtectionTypeKVC protectionName:kKVCException operation:openOperation imp:imp];
    }
    /// UnrecognizedSelector保护
    if (protectionType & ASProtectionTypeUnrecognizedSelector) {
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingForwardingTargetForSelector));
        [self filterProtectionsOn:protectionType protectionName:kUnrecognizedSelector operation:openOperation imp:imp];
    }
    /// KVO保护
    if (protectionType & ASProtectionTypeKVO) {
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingAddObserverForKeyPathOptionsContext));
        [self filterProtectionsOn:protectionType protectionName:kKVOException operation:openOperation imp:imp];
    }
    /// Timer保护
    if (protectionType & ASProtectionTypeTimer) {
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingScheduledTimerWithTimeInterval));
        [self filterProtectionsOn:protectionType protectionName:kTimerException operation:openOperation imp:imp];
    }
    /// Containers保护
    if (protectionType & ASProtectionTypeContainers) {
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingContainersMethods));
        [self filterProtectionsOn:protectionType protectionName:kContainersException operation:openOperation imp:imp];
    }
    /// KVC保护
    if (protectionType & ASProtectionTypeKVC) {
        imp = class_getMethodImplementation([ASProtector class], @selector(AS_mappingSetValueForKey));
        [self filterProtectionsOn:protectionType protectionName:kKVCException operation:openOperation imp:imp];
    }
}

+ (void)filterProtectionsOn:(ASProtectionType)protectionType protectionName:(NSString *)protectionName operation:(BOOL)openOperation imp:(IMP)imp{
    /// 开启
    if (openOperation) {
        /// 存在该imp，说明没有被交换，此时应该进行交换
        if (AS_ImpExistInList(impList, imp)) {
            [self exchangeMethodWithType:protectionType];
        }
    }
    /// 关闭
    else {
        /// 不存在该imp，说明发生过方法交换。此时应该进行再次交换
        if (!AS_ImpExistInList(impList, imp)) {
            [self exchangeMethodWithType:protectionType];
        }
    }
}

+ (void)exchangeMethodWithType:(ASProtectionType)protectionType{
    /// UnrecognizedSelector保护
    if (protectionType & ASProtectionTypeUnrecognizedSelector) {
        [NSObject as_exchangeInstanceMethodForRecognized];
        AS_ExchangeInstanceMethod([ASProtector class], @selector(AS_mappingForwardingTargetForSelector), [ASProtector class], @selector(AS_excMappingForwardingTargetForSelector));
    }
    /// KVO保护
    if (protectionType & ASProtectionTypeKVO) {
        [NSObject as_exchangeInstanceMethodForKVO];
        AS_ExchangeInstanceMethod([ASProtector class], @selector(AS_mappingAddObserverForKeyPathOptionsContext), [ASProtector class], @selector(AS_excMappingAddObserverForKeyPathOptionsContext));
    }
    /// Timer保护
    if (protectionType & ASProtectionTypeTimer) {
        [NSTimer as_exchangeInstanceMethod];
        AS_ExchangeInstanceMethod([ASProtector class], @selector(AS_mappingScheduledTimerWithTimeInterval), [ASProtector class], @selector(AS_excMappingScheduledTimerWithTimeInterval));
    }
    /// Containers保护
    if (protectionType & ASProtectionTypeContainers) {
        [ASProtectorContainers exchangeContainersMethods];
        AS_ExchangeInstanceMethod([ASProtector class], @selector(AS_mappingContainersMethods), [ASProtector class], @selector(AS_excMappingContainersMethods));
    }
    /// KVC保护
    if (protectionType & ASProtectionTypeKVC) {
        [NSObject as_exchangeInstanceMethodForKVC];
        AS_ExchangeInstanceMethod([ASProtector class], @selector(AS_mappingSetValueForKey), [ASProtector class], @selector(AS_excMappingSetValueForKey));
    }
}


#pragma mark - IMP映射

///NSObject ForwardingTargetForSelector方法的映射
- (void)AS_mappingForwardingTargetForSelector{
}

- (void)AS_excMappingForwardingTargetForSelector{
}

///NSObject addObserver:forKeyPath:options:context:方法的映射
- (void)AS_mappingAddObserverForKeyPathOptionsContext{
}

- (void)AS_excMappingAddObserverForKeyPathOptionsContext{
}

///NSObject setValue:forKey:方法的映射
- (void)AS_mappingSetValueForKey{
}

- (void)AS_excMappingSetValueForKey{
}

///NSTimer scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:方法的映射
- (void)AS_mappingScheduledTimerWithTimeInterval{
}

- (void)AS_excMappingScheduledTimerWithTimeInterval{
}

/// Containers 方法的映射
- (void)AS_mappingContainersMethods{
}

- (void)AS_excMappingContainersMethods{
}

@end
