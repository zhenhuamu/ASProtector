//
//  NSTimer+TimerProtector.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSTimer+TimerProtector.h"
#import "ASProtectorWeakProxy.h"
#import "ASProtector.h"


@implementation NSTimer (TimerProtector)

+ (void)as_exchangeInstanceMethod {
    AS_ExchangeClassMethod([NSTimer class], @selector(timerWithTimeInterval:target:selector:userInfo:repeats:), @selector(as_timerWithTimeInterval:target:selector:userInfo:repeats:));
    AS_ExchangeClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:), @selector(as_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
}

+ (NSTimer *)as_timerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    /// 非循环、target非系统类、黑白名单、target非继承NSProxy
    if (!yesOrNo ||
        ![[ASProtector shared] isNeedProtectionWithClass:[target class] type:ASProtectionTypeTimer] ||
        ([target respondsToSelector:@selector(isProxy)] && [target isProxy])) {
        return [self as_timerWithTimeInterval:timeInterval target:target selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }
    return [self as_timerWithTimeInterval:timeInterval target:[ASProtectorWeakProxy proxyWithTarget:target] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)as_scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    /// 非循环、target非系统类、黑白名单、target非继承NSProxy
    if (!yesOrNo ||
        ![[ASProtector shared] isNeedProtectionWithClass:[target class] type:ASProtectionTypeTimer] ||
        ([target respondsToSelector:@selector(isProxy)] && [target isProxy])) {
        return [self as_scheduledTimerWithTimeInterval:timeInterval target:target selector:selector userInfo:userInfo repeats:yesOrNo];
    }
    return [self as_scheduledTimerWithTimeInterval:timeInterval target:[ASProtectorWeakProxy proxyWithTarget:target] selector:selector userInfo:userInfo repeats:yesOrNo];
}

@end
