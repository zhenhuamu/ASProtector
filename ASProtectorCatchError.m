//
//  ASProtectorCatchError.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "ASProtectorCatchError.h"
#import "ASProtectorFunctions.h"
#import <pthread.h>


/// 错误信息堆栈根Key
NSString *const ASErrorCallStackSymbols = @"ErrorCallStackSymbols";

/// 发生错误的当前显示的视图控制器
NSString *const ASError_TopVC = @"ErrorTopViewController";
/// 发生错误的原因简述
NSString *const ASError_Reason = @"ErrorReason";

@interface ASProtectorCatchError ()

/// 错误类型
@property (nonatomic, assign) ASErrorType errorType;
/// 错误信息字典，通过相对应的key获取
@property (nonatomic, copy) NSDictionary *errorInfos;
/// 错误堆栈
@property (nonatomic, copy) NSArray *errorCallStackSymbols;


@end

@implementation ASProtectorCatchError

#pragma mark - 类方法

/**
 初始化方法
 @param errorType 错误类型
 @param errorInfos 错误信息字典
 @return 错误实例
 */
+ (instancetype)errorWithType:(ASErrorType)errorType infos:(NSDictionary *)errorInfos {
    return [[self alloc]initWithType:errorType infos:errorInfos];
}

/// unrecognizedSel原因
+ (NSString *)unrecognizedSelReason:(SEL)sel ob:(id)ob {
    return [NSString stringWithFormat:@"UNRecognized Selector:'%@' sent to instance %@",NSStringFromSelector(sel),ob];
}

#pragma mark - 实例方法

- (instancetype)initWithType:(ASErrorType)errorType infos:(NSDictionary *)errorInfos{
    if (self = [super init]) {
        self.errorType = errorType;
        self.errorInfos = [self handleDict:errorInfos];
    }
    return self;
}

/// 添加当前显示的控制器，当前堆栈信息
- (NSDictionary *)handleDict:(NSDictionary *)dict {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:(dict ? : @{})];
    NSArray *callStackSymbolsArray = [NSThread callStackSymbols];
    [mDict setValue:callStackSymbolsArray forKey:ASErrorCallStackSymbols];
    __block UIViewController * topViewController = nil;
    if (pthread_main_np()) {
        topViewController = AS_TopViewController();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            topViewController = AS_TopViewController();
        });
    }
    [mDict setValue:topViewController forKey:ASError_TopVC];
    return mDict;
}

/// 获取格式化的错误信息
- (NSString *)formatErrorInfo {
    NSMutableString *text = [NSMutableString stringWithString:[NSString stringWithFormat:@"\n{\n"]];
    if (self.errorInfos.count > 0) {
        [self.errorInfos enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
            [text appendString:key];
            [text appendString:@":"];
            [text appendString:[NSString stringWithFormat:@"%@\n",obj]];
        }];
        [text appendString:@"}\n"];
    }
    return text.copy;
}

#pragma mark - 懒加载

- (NSArray *)errorCallStackSymbols{
    if (!_errorCallStackSymbols) {
        if ([self.errorInfos.allKeys containsObject:ASErrorCallStackSymbols]) {
            _errorCallStackSymbols = [self.errorInfos objectForKey:ASErrorCallStackSymbols];
        }else{
            _errorCallStackSymbols = @[];
        }
    }
    return _errorCallStackSymbols;
}


@end
