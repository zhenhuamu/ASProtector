//
//  ASProtectorCatchError.h
//
//  Created by AndyMu on 2020/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 错误信息堆栈根Key
FOUNDATION_EXPORT NSString *const ASErrorCallStackSymbols;

/// 发生错误的当前显示的视图控制器
FOUNDATION_EXPORT NSString *const ASError_TopVC;
/// 发生错误的原因简述
FOUNDATION_EXPORT NSString *const ASError_Reason;


typedef NS_ENUM(NSInteger, ASErrorType) {
    /// UnrecognizedSelector异常
    ASErrorTypeUnrecognizedSelector = 1,
    /// KVO异常
    ASErrorTypeKVO,
    /// Timer异常
    ASErrorTypeTimer,
    /// Containers
    ASErrorTypeContainers,
    /// KVC异常
    ASErrorTypeKVC,
};


@interface ASProtectorCatchError : NSObject

/// 错误类型
@property (nonatomic, assign, readonly) ASErrorType errorType;
/// 错误信息字典，通过相对应的key获取
@property (nonatomic, copy, readonly) NSDictionary *errorInfos;
/// 错误堆栈
@property (nonatomic, copy, readonly) NSArray *errorCallStackSymbols;

/**
 初始化方法
 @param errorType 错误类型
 @param errorInfos 错误信息字典【会默认添加当前显示的控制器，当前堆栈信息】
 @return 错误实例
 */
+ (instancetype)errorWithType:(ASErrorType)errorType infos:(nullable NSDictionary *)errorInfos;

/// unrecognizedSel原因
+ (NSString *)unrecognizedSelReason:(SEL)sel ob:(id)ob;

/// 获取格式化的错误信息
- (NSString *)formatErrorInfo;

@end

NS_ASSUME_NONNULL_END
