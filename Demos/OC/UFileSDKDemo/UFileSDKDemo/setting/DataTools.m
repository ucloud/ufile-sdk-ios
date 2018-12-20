//
//  DataTools.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/5.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "DataTools.h"


@implementation DataTools

+ (void)storeStrData:(NSString *)strData keyName:(NSString *)key
{
    if (!strData || !key) {
        NSLog(@"%s, store data error , reason : strData or key is nil..",__func__);
        return;
    }
    [KUFUserDefaults setObject:strData forKey:key];
    [KUFUserDefaults synchronize];
}

+ (NSString *)getStrData:(NSString *)key
{
    if (!key) {
        NSLog(@"%s, get data error , reason :  key is nil..",__func__);
        return nil;
    }
    return [KUFUserDefaults objectForKey:key];
}

@end
