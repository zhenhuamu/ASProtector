//
//  NSTimer+TimerProtector.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (TimerProtector)

+ (void)as_exchangeInstanceMethod;

@end

NS_ASSUME_NONNULL_END
