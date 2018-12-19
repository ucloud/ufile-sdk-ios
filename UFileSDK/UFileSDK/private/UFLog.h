//
//  UFLog.h
//  UFileSDK
//
//  Created by ethan on 2018/10/31.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFSDKHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface UFLog : NSObject

+ (void)settingSDKLogLevel:(UFSDKLogLevel)logLevel;
@end

NS_ASSUME_NONNULL_END
