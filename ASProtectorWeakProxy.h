//
//  ASProtectorWeakProxy.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASProtectorWeakProxy : NSProxy

@property (nonatomic, weak, readonly, nullable) id target;

- (nonnull instancetype)initWithTarget:(nonnull id)target;
+ (nonnull instancetype)proxyWithTarget:(nonnull id)target;


@end

NS_ASSUME_NONNULL_END
