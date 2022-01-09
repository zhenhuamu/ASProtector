//
//  ASProtectorKVOProxy.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "ASProtectorKVOProxy.h"
#import <CommonCrypto/CommonCrypto.h>

typedef NS_ENUM(NSInteger, ASKVOCrashType) {
    /// 参数不合法
    ASKVOCrashTypeParameterInvalid      = 1,
    /// 重复添加observer
    ASKVOCrashTypeRepeatToAddO          = 2,
    /// 移除了未注册的观察者
    ASKVOCrashTypeRemoveUnregisteredO   = 3,
    /// 添加了观察者，但未实现observeValueForKeyPath:ofObject:change:context:
    ASKVOCrashTypeUnrealizedO           = 4
};

@interface ASProtectorKVOProxy ()

/// 关系数据表结构：{keypath : [observer1, observer2 , ...](NSHashTable)}
@property(nonatomic, strong)NSMutableDictionary<NSString *, NSHashTable<NSObject *> *> *keyPathMaps;

@property(nonatomic, copy)ASProtectorKVOFailure failureBlock;

@end

@implementation ASProtectorKVOProxy

- (instancetype)init {
    self = [super init];
    if (nil != self) {
        _keyPathMaps = [NSMutableDictionary dictionary];
    }
    return self;
}

/// 将添加kvo时的相关信息加入到关系maps中
- (void)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context
                             success:(void(^)(void))success
                             failure:(ASProtectorKVOFailure)failure {
    @synchronized (self) {
        /// 参数合法性检查
        if (!observer ||
            !keyPath ||
            ![keyPath isKindOfClass:NSString.class] ||
            keyPath.length <= 0) {
            if (failure) {
                failure([self getErrorInfo:ASKVOCrashTypeParameterInvalid observer:observer keyPath:keyPath]);
            }
            return;
        }
        /// 重复性检查
        NSHashTable<NSObject *> *info = _keyPathMaps[keyPath];
        if (info.count > 0 && [info containsObject:observer]) {
            if (failure) {
                failure([self getErrorInfo:ASKVOCrashTypeRepeatToAddO observer:observer keyPath:keyPath]);
            }
            return;
        }
        /// 不存在映射关系
        if (info.count == 0) {
            info = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
            [info addObject:observer];
            _keyPathMaps[keyPath] = info;
        }
        /// 已经存在映射关系
        else {
            [info addObject:observer];
        }
        if (success) {
            success();
        }
        self.failureBlock = failure;
    }
}

/// 从关系maps中移除观察者
- (void)removeKVOInfoInMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath
                                success:(void(^)(void))success
                                failure:(ASProtectorKVOFailure)failure {
    @synchronized (self) {
        /// 参数合法性检查
        if (!observer ||
            !keyPath ||
            ![keyPath isKindOfClass:NSString.class] ||
            keyPath.length <= 0) {
            if (failure) {
                failure([self getErrorInfo:ASKVOCrashTypeParameterInvalid observer:observer keyPath:keyPath]);
            }
            return;
        }
        /// keyPath正确性检查
        NSHashTable<NSObject *> *info = _keyPathMaps[keyPath];
        if (info.count == 0 || ![info containsObject:observer]) {
            if (failure) {
                failure([self getErrorInfo:ASKVOCrashTypeRemoveUnregisteredO observer:observer keyPath:keyPath]);
            }
            return;
        }
        /// 数据更新
        [info removeObject:observer];
        if (info.count == 0) {
            [_keyPathMaps removeObjectForKey:keyPath];
        }
        if (success) {
            success();
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSHashTable<NSObject *> *info = _keyPathMaps[keyPath];
    for (NSObject *observer in info) {
        @try {
            [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            if (self.failureBlock) {
                self.failureBlock([self getErrorInfo:ASKVOCrashTypeUnrealizedO observer:observer keyPath:keyPath]);
            }
        }
    }
}

#pragma mark - Private

- (ASProtectorCatchError *)getErrorInfo:(ASKVOCrashType)type observer:(NSObject *)observer keyPath:(NSString *)keyPath {
    NSString *reason = @"";
    if (type == ASKVOCrashTypeParameterInvalid) {
        reason = [NSString stringWithFormat:@"\n keypath为nil:\n observer:%@\n keypath:%@ \n",observer,keyPath];
    }else if (type == ASKVOCrashTypeRepeatToAddO) {
        reason = [NSString stringWithFormat:@"\n observer重复添加:\n observer:%@\n keypath:%@ \n",observer,keyPath];
    }else if (type == ASKVOCrashTypeRemoveUnregisteredO) {
        reason = [NSString stringWithFormat:@"\n 移除未注册的observer:\n observer:%@\n keypath:%@ \n",observer,keyPath];
    }else if (type == ASKVOCrashTypeUnrealizedO) {
        reason = [NSString stringWithFormat:@"\n 注册但是未实现observer:\n observer:%@\n keypath:%@ \n",observer,keyPath];
    }
    ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeKVO infos:@{ASError_Reason:reason}];
    return error;
}

@end
