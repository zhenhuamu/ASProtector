//
//  ASRecognizedCrashHandler.m
//
//  Created by AndyMu on 2020/6/1.
//

#import "ASRecognizedCrashHandler.h"

@implementation ASRecognizedCrashHandler

+ (instancetype)shared {
    static ASRecognizedCrashHandler *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [ASRecognizedCrashHandler shared];
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [ASRecognizedCrashHandler shared];
}

@end
