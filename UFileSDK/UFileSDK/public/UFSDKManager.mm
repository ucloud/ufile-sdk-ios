//
//  UFSDKManager.m
//  UFileSDK
//
//  Created by ethan on 2018/10/31.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFSDKManager.h"
#import "UFLog.h"
#include "UFileSDKConst.h"
#include "log4cplus_ufile.h"

@implementation UFSDKManager

static UFSDKManager *ufSDKManager_instance = nil;
+ (instancetype _Nonnull)shareInstance
{
    static dispatch_once_t ufSDKManager_onceToken;
    dispatch_once(&ufSDKManager_onceToken, ^{
        ufSDKManager_instance = [[super allocWithZone:NULL] init];
    });
    return ufSDKManager_instance;
}

- (void)settingSDKLogLevel:(UFSDKLogLevel)logLevel
{
    [UFLog settingSDKLogLevel:logLevel];
}

- (NSString *)version
{
    return KUFileSDKVersion;
}

@end
