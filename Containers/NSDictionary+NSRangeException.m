//
//  NSDictionary+NSRangeException.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSDictionary+NSRangeException.h"
#import "ASProtector.h"


@implementation NSDictionary (NSRangeException)

+ (void)as_exchangeInstanceMethod {
    @autoreleasepool {
        /// initWithNil
        AS_ExchangeInstanceMethod(objc_getClass("__NSPlaceholderDictionary"), @selector(initWithObjects:forKeys:count:), objc_getClass("__NSPlaceholderDictionary"), @selector(as_initWithObjects:forKeys:count:));
    }
}

#pragma mark - __NSPlaceholderDictionary

- (instancetype)as_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    NSUInteger index = 0;
    id _Nonnull objectsNew[cnt];
    id <NSCopying> _Nonnull keysNew[cnt];
    for (int i = 0; i<cnt; i++) {
        if (objects[i] && keys[i]) {
            objectsNew[index] = objects[i];
            keysNew[index] = keys[i];
            index ++;
        }else{
            [NSDictionary as_gatherError];
        }
    }
    return [self as_initWithObjects:objectsNew forKeys:keysNew count:index];
}

#pragma mark -

/// 错误信息收集
+ (void)as_gatherError {
    ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeContainers infos:nil];
    [ASProtector postErrorInfo:error];
}

@end
