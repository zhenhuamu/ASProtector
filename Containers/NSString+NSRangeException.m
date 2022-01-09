//
//  NSString+NSRangeException.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSString+NSRangeException.h"
#import "ASProtector.h"


@implementation NSString (NSRangeException)

+ (void)as_exchangeInstanceMethod {
    @autoreleasepool {
        /// NSString
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(stringByAppendingString:), objc_getClass("__NSCFString"), @selector(as_stringByAppendingString:));
        AS_ExchangeInstanceMethod(objc_getClass("NSTaggedPointerString"), @selector(stringByAppendingString:), objc_getClass("NSTaggedPointerString"), @selector(as_tagged_stringByAppendingString:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(substringToIndex:), objc_getClass("__NSCFString"), @selector(as_substringToIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("NSTaggedPointerString"), @selector(substringToIndex:), objc_getClass("NSTaggedPointerString"), @selector(as_tagged_substringToIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(substringFromIndex:), objc_getClass("__NSCFString"), @selector(as_substringFromIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("NSTaggedPointerString"), @selector(substringFromIndex:), objc_getClass("NSTaggedPointerString"), @selector(as_tagged_substringFromIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(substringWithRange:), objc_getClass("__NSCFString"), @selector(as_substringWithRange:));
        AS_ExchangeInstanceMethod(objc_getClass("NSTaggedPointerString"), @selector(substringWithRange:), objc_getClass("NSTaggedPointerString"), @selector(as_tagged_substringWithRange:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(characterAtIndex:), objc_getClass("__NSCFString"), @selector(as_characterAtIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("NSTaggedPointerString"), @selector(characterAtIndex:), objc_getClass("NSTaggedPointerString"), @selector(as_tagged_characterAtIndex:));
        /// NSMutableString
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(insertString:atIndex:), objc_getClass("__NSCFString"), @selector(as_insertString:atIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(deleteCharactersInRange:), objc_getClass("__NSCFString"), @selector(as_deleteCharactersInRange:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSCFString"), @selector(replaceCharactersInRange:withString:), objc_getClass("__NSCFString"), @selector(as_replaceCharactersInRange:withString:));
    }
}

#pragma mark - __NSCFString

- (NSString *)as_stringByAppendingString:(NSString *)str{
    if (str == nil) {
        str = @"";
        [NSString as_gatherError];
    }
    return [self as_stringByAppendingString:str];
}

- (NSString *)as_substringToIndex:(NSUInteger)to {
    if (to > self.length) {
        [NSString as_gatherError];
        return nil;
    }
    return [self as_substringToIndex:to];
}

- (NSString *)as_substringFromIndex:(NSUInteger)to {
    if (to > self.length) {
        [NSString as_gatherError];
        return nil;
    }
    return [self as_substringFromIndex:to];
}

- (NSString *)as_substringWithRange:(NSRange)range {
    if ((range.location + range.length) > self.length) {
        [NSString as_gatherError];
        return nil;
    }
    return [self as_substringWithRange:range];
}

- (unichar)as_characterAtIndex:(NSUInteger)to {
    if (to >= self.length) {
        [NSString as_gatherError];
        return 0;
    }
    return [self as_characterAtIndex:to];
}

- (void)as_insertString:(NSString *)str atIndex:(NSUInteger)loc{
    if (str == nil || loc > self.length) {
        [NSString as_gatherError];
    }else{
        [self as_insertString:str atIndex:loc];
    }
}

- (void)as_deleteCharactersInRange:(NSRange)range{
    if ((range.location + range.length) > self.length) {
        [NSString as_gatherError];
    }else {
        [self as_deleteCharactersInRange:range];
    }
}

- (void)as_replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    if (str == nil || (range.location + range.length) > self.length) {
        [NSString as_gatherError];
    }else {
        [self as_replaceCharactersInRange:range withString:str];
    }
}

#pragma mark - NSTaggedPointerString

- (NSString *)as_tagged_stringByAppendingString:(NSString *)str{
    if (str == nil) {
        str = @"";
        [NSString as_gatherError];
    }
    return [self as_tagged_stringByAppendingString:str];
}

- (NSString *)as_tagged_substringToIndex:(NSUInteger)to {
    if (to > self.length) {
        [NSString as_gatherError];
        return nil;
    }
    return [self as_tagged_substringToIndex:to];
}

- (NSString *)as_tagged_substringFromIndex:(NSUInteger)to {
    if (to > self.length) {
        [NSString as_gatherError];
        return nil;
    }
    return [self as_tagged_substringFromIndex:to];
}

- (NSString *)as_tagged_substringWithRange:(NSRange)range {
    if (range.location + range.length > self.length) {
        [NSString as_gatherError];
        return nil;
    }
    return [self as_tagged_substringWithRange:range];
}

- (unichar)as_tagged_characterAtIndex:(NSUInteger)to {
    if (to >= self.length) {
        [NSString as_gatherError];
        return 0;
    }
    return [self as_tagged_characterAtIndex:to];
}

#pragma mark -

/// 错误信息收集
+ (void)as_gatherError {
    ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeContainers infos:nil];
    [ASProtector postErrorInfo:error];
}

@end
