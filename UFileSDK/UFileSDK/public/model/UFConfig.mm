//
//  UFConfig.m
//  UFileSDK
//
//  Created by ethan on 2018/11/6.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFConfig.h"
#import "UFTools.h"
#include "UFileSDKConst.h"
#include "log4cplus_ufile.h"

@implementation UFConfig
- (instancetype)initConfigWithPrivateToken:(NSString *)privateToken
                       publicToken:(NSString *)publicToken
                            bucket:(NSString *)bucket
          fileOperateEncryptServer:(NSString *)fileOperateEncryptServer
          fileAddressEncryptServer:(NSString *)fileAddressEncryptServer
                       proxySuffix:(NSString *)proxySuffix
{
    self  = [super init];
    if (!self) {
        return nil;
    }
    if (privateToken) {
        _privateToken = privateToken;
    }
    if (publicToken) {
        _publicToken = publicToken;
    }
    if (bucket) {
        _bucket = bucket;
    }
    if (fileOperateEncryptServer) {
        _fileOperateEncryptServer = fileOperateEncryptServer;
    }
    if (fileAddressEncryptServer) {
        _fileAddressEncryptServer = fileAddressEncryptServer;
    }
    if (proxySuffix) {
        _proxySuffix = proxySuffix;
    }
    NSString *urlstr  = [NSString stringWithFormat:@"http://%@", self.proxySuffix];
    NSArray *arr  = [urlstr componentsSeparatedByString:@"://"];
    [NSString stringWithFormat:@"%@://%@.%@", arr[0], self.bucket, arr[1]];
    _baseURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://%@.%@", arr[0], self.bucket, arr[1]] ];
    return self;
}

+ (instancetype)instanceConfigWithPrivateToken:(NSString * _Nullable)privateToken
                                   publicToken:(NSString * _Nonnull)publicToken
                                        bucket:(NSString * _Nonnull)bucket
                      fileOperateEncryptServer:(NSString * _Nullable)fileOperateEncryptServer
                      fileAddressEncryptServer:(NSString * _Nullable)fileAddressEncryptServer
                                   proxySuffix:(NSString * _Nonnull)proxySuffix
{
    return[[self alloc] initConfigWithPrivateToken:privateToken publicToken:publicToken bucket:bucket fileOperateEncryptServer:fileOperateEncryptServer fileAddressEncryptServer:fileAddressEncryptServer proxySuffix:proxySuffix];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"privateToken:%@ , publicToken:%@ , bucket:%@ , fileOperateEncryptServer:%@ , fileAddressEncryptServer:%@ , proxySuffix:%@ , baseURL:%@",self.privateToken,self.publicToken,self.bucket,self.fileOperateEncryptServer,self.fileAddressEncryptServer,self.proxySuffix,self.baseURL];
}

- (id)signatureForFileOperationWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType  callBack:(NSDictionary * __nullable)policy
{
    if (self.fileOperateEncryptServer == nil || [UFTools uf_isEmpty:self.fileOperateEncryptServer]) {
        return [self localSignatureWithHttpMethod:httpMethod key:keyName md5Data:contentMd5 contentType:contentType callBack:policy];
    }
    return [self serverSignatureWithHttpMethod:httpMethod key:keyName md5Data:contentMd5 contentType:contentType callBack:policy];
}

- (id)doSyncHttpRequestGetSignature:(NSMutableURLRequest *)request params:(NSDictionary *)paramsDict
{
    NSString * paramJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramsDict options:0 error:nil] encoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [paramJson dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    __block NSString* strRes = nil;
    //4.task
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse* httpResponse =  (NSHTTPURLResponse*)response;
        if (httpResponse && httpResponse.statusCode == 200 && data) {
            strRes = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            strRes = [strRes stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        dispatch_semaphore_signal(semaphore);   //发送信号
    }];
    
    [task resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    if (strRes) {
        return strRes;
    }
    log4cplus_warn("UFileSDK", "server signature, signature result is nil..\n");
    UFError *ufError  = [UFError sysErrorWithInvalidArgument:@"server signature, signature is nil"];
    return ufError;
}

- (id)serverSignatureWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5
                                contentType:(NSString *)contentType
                                   callBack:(NSDictionary * __nullable)policy
{
    NSMutableDictionary *mutaDict = [NSMutableDictionary dictionary];
    if (httpMethod) {
        [mutaDict setObject:httpMethod forKey:@"method"];
    }
    if (self.bucket) {
        [mutaDict setObject:self.bucket forKey:@"bucket"];
    }
    if (keyName) {
        [mutaDict setObject:keyName forKey:@"key"];
    }
    if (contentMd5) {
        [mutaDict setObject:contentMd5 forKey:@"content_md5"];
    }
    if (contentType) {
        [mutaDict setObject:contentType forKey:@"content_type"];
    }
    NSString *callBackPolicy = nil;
    if (policy) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:policy options:NSJSONWritingPrettyPrinted error:&error];
        NSString* policy = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        if (!error && jsonData) {
            callBackPolicy = [self stringFromResult: (void*)policy.UTF8String Len:policy.length];
        }
        if (callBackPolicy) {
            [mutaDict setObject:callBackPolicy forKey:@"put_policy"];
        }
    }
    NSURL *url = [NSURL URLWithString:self.fileOperateEncryptServer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    return [self doSyncHttpRequestGetSignature:request params:mutaDict];
}

