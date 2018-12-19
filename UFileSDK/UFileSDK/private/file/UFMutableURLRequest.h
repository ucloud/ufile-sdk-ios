//
//  UFMutableURLRequest.h
//  UFileSDK
//
//  Created by ethan on 2018/11/13.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface UFMutableURLRequest : NSMutableURLRequest

- (instancetype)initUFMutableURLRequestWithURL:(NSURL *)url httpMethod:(NSString *)method timeout:(NSTimeInterval)time headers:(NSArray *)header httpBody:(NSData *)bodyData;

- (instancetype)initUFMutableURLRequestWithBaseUrl:(NSString *)baseUrlStr httpMethod:(NSString *)method timeout:(NSTimeInterval)time privateKey:(NSString *)privateKey paramsDict:(NSDictionary *)paramDict;
@end

NS_ASSUME_NONNULL_END
