//
//  NSObject+ASKVCProtector.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ASKVCProtector)

+ (void)as_exchangeInstanceMethodForKVC;

@end

NS_ASSUME_NONNULL_END
