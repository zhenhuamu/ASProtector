//
//  NSObject+ASKVCProtector.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSObject+ASKVCProtector.h"
#import "ASProtector.h"


@implementation NSObject (ASKVCProtector)

+ (void)as_exchangeInstanceMethodForKVC {
    AS_ExchangeInstanceMethod([NSObject class], @selector(setValue:forKey:), [NSObject class], @selector(as_setValue:forKey:));
    AS_ExchangeInstanceMethod([NSObject class], @selector(setNilValueForKey:), [NSObject class], @selector(as_setNilValueForKey:));
    AS_ExchangeInstanceMethod([NSObject class], @selector(setValue:forUndefinedKey:), [NSObject class], @selector(as_setValue:forUndefinedKey:));
    AS_ExchangeInstanceMethod([NSObject class], @selector(valueForUndefinedKey:), [NSObject class], @selector(as_valueForUndefinedKey:));
}

- (void)as_setValue:(id)value forKey:(NSString *)key {
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVC]) {
        [self as_setValue:value forKey:key];
    }else {
        if (key == nil) {
            NSString *message = [NSString stringWithFormat:@"[<%@ %p> setValueForNilKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
            [NSObject as_gatherError:message];
            return;
        }
        [self as_setValue:value forKey:key];
    }
}

- (void)as_setNilValueForKey:(NSString *)key {
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVC]) {
        [self as_setNilValueForKey:key];
    }else {
        NSString *message = [NSString stringWithFormat:@"[<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
        [NSObject as_gatherError:message];
    }
}

- (void)as_setValue:(id)value forUndefinedKey:(NSString *)key {
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVC]) {
        [self as_setValue:value forUndefinedKey:key];
    }else {
        NSString *message = [NSString stringWithFormat:@"[<%@ %p> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key: %@,value:%@'",NSStringFromClass([self class]),self,key,value];
        [NSObject as_gatherError:message];
    }
}

- (nullable id)as_valueForUndefinedKey:(NSString *)key {
    if (![[ASProtector shared] isNeedProtectionWithClass:self.class type:ASProtectionTypeKVC]) {
        [self as_valueForUndefinedKey:key];
    }else {
        NSString *message = [NSString stringWithFormat:@"crashMessages :[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key: %@",NSStringFromClass([self class]),self,key];
        [NSObject as_gatherError:message];
    }
    return self;
}

#pragma mark -

/// 错误信息收集
+ (void)as_gatherError:(NSString *)message {
    ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeContainers infos:@{ASError_Reason:message}];
    [ASProtector postErrorInfo:error];
}

@end
