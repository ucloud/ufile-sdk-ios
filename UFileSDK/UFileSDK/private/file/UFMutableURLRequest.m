//
//  UFMutableURLRequest.m
//  UFileSDK
//
//  Created by ethan on 2018/11/13.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFMutableURLRequest.h"
#import "UFTools.h"
#import "UFileSDKConst.h"
@interface UFMutableURLRequest()

@end

@implementation UFMutableURLRequest

- (instancetype)initUFMutableURLRequestWithURL:(NSURL *)url httpMethod:(NSString *)method timeout:(NSTimeInterval)time headers:(NSArray *)header httpBody:(NSData *)bodyData
{
    self = [super initWithURL:url];
    if (!self) {
        return nil;
    }
    
    self.HTTPMethod = method;
    self.timeoutInterval = time;
    for (NSArray *item in header) {
        [self addValue:item[1] forHTTPHeaderField:item[0]];
    }
    [self addValue:[NSString stringWithFormat:@"UFile iOS/%@",KUFileSDKVersion] forHTTPHeaderField:@"UserAgent"];
    [self setHTTPBody:bodyData];
    
    return self;
}

- (instancetype)initUFMutableURLRequestWithBaseUrl:(NSString *)baseUrlStr httpMethod:(NSString *)method timeout:(NSTimeInterval)time privateKey:(NSString *)privateKey paramsDict:(NSDictionary *)paramDict
{
    NSString *signature  = [UFTools createSignature:paramDict privateKey:privateKey];
    NSString *urlStr = baseUrlStr;
    
    NSArray *keyArray  = [paramDict allKeys];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *keys = [keyArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor,nil]];
    for (int i = 0 ; i < keys.count; i++) {
        if (i == 0) {
            urlStr = [urlStr stringByAppendingString:@"?"];
        }else{
            urlStr = [urlStr stringByAppendingString:@"&"];
        }
        
        urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@=",keys[i]]];
        urlStr = [urlStr stringByAppendingString:paramDict[keys[i]]];
    }
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&Signature=%@",signature]];
    urlStr = [UFTools urlEncode:urlStr];
    self = [super initWithURL:[NSURL URLWithString:urlStr]];
    if (!self) {
        return nil;
    }
    self.HTTPMethod = method;
    self.timeoutInterval = time;
    return self;
}

@end
