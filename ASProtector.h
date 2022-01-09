//
//  ASProtector.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>
#import "ASProtectorCatchError.h"
#import "ASProtectCatchDelegate.h"
#import "ASProtectorFunctions.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ASProtectionType) {
    /// 开启全部保护
    ASProtectionTypeAll                  = 0,
    /// UnrecognizedSelector保护
    ASProtectionTypeUnrecognizedSelector = 1<<0,
    /// KVO保护
    ASProtectionTypeKVO                  = 1<<1,
    /// Timer保护
    ASProtectionTypeTimer                = 1<<2,
    /// Containers保护
    ASProtectionTypeContainers           = 1<<3,
    /// KVC保护
    ASProtectionTypeKVC                  = 1<<4
};

@interface ASProtector : NSObject

/// 代理
@property (nonatomic, weak) id<ASProtectCatchDelegate> delegate;

+ (instancetype)shared;

/// 开启崩溃保护
+ (void)openProtectionsOn:(ASProtectionType)protectionType;

/// 关闭崩溃保护
+ (void)closeProtectionsOn:(ASProtectionType)protectionType;

/// 捕获信息上报
+ (void)postErrorInfo:(ASProtectorCatchError *)error;

/// 设置黑名单 作用：忽略对具有以下指定前缀的类的保护
/// 例如：@[@"AD"]
- (void)ignoreProtectionsOnClassesWithPrefix:(NSArray *_Nonnull)ignorePrefixes;

/// 设置白名单 作用：只保护对具有以下指定前缀的类【优先级高于黑名单】
/// 例如：@[@"AS"]
- (void)onlyProtectionsOnClassesWithPrefix:(NSArray *_Nonnull)onlyPrefixes;

/// 设置全部类白名单 作用：保护此类型下的全部类  默认：忽略系统类
/// 例如：@[@(ASProtectionTypeKVC)]
- (void)allProtectionsWithType:(NSArray *_Nonnull)types;


/// 是否应该保护此类
/// 全部类保护状态 -> 检查是否系统类 -> 白名单 -> 黑名单
- (BOOL)isNeedProtectionWithClass:(Class)cls type:(ASProtectionType)type;

@end

NS_ASSUME_NONNULL_END
