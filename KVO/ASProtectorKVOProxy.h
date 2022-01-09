//
//  ASProtectorKVOProxy.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>
#import "ASProtector.h"

typedef void(^ASProtectorKVOFailure)(ASProtectorCatchError *error);

NS_ASSUME_NONNULL_BEGIN

@interface ASProtectorKVOProxy : NSObject

/// 将添加kvo时的相关信息加入到关系maps中
- (void)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context
                             success:(void(^)(void))success
                             failure:(ASProtectorKVOFailure)failure;

/// 从关系maps中移除观察者
- (void)removeKVOInfoInMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath
                                success:(void(^)(void))success
                                failure:(ASProtectorKVOFailure)failure;

@end

NS_ASSUME_NONNULL_END
