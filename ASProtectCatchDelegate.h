//
//  ASProtectCatchDelegate.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>
#import "ASProtectorCatchError.h"


NS_ASSUME_NONNULL_BEGIN

@protocol ASProtectCatchDelegate <NSObject>

/// 捕获到的错误信息
- (void)protectCatchInfo:(ASProtectorCatchError *)info;

@end

NS_ASSUME_NONNULL_END
