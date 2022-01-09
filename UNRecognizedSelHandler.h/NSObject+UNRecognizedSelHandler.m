//
//  NSObject+UNRecognizedSelHandler.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSObject+UNRecognizedSelHandler.h"
#import "ASProtector.h"
#import "ASRecognizedCrashHandler.h"


@implementation NSObject (UNRecognizedSelHandler)

+ (void)as_exchangeInstanceMethodForRecognized {
    /// 实例方法
    AS_ExchangeInstanceMethod([NSObject class], @selector(forwardingTargetForSelector:), [NSObject class], @selector(as_forwardingTargetForSelector:));
    /// 类方法
    AS_ExchangeClassMethod([NSObject class], @selector(forwardingTargetForSelector:), @selector(as_forwardingTargetForSelector:));
}

//将崩溃信息转发到一个指定的类中执行FastForwarding
- (id)as_forwardingTargetForSelector:(SEL)selector{
    /// 判断是否是NSNull或者有没有重写消息转发的方法
    if ([self isEqual:[NSNull null]] ||
        ![self.class overideForwardingMethods] ||
        [[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeUnrecognizedSelector]) {
        /// 添加保护方法
        class_addMethod([ASRecognizedCrashHandler class], selector, (IMP)AS_DynamicAddMethodIMP, "@:");
        ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeUnrecognizedSelector infos:@{ASError_Reason:[ASProtectorCatchError unrecognizedSelReason:selector ob:self]}];
        [ASProtector postErrorInfo:error];
        /// 返回处理selector的对象
        return [ASRecognizedCrashHandler shared];
    }
    return [self as_forwardingTargetForSelector:selector];
}

//将崩溃信息转发到一个指定的类中执行FastForwarding
+ (id)as_forwardingTargetForSelector:(SEL)selector{
    /// 判断是否是NSNull或者有没有重写消息转发的方法
    if ([self isKindOfClass:NSNull.class] ||
        ![self overideForwardingMethods] ||
        [[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeUnrecognizedSelector]) {
        /// 添加保护方法
        class_addMethod([ASRecognizedCrashHandler class], selector, (IMP)AS_DynamicAddMethodIMP, "@:");
        ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeUnrecognizedSelector infos:@{ASError_Reason:[ASProtectorCatchError unrecognizedSelReason:selector ob:self]}];
        [ASProtector postErrorInfo:error];
        /// 返回处理selector的对象
        return [ASRecognizedCrashHandler shared];
    }
    return [self as_forwardingTargetForSelector:selector];
}

/// 判断是否重写了消息转发的方法
+ (BOOL)overideForwardingMethods{
    BOOL overide = NO;
    BOOL stepTwo = (class_getMethodImplementation([NSObject class], @selector(forwardingTargetForSelector:)) != class_getMethodImplementation([self class], @selector(forwardingTargetForSelector:)));
    BOOL stepThree = (class_getMethodImplementation([NSObject class], @selector(forwardInvocation:)) != class_getMethodImplementation([self class], @selector(forwardInvocation:)));
    overide = (stepTwo || stepThree);
    return overide;
}

@end
