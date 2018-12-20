//
//  DataTools.h
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/5.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFileSDKDemoConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataTools : NSObject
+ (void)storeStrData:(NSString *)strData keyName:(NSString *)key;
+ (NSString *)getStrData:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
