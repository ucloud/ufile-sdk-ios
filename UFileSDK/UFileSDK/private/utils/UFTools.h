//
//  UFTools.h
//  UFileSDK
//
//  Created by ethan on 2018/11/2.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UFTools : NSObject


+ (NSString*)convertDataToMD5:(NSData *)data;
+ (NSString *)hmacSha1:(NSString *) key data:(NSString *) data;
+ (NSString*)encodeFromBuf:(const unsigned char *) buf;

+ (NSString *)calcEtagForData:(NSData *)contentData;
//+ (NSString *)getMimeTypeWithFileName:(NSString *)fileName;

+ (NSString *)createSignature:(NSDictionary *)dict privateKey:(NSString *)privateKey;

#pragma mark- 处理字符串
+ (BOOL)uf_isEmpty:(NSString *)str;

#pragma mark- URL编码
+(NSString*)urlEncode:(NSString *)connection_url;
@end

NS_ASSUME_NONNULL_END