- (id)localSignatureWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType
                                  callBack:(NSDictionary * __nullable)policy
{
    
    if (self.privateToken == nil || [UFTools uf_isEmpty:self.privateToken]) {
        log4cplus_warn("UFileSDK", "local signature,private token is nil..\n");
        UFError *ufError  = [UFError sysErrorWithInvalidArgument:@"local signature,private token is nil"];
        return ufError;
    }
    NSString *key  = [keyName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *sigStr  = [NSMutableString stringWithFormat:@"%@\n",httpMethod];
    [sigStr appendFormat:@"%@\n", contentMd5];
    [sigStr appendFormat:@"%@\n", contentType];
    [sigStr appendFormat:@"%@\n", @""];
    [sigStr appendFormat:@"/%@/%@", self.bucket, key];
    NSMutableString *strBase64 = [NSMutableString string];
    if (policy) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:policy options:NSJSONWritingPrettyPrinted error:nil];
        NSString *polocy_str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData *data = [polocy_str dataUsingEncoding:NSUTF8StringEncoding];
        strBase64 = [NSMutableString stringWithString:[data base64Encoding]];
        [sigStr appendFormat:@"%@", strBase64];
    }
    NSString *HmacSHA1str = [UFTools hmacSha1:self.privateToken data:sigStr];
    NSMutableString* signedStr = [NSMutableString stringWithFormat:@"UCloud %@:%@", self.publicToken, HmacSHA1str];
    if (strBase64 && strBase64.length > 0) {
        signedStr = [NSMutableString stringWithFormat:@"UCloud %@:%@:%@", self.publicToken, HmacSHA1str,strBase64];
    }
    return signedStr;
}

-(NSString*)stringFromResult:(void*)result Len:(NSInteger)length
{
    NSData* data = [[NSData alloc] initWithBytes:result length:length];
    return [data base64EncodedStringWithOptions:0];
}

- (id)serverSignatureForGetFileUrlWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType expiresTime:(NSString *)expiresTime
{
    NSMutableDictionary *mutaDict = [NSMutableDictionary dictionary];
    if (self.bucket) {
        [mutaDict setObject:self.bucket forKey:@"bucket"];
    }
    if (httpMethod) {
         [mutaDict setObject:httpMethod forKey:@"method"];
    }
    if (keyName) {
        [mutaDict setObject:keyName forKey:@"key"];
    }
    if (expiresTime) {
        [mutaDict setObject:expiresTime forKey:@"expires"];
    }
    NSURL *url = [NSURL URLWithString:self.fileAddressEncryptServer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    return [self doSyncHttpRequestGetSignature:request params:mutaDict];
}

- (id)localSignatureForGetFileUrlWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType expiresTime:(NSString *)expiresTime
{
    if (self.privateToken == nil || [UFTools uf_isEmpty:self.privateToken]) {
        log4cplus_warn("UFileSDK", "local signature, private token is nil..\n");
        UFError *ufError = [UFError sysErrorWithInvalidArgument:@"local signature, private token is nil"];
        return ufError;
    }
    NSString *key  = [keyName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *sigStr  = [NSMutableString stringWithFormat:@"%@\n",httpMethod];
    [sigStr appendFormat:@"%@\n", contentMd5];
    [sigStr appendFormat:@"%@\n", contentType];
    [sigStr appendFormat:@"%@\n", expiresTime];
    [sigStr appendFormat:@"/%@/%@", self.bucket, key];
    NSString *HmacSHA1str = [UFTools hmacSha1:self.privateToken data:sigStr];
    return HmacSHA1str;
}

- (id)signatureForGetFileUrlWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType expiresTime:(NSString *)expiresTime
{
    if (self.fileAddressEncryptServer == nil || [UFTools uf_isEmpty:self.fileAddressEncryptServer]) {
        return [self localSignatureForGetFileUrlWithHttpMethod:httpMethod key:keyName md5Data:contentMd5 contentType:contentType expiresTime:expiresTime];
    }
    return [self serverSignatureForGetFileUrlWithHttpMethod:httpMethod key:keyName md5Data:contentMd5 contentType:contentType expiresTime:expiresTime];
}

@end
