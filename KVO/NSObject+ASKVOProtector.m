//
//  NSObject+ASKVOProtector.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSObject+ASKVOProtector.h"
#import "ASProtector.h"
#import "ASProtectorKVOProxy.h"



@implementation NSObject (ASKVOProtector)

+ (void)as_exchangeInstanceMethodForKVO {
    AS_ExchangeInstanceMethod([NSObject class], @selector(addObserver:forKeyPath:options:context:), [NSObject class], @selector(as_addObserver:forKeyPath:options:context:));
    AS_ExchangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:), [NSObject class], @selector(as_removeObserver:forKeyPath:));
    AS_ExchangeInstanceMethod([NSObject class], @selector(removeObserver:forKeyPath:context:), [NSObject class], @selector(as_removeObserver:forKeyPath:context:));
}

- (void)setAs_kvoProxy:(ASProtectorKVOProxy *)proxy{
    objc_setAssociatedObject(self, @selector(as_kvoProxy), proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ASProtectorKVOProxy *)as_kvoProxy{
    id proxy = objc_getAssociatedObject(self, @selector(as_kvoProxy));
    if (proxy == nil) {
        proxy = [[ASProtectorKVOProxy alloc]init];
        self.as_kvoProxy = proxy;
    }
    return proxy;
}

- (void)as_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVO]) {
        [self as_addObserver:observer forKeyPath:keyPath options:options context:context];
    }else {
        [self.as_kvoProxy addKVOInfoToMapsWithObserver:observer forKeyPath:keyPath options:options context:context success:^{
            [self as_addObserver:self.as_kvoProxy forKeyPath:keyPath options:options context:context];
        } failure:^(ASProtectorCatchError * _Nonnull error) {
            [ASProtector postErrorInfo:error];
        }];
    }
}

- (void)as_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVO]) {
        [self as_removeObserver:observer forKeyPath:keyPath];
    }else {
        [self.as_kvoProxy removeKVOInfoInMapsWithObserver:observer forKeyPath:keyPath success:^{
            [self as_removeObserver:self.as_kvoProxy forKeyPath:keyPath];
        } failure:^(ASProtectorCatchError * _Nonnull error) {
            [ASProtector postErrorInfo:error];
        }];
    }
}

- (void)as_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context{
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVO]) {
        [self as_removeObserver:observer forKeyPath:keyPath context:context];
    }else {
        [self.as_kvoProxy removeKVOInfoInMapsWithObserver:observer forKeyPath:keyPath success:^{
            [self as_removeObserver:self.as_kvoProxy forKeyPath:keyPath context:context];
        } failure:^(ASProtectorCatchError * _Nonnull error) {
            [ASProtector postErrorInfo:error];
        }];
    }
}

@end
