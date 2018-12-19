//
//  UFLog.m
//  UFileSDK
//
//  Created by ethan on 2018/10/31.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFLog.h"
#import "UFileSDKConst.h"
#import "UFConfig.h"
#include "log4cplus_ufile.h"
#import "UFFileClient.h"

/*   define log level  */
int UFile_IOS_FLAG_FATAL = 0x10;
int UFile_IOS_FLAG_ERROR = 0x08;
int UFile_IOS_FLAG_WARN = 0x04;
int UFile_IOS_FLAG_INFO = 0x02;
int UFile_IOS_FLAG_DEBUG = 0x01;
int UFile_IOS_LOG_LEVEL = UFile_IOS_LOG_LEVEL = UFile_IOS_FLAG_FATAL|UFile_IOS_FLAG_ERROR;

@interface UFLog()


@end

@implementation UFLog

//static UFLog *ufService_instance = nil;
//+ (instancetype)shareInstance
//{
//    static dispatch_once_t ufService_onceToken;
//    dispatch_once(&ufService_onceToken, ^{
//        ufService_instance = [[super allocWithZone:NULL] init];
//    });
//    return ufService_instance;
//}

+ (void)settingSDKLogLevel:(UFSDKLogLevel)logLevel
{
    switch (logLevel) {
        case UFSDKLogLevel_FATAL:
        {
            UFile_IOS_LOG_LEVEL = UFile_IOS_FLAG_FATAL;
            log4cplus_fatal("UFileSDK", "setting UCSDK log level ,UFile_IOS_FLAG_FATAL...\n");
        }
            break;
        case UFSDKLogLevel_ERROR:
        {
            UFile_IOS_LOG_LEVEL = UFile_IOS_FLAG_FATAL|UFile_IOS_FLAG_ERROR;
            log4cplus_warn("UFileSDK", "setting UCSDK log level ,UFile_IOS_FLAG_ERROR...\n");
        }
            break;
        case UFSDKLogLevel_WARN:
        {
            UFile_IOS_LOG_LEVEL = UFile_IOS_FLAG_FATAL|UFile_IOS_FLAG_ERROR|UFile_IOS_FLAG_WARN;
            log4cplus_warn("UFileSDK", "setting UCSDK log level ,UFile_IOS_FLAG_WARN...\n");
        }
            break;
        case UFSDKLogLevel_INFO:
        {
            UFile_IOS_LOG_LEVEL = UFile_IOS_FLAG_FATAL|UFile_IOS_FLAG_ERROR|UFile_IOS_FLAG_WARN|UFile_IOS_FLAG_INFO;
            log4cplus_info("UFileSDK", "setting UCSDK log level ,UFile_IOS_FLAG_INFO...\n");
        }
            break;
        case UFSDKLogLevel_DEBUG:
        {
            UFile_IOS_LOG_LEVEL = UFile_IOS_FLAG_FATAL|UFile_IOS_FLAG_ERROR|UFile_IOS_FLAG_WARN|UFile_IOS_FLAG_INFO|UFile_IOS_FLAG_DEBUG;
            log4cplus_debug("UFileSDK", "setting UCSDK log level ,UCNetAnalysisSDKLogLevel_DEBUG...\n");
        }
            break;
            
        default:
            break;
    }
}

@end
