//
//  NSArray+NSRangeException.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "NSArray+NSRangeException.h"
#import "ASProtector.h"


/**
1、在alloc之后得到的类都是 __NSPlaceholderArray
2、@[]，返回的是__NSArray0的单例
3、@[@"1"]单个元素 或者 NSArray创建，返回的是__NSSingleObjectArrayI的实例
4、@[@"1",@"2"]2个元素以上，返回的是__NSArrayI的实例
5、在init之后且是可变数组的时候，返回的是__NSArrayM的实例
 */

@implementation NSArray (NSRangeException)

+ (void)as_exchangeInstanceMethod {
    @autoreleasepool {
        /// initWithNil
        /// iOS10系列会crash，进行容错处理
        if (@available(iOS 11.0, *)) {
            AS_ExchangeInstanceMethod(objc_getClass("__NSPlaceholderArray"), @selector(initWithObjects:count:), objc_getClass("__NSPlaceholderArray"), @selector(as_initWithObjects:count:));
        }
        /// objectAtIndex:
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:), objc_getClass("__NSArrayI"), @selector(as_objectIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:), objc_getClass("__NSArrayI"), @selector(as_objectAtIndexedSubscript:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:), objc_getClass("__NSSingleObjectArrayI"), @selector(as_singleObjectIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:), objc_getClass("__NSArray0"), @selector(as_emptyObjectIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:), objc_getClass("__NSArrayM"), @selector(as_mutableObjectIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndexedSubscript:), objc_getClass("__NSArrayM"), @selector(as_replace_objectAtIndexedSubscript:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSFrozenArrayM"), @selector(objectAtIndexedSubscript:), objc_getClass("__NSFrozenArrayM"), @selector(as_frozen_objectAtIndexedSubscript:));
        /// remove
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(removeObjectAtIndex:), objc_getClass("__NSArrayM"), @selector(as_removeObjectAtIndex:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(removeObjectsInRange:), objc_getClass("__NSArrayM"), @selector(as_removeObjectsInRange:));
        /// insert
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(insertObject:atIndex:), objc_getClass("__NSArrayM"), @selector(as_insertObject:atIndex:));
        /// replace
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), objc_getClass("__NSArrayM"), @selector(as_replaceObjectAtIndex:withObject:));
        AS_ExchangeInstanceMethod(objc_getClass("__NSArrayM"), @selector(replaceObjectsInRange:withObjectsFromArray:), objc_getClass("__NSArrayM"), @selector(as_replaceObjectsInRange:withObjectsFromArray:));
    }
}

#pragma mark - __NSPlaceholderArray

- (instancetype)as_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt{
    id tmpObject[cnt];
    NSInteger index = 0;
    for (NSInteger i=0; i<cnt; i++) {
        id tmp = objects[i];
        if (tmp == nil) {
            [NSArray as_gatherError];
            continue;
        }
        tmpObject[index] = objects[i];
        index++;
    }
    return [self as_initWithObjects:tmpObject count:index];
}

#pragma mark - __NSArrayI

- (id)as_objectIndex:(NSUInteger)index{
    if (index >= self.count || index < 0) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_objectIndex:index];
}

- (id)as_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx >= self.count) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_objectAtIndexedSubscript:idx];
}

#pragma mark - __NSSingleObjectArrayI

- (id)as_singleObjectIndex:(NSUInteger)index{
    if (index >= self.count || index < 0) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_singleObjectIndex:index];
}

#pragma mark - __NSArray0

- (id)as_emptyObjectIndex:(NSUInteger)index{
    if (index >= self.count || index < 0) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_emptyObjectIndex:index];
}

#pragma mark - __NSArrayM

- (id)as_mutableObjectIndex:(NSUInteger)index{
    if (index >= self.count || index < 0) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_mutableObjectIndex:index];
}

- (id)as_replace_objectAtIndexedSubscript:(NSUInteger)index{
    if (index >= self.count || index < 0) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_replace_objectAtIndexedSubscript:index];
}

- (void)as_removeObjectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        [NSArray as_gatherError];
        return;
    }
    [self as_removeObjectAtIndex:index];
}

- (void)as_removeObjectsInRange:(NSRange)range{
    if (range.location + range.length > self.count) {
        [NSArray as_gatherError];
        return;
    }
    [self as_removeObjectsInRange:range];
}

- (void)as_insertObject:(id)object atIndex:(NSUInteger)index{
    if (object == nil) {
        [NSArray as_gatherError];
        return;
    }
    if (index > self.count) {
        [NSArray as_gatherError];
        return;
    }
    [self as_insertObject:object atIndex:index];
}

- (void)as_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if (anObject == nil) {
        [NSArray as_gatherError];
        return;
    }
    if (index >= self.count) {
        [NSArray as_gatherError];
        return;
    }
    [self as_replaceObjectAtIndex:index withObject:anObject];
}

-(void)as_replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray{
    if (range.location + range.length > self.count) {
        [NSArray as_gatherError];
    }else{
        [self as_replaceObjectsInRange:range withObjectsFromArray:otherArray];
    }
}

#pragma mark - __NSFrozenArrayM

- (id)as_frozen_objectAtIndexedSubscript:(NSUInteger)index{
    if (index >= self.count || index < 0) {
        [NSArray as_gatherError];
        return nil;
    }
    return [self as_frozen_objectAtIndexedSubscript:index];
}

#pragma mark - 

/// 错误信息收集
+ (void)as_gatherError {
    ASProtectorCatchError *error = [ASProtectorCatchError errorWithType:ASErrorTypeContainers infos:nil];
    [ASProtector postErrorInfo:error];
}

@end
