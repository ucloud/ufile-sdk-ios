//
//  UFTools.m
//  UFileSDK
//
//  Created by ethan on 2018/11/2.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>
//#import <CoreServices/CoreServices.h>

#define CC_MD5_DIGEST_LENGTH    16          /* digest length in bytes */
#define UF_DEVICE_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

uint8_t * INT2LE(uint8_t data)
{
    uint8_t *b = (uint8_t *)malloc(sizeof(data));
    b[0] = data;
    b[1] = ((data >> 8) & 0xFF);
    b[2] = ((data >> 16) & 0xFF);
    b[3] = ((data >> 24) & 0xFF);
    return b;
}

//static inline NSString * UFContentTypeForPathExtension(NSString *extension) {
//    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
//    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
//    if (!contentType) {
//        return @"application/octet-stream";
//    } else {
//        return contentType;
//    }
//}

@implementation UFTools
+ (NSString*)convertDataToMD5:(NSData *)data
{
    const char* original_str = (const char *)[data bytes];
    NSUInteger len = [data length];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (uint)len, digest);
    return [self encodeFromBuf:digest];
}

+ (NSString *)hmacSha1:(NSString *) key data:(NSString *) data
{
    const void *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    //    const void *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    const void *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    //sha1
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
    return hash;
}

+ (NSString*) encodeFromBuf:(const unsigned char *) buf
{
    NSMutableString* res = [NSMutableString stringWithCapacity:32];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [res appendFormat:@"%02x",buf[i]];
    }
    return res;
}

+ (NSString *)calcEtagForData:(NSData *)contentData
{
//    NSFileManager *manager  = [NSFileManager defaultManager];
//    int size = 0;
//    if ([manager fileExistsAtPath:path]) {
//        size = [[manager attributesOfItemAtPath:path error:nil] fileSize];
//    }
//    if (size == 0) {
//        return NULL;
//    }
    NSUInteger size  = contentData.length;
    
    int ref_4m_size_byte = 2<<21;  // 定义参照大小4M
    int count_4m_block = size/ref_4m_size_byte;
    if (size%ref_4m_size_byte != 0) {
        count_4m_block++;
    }
    
    if (size <= ref_4m_size_byte) {
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(contentData.bytes, (unsigned int)contentData.length, digest);
        uint8_t *count_4m_data = INT2LE(count_4m_block);
        
        uint8_t etagData[CC_SHA1_DIGEST_LENGTH + sizeof(count_4m_block)] = {0};
        memcpy(etagData, count_4m_data, sizeof(count_4m_block));
        memcpy(etagData+sizeof(count_4m_block), digest, CC_SHA1_DIGEST_LENGTH);
        int etagDataLen = CC_SHA1_DIGEST_LENGTH + sizeof(count_4m_block);
        
        NSString *etag = [self encode:etagData length:etagDataLen];
        return etag;
    }else{
        
        int etagDataLen = CC_SHA1_DIGEST_LENGTH + sizeof(count_4m_block);
        uint8_t *etagData = (uint8_t *)malloc(etagDataLen);
        memset(etagData, 0, etagDataLen);
        uint8_t *count_4m_data = INT2LE(count_4m_block);
        memcpy(etagData, count_4m_data, sizeof(count_4m_block));
        
        int sha1DataLen = CC_SHA1_DIGEST_LENGTH * count_4m_block;
        uint8_t *sha1Data = (uint8_t *)malloc(sha1DataLen);
        memset(sha1Data, 0, sha1DataLen);
        for (int i = 0; i < count_4m_block; i++) {
            uint8_t digest[CC_SHA1_DIGEST_LENGTH];
            uint8_t *data  = (uint8_t *)contentData.bytes + i*ref_4m_size_byte;
            unsigned int len = ref_4m_size_byte;
            if (i == count_4m_block-1) {
                len = size - (count_4m_block-1)*ref_4m_size_byte;
            }
            CC_SHA1(data, len, digest);
            memcpy(sha1Data + i*CC_SHA1_DIGEST_LENGTH, digest, CC_SHA1_DIGEST_LENGTH);
        }
        
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(sha1Data, sha1DataLen, digest);
        memcpy(etagData+ sizeof(count_4m_block), digest, CC_SHA1_DIGEST_LENGTH);
        free(sha1Data);
        NSString *etag = [self encode:etagData length:etagDataLen];
        free(etagData);
        return etag;
    }
}

+ (NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=";
    
    NSMutableData * data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t * output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}
//
//+ (NSString *)getMimeTypeWithFileName:(NSString *)fileName
//{
//    NSRange poingRange  = [fileName rangeOfString:@"."];
//    NSString *fileSuffix = [fileName substringFromIndex:(poingRange.location+1)];
//    return UFContentTypeForPathExtension(fileSuffix);
//}


#pragma mark- manager bucket
+ (NSString *)createSignature:(NSDictionary *)dict privateKey:(NSString *)privateKey
{
    NSMutableString *mutableStr = [NSMutableString string];
    NSArray *keyArray  = [dict allKeys];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *keys = [keyArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor,nil]];
    
    for (NSString *key in keys) {
        [mutableStr appendString:[NSString stringWithFormat:@"%@%@",key,dict[key]]];
    }
    [mutableStr appendString:privateKey];
    
    
    NSString *test = mutableStr;
    const char *cstr = [test cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:test.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (int)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}


#pragma mark- 处理字符串
+ (BOOL)uf_isEmpty:(NSString *)str
{
    return [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

#pragma mark- URL编码
+(NSString*)urlEncode:(NSString *)connection_url{
    if(connection_url == NULL || [connection_url length] == 0){
        return connection_url;
    }
    int index = 0;
    NSUInteger size = [connection_url length];
    NSMutableString* encodedSting = [[NSMutableString alloc] initWithCapacity:size];
    char c;
    for(;index <size ;index++){
        c =[connection_url characterAtIndex:index];
        if (
            (c >= ',' && c <= ';')
            || (c >= 'A' && c <= 'Z')
            || (c >= 'a' && c <= 'z')
            || c == '_'
            || c == '?'
            || c == '&'
            || c == '=') {
            [encodedSting appendFormat:@"%c",c];
        } else {
            [encodedSting appendString:@"%"];
            int x = (int)c;
            [encodedSting appendFormat:@"%02x", x];
        }
    }
    return encodedSting;
}

#pragma mark- 清洗ResumeData数据
+ (NSData *)cleanResumeData:(NSData *)resumeData {
    if (UF_DEVICE_VERSION >= 11.0f && UF_DEVICE_VERSION < 11.2f) {
        // fix iOS11 bug
        NSString *dataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
        if ([dataString containsString:@"<key>NSURLSessionResumeByteRange</key>"]) {
            NSRange rangeKey = [dataString rangeOfString:@"<key>NSURLSessionResumeByteRange</key>"];
            NSString *headStr = [dataString substringToIndex:rangeKey.location];
            NSString *backStr = [dataString substringFromIndex:rangeKey.location];
            
            NSRange rangeValue = [backStr rangeOfString:@"</string>\n\t"];
            NSString *tailStr = [backStr substringFromIndex:rangeValue.location + rangeValue.length];
            dataString = [headStr stringByAppendingString:tailStr];
        }
        return [dataString dataUsingEncoding:NSUTF8StringEncoding];
    }
    return resumeData;
}

#pragma mark- App 包名
+(NSString*)appBundleIdentifier{
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"%@.UFileBGDownloader", bundleId];
}
@end
