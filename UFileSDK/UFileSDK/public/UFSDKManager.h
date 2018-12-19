//
//  UFSDKManager.h
//  UFileSDK
//
//  Created by ethan on 2018/10/31.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFSDKHelper.h"


NS_ASSUME_NONNULL_BEGIN


/**
 这是 `NSObject` 的一个子类。用来做sdk系统级的设置和信息获取等操作，你可以利用该类完成以下操作：
 
 * 设置`UFileSDK`日志级别
 * 获取`UFileSDK`的版本信息
 
 */
@interface UFSDKManager : NSObject

#pragma mark- instance method

/**
 @brief 创建一个 `UFSDKManager` 实例
 @return 返回一个 `UFSDKManager` 实例
 */
+ (instancetype _Nonnull)shareInstance;

#pragma mark- setting SDK log level

/**
 @brief 设置日志级别
 @discussion  如果不设置，默认的日志级别是 `UFSDKLogLevel_ERROR`
 @param logLevel 日志级别，类型是一个枚举 `UFSDKLogLevel`
 */
- (void)settingSDKLogLevel:(UFSDKLogLevel)logLevel;

#pragma mark- sdk info

/**
 @brief 查看SDK版本号

 @return 返回SDK版本号
 */
- (NSString *)version;

@end

NS_ASSUME_NONNULL_END
