//
//  ASProtectorContainers.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "ASProtectorContainers.h"
#import "NSArray+NSRangeException.h"
#import "NSDictionary+NSRangeException.h"
#import "NSString+NSRangeException.h"


@implementation ASProtectorContainers

+ (void)exchangeContainersMethods {
    [NSArray as_exchangeInstanceMethod];
    [NSDictionary as_exchangeInstanceMethod];
    [NSString as_exchangeInstanceMethod];
}

@end
