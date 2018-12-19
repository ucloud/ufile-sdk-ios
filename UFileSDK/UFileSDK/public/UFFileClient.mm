//
//  UFFileClient.m
//  UFileSDK
//
//  Created by ethan on 2018/11/1.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFFileClient.h"
#import "UFURLSessionManager.h"
#import "UFTools.h"
#include "UFileSDKConst.h"
#include "log4cplus_ufile.h"
#import "UFMutableURLRequest.h"
#import "UFErrorModel.h"

typedef void (^UFFileOperationHandler)(id _Nullable obj1,id _Nullable obj2);

typedef enum UFHttpResponseType
{
    UFHttpResponseTypeError = 0,
    UFHttpResponseTypeUpload,
    UFHttpResponseTypeDownload,
    UFHttpResponseTypeMultiPartInfo,
    UFHttpResponseTypeFinishMultipartUpload,
    UFHttpResponseTypeQueryFile,
    UFHttpResponseTypePrefixFileList,
    UFHttpResponseTypeHeadFile,
}UFHttpResponseType;

static NSString *mime(NSString *mimeType) {
    if (mimeType == nil || [UFTools uf_isEmpty:mimeType]) {
        return @"application/octet-stream";
    }
    return mimeType;
}

NSString * UFilePercentEscapedStringFromString(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@?/"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];

    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
}

@interface UFFileClient()

@property (nonatomic,strong) UFURLSessionManager *localSessionManager;
@property (nonatomic,strong) UFConfig  *ufConfig;

@end

@implementation UFFileClient

- (instancetype)initFileClientWithConfig:(UFConfig *)ufConfig
{
    self  = [super init];
    if (!self) {
        return nil;
    }
    if (ufConfig) {
        self.ufConfig =  ufConfig;
    }
    return self;
}

+ (instancetype)instanceFileClientWithConfig:(UFConfig *)ufConfig
{
    return [[self alloc] initFileClientWithConfig:ufConfig];
}

- (void)setTimeoutIntervalForRequest:(NSTimeInterval)timeoutIntervalForRequest
{
    if (timeoutIntervalForRequest <= 0) {
        self.timeoutIntervalForRequest = 60 ;
        return;
    }
    
    self.timeoutIntervalForRequest = timeoutIntervalForRequest;
}

- (UFURLSessionManager *)localSessionManager
{
    if (!_localSessionManager) {
        _localSessionManager = [[UFURLSessionManager alloc] init];
    }
    return _localSessionManager;
}

- (NSArray *)constructHeadersForType:(UFHttpResponseType)type author:(NSString *)authorization options:(NSDictionary *)options length:(NSUInteger)length
{
    NSMutableArray * headers = [NSMutableArray new];
    [headers addObject:@[@"Authorization", authorization]];
    switch (type) {
        case UFHttpResponseTypeUpload:
            {
                [headers addObjectsFromArray:@[@[@"Content-Length", [NSString stringWithFormat:@"%lu", (unsigned long)length]]]];
                if (options) {
                    if (options[kUFileSDKOptionFileType]) {
                        [headers addObject:@[@"Content-Type", options[kUFileSDKOptionFileType]]];
                    }
                    if (options[kUFileSDKOptionMD5]) {
                        [headers addObject:@[@"Content-MD5", options[kUFileSDKOptionMD5]]];
                    }
                }
            }
            break;
        case UFHttpResponseTypeDownload:
        {
            if (options) {
                if (options[kUFileSDKOptionRange]) {
                    [headers addObject:@[@"Range", [@"bytes=" stringByAppendingString:options[kUFileSDKOptionRange]]]];
                }
                if (options[kUFileSDKOptionModifiedSince]) {
                    [headers addObject:@[@"If-Modified-Since", options[kUFileSDKOptionModifiedSince]]];
                }
            }
        }
            break;
        case UFHttpResponseTypePrefixFileList:
        {
            if (options) {
                if (options[@"prefix"]) {
                    [headers addObject:@[@"prefix",options[@"prefix"]]];
                }
                if (options[@"marker"]) {
                    [headers addObject:@[@"marker",options[@"marker"]]];
                }
                if (options[@"limit"]) {
                    [headers addObject:@[@"limit",options[@"limit"]]];
                }
            }
        }
            break;
            
    }
     return headers;
}

- (NSURL*)fileUrl:(NSString*)fileName params:(NSDictionary*)params
{
    NSMutableString* url = [NSMutableString stringWithString:UFilePercentEscapedStringFromString(fileName)];
    
    if (params != nil) {
        [url appendString:@"?"];
        BOOL first = YES;
        for (NSString* key in params) {
            if (first != YES) {
                [url appendString:@"&"];
            }
            first = NO;
            NSString* value = [params objectForKey:key];
            if (value.length == 0) {
                [url appendString:key];
            } else {
                [url appendFormat:@"%@=%@",
                 UFilePercentEscapedStringFromString(key),
                 UFilePercentEscapedStringFromString(value)];
            }
        }
    }
    return [NSURL URLWithString:url relativeToURL:self.ufConfig.baseURL];
}

- (nullable id)constructHttpResponseObject:(UFHttpResponseType)httpResponseType
                                  response:(NSURLResponse *)response
                                      body:(NSData *)body
                                  filePath:(NSURL *)filePath
                                   handler:(UFFileOperationHandler _Nonnull)handler
{
    NSHTTPURLResponse* resp = (NSHTTPURLResponse*)response;
    switch (httpResponseType) {
        case UFHttpResponseTypeError:
        {
            UFFileClientError *httpError = nil;
            if (resp.statusCode/100 != 2) {
                NSError * jsonErr = nil;
                id respObj = nil;
                if (body) {
                    respObj = [NSJSONSerialization JSONObjectWithData:body options:0 error:&jsonErr];
                }
                if (![respObj isKindOfClass:[NSDictionary class]] ||
                    !respObj[kUFileRespRetCode] ||
                    ![respObj[kUFileRespRetCode] isKindOfClass:[NSNumber class]]){
                    
                    NSString *xsessionID = nil;
                    if (resp.allHeaderFields[kUFileRespXSession]) {
                        xsessionID = resp.allHeaderFields[kUFileRespXSession];
                    }
                    httpError= [UFFileClientError initUFHttpErrorWithSession:xsessionID statusCode:resp.statusCode retCode:-1 errMsg:nil];
                }
                else
                {
                    httpError = [UFFileClientError initUFHttpErrorWithSession:resp.allHeaderFields[kUFileRespXSession]
                                                             statusCode:resp.statusCode
                                                                retCode:[respObj[kUFileRespRetCode] integerValue]
                                                                 errMsg:respObj[kUFileRespErrMsg]];
                }
            }
            return httpError;
        }
            break;
        case UFHttpResponseTypeUpload:
        {
            UFUploadResponse *uploadResponse = nil;
            NSUInteger partNumber  = 0;
            NSError *jsonError = nil;
            if (body) {
                id respId = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableLeaves error:&jsonError];
                if (respId && jsonError) {
                    log4cplus_warn("UFileSDK", "JSON parsing error, error info :%s",[jsonError.description UTF8String]);
                    handler([UFError sysErrorWithError:jsonError],nil);
                    return nil;
                }
                if ([respId isKindOfClass:[NSDictionary class]]) {
                    partNumber = [respId[KUFileRespPartNumber] unsignedIntegerValue];
                }
            }
            uploadResponse = [UFUploadResponse instanceWithStatusCode:resp.statusCode etag:resp.allHeaderFields[kUFileRespHeaderEtag] partNumber:partNumber];
            return uploadResponse;
        }
            break;
        case UFHttpResponseTypeDownload:
        {
            return [UFDownloadResponse instanceWithStatusCode:resp.statusCode etag:resp.allHeaderFields[kUFileRespHeaderEtag] data:body destPath:filePath.absoluteString];
        }
            break;
        case UFHttpResponseTypeMultiPartInfo:
        {
            UFMultiPartInfo *multiPartInfo = nil;
            NSDictionary *resDict = nil;
            //  && [NSJSONSerialization isValidJSONObject:body]   // 服务器返回数据校验时出错
            if (body) {
                NSError * jsonError = nil;
                resDict = [NSJSONSerialization JSONObjectWithData:body options:0 error:&jsonError];
                if (resDict && jsonError) {
                    log4cplus_warn("UFileSDK", "JSON parsing error, error info :%s",[jsonError.description UTF8String]);
                    handler([UFError sysErrorWithError:jsonError],nil);
                    return nil;
                }
            }
            multiPartInfo = [UFMultiPartInfo ufMultiPartInfoWithDict:resDict];
            return multiPartInfo;
        }
            break;
        case UFHttpResponseTypeFinishMultipartUpload:
        {
            UFFinishMultipartUploadResponse *finishMultipartUploadResponse = nil;
            NSDictionary * respObj = nil;
            if (body) {
                NSError *jsonErr = nil;
                respObj = [NSJSONSerialization JSONObjectWithData:body options:0 error:&jsonErr];
                if (respObj && jsonErr) {
                    log4cplus_warn("UFileSDK", "JSON parsing error, error info :%s",[jsonErr.description UTF8String]);
                    handler([UFError sysErrorWithError:jsonErr],nil);
                    return nil;
                }
            }
            finishMultipartUploadResponse = [UFFinishMultipartUploadResponse instanceWithStatusCode:resp.statusCode
                                                                      etag:resp.allHeaderFields[kUFileRespHeaderEtag]
                                                                    bucket:respObj[KBucket]
                                                                       key:respObj[KKey]
                                                                  fileSize:[respObj[KUFileRespFileSize] unsignedIntegerValue] ];
            return finishMultipartUploadResponse;
        }
            break;
        case UFHttpResponseTypeQueryFile:
        {
            NSString *contentLen_str = resp.allHeaderFields[KUFHeadFileContentLength];
            return [UFQueryFileResponse instanceWithStatusCode:resp.statusCode
                                                          etag:resp.allHeaderFields[kUFileRespHeaderEtag]
                                                   contentType:resp.allHeaderFields[KUFHeadFileContentType]
                                                 contentLength:[contentLen_str integerValue]];
        }
            break;
        case UFHttpResponseTypePrefixFileList:
        {
            UFPrefixFileList *prefixFileList = nil;
            if (resp.statusCode == 200 && body) {
                NSError *jsonErr = nil;
                NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:body options:0 error:&jsonErr];
                if (resDict && jsonErr) {
                    log4cplus_warn("UFileSDK", "JSON parsing error, error info :%s",[jsonErr.description UTF8String]);
                    handler([UFError sysErrorWithError:jsonErr],nil);
                    return nil;
                }
                if ([resDict objectForKey:@"BucketName"]) {
                    prefixFileList = [UFPrefixFileList ufPrefixFileListResponseWithDict:resDict];
                }
            }
            return prefixFileList;
        }
            break;
        case UFHttpResponseTypeHeadFile:
        {
            NSHTTPURLResponse* resp = (NSHTTPURLResponse*)response;
            NSString *contentLen_str = resp.allHeaderFields[KUFHeadFileContentLength];
            return [UFHeadFile instanceWithStatusCode:resp.statusCode
                                                 etag:resp.allHeaderFields[kUFileRespHeaderEtag]
                                          contentType:resp.allHeaderFields[KUFHeadFileContentType]
                                        contentLength:[contentLen_str integerValue]
                                         contentRange:resp.allHeaderFields[KUFHeadFileContentRange]];
        }
            break;
            
        default:
            log4cplus_warn("UFileSDK", "unknown UFHttpResponseType");
            break;
    }
    return nil;
}

#pragma mark- 错误处理
- (BOOL)processingHttpResponseError:(NSError *)error
                           response:(NSURLResponse *)response
                               body:(NSData *)body
                            handler:(UFFileOperationHandler _Nonnull)handler
{
    if (error) {
        log4cplus_warn("UFileSDK", "http response error , error info-->%s",[error.description UTF8String]);
        handler([UFError sysErrorWithError:error],nil);
        return YES;
    }
    UFFileClientError * httpError = [self constructHttpResponseObject:UFHttpResponseTypeError response:response body:body filePath:nil handler:handler];
    if (httpError) {
        log4cplus_info("UFileSDK", "file opeartion failed , server response error info-->%s",[httpError.errMsg UTF8String]);
        handler([UFError httpErrorWithFileClientError:httpError],nil);
        return YES;
    }
    return NO;
}

#pragma mark- 校验参数
+ (BOOL)checkParametersAndNotify:(NSString *)keyName input:(NSObject *)input isCheck:(BOOL)checkInput  handler:(UFFileOperationHandler _Nonnull)handler
{
    if (handler == nil) {
        log4cplus_warn("UFileSDK", "argument error , file operation callback is nil..\n");
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"no fileOperationHandler"
                                     userInfo:nil];
        return YES;
    }
    NSString *errorDesc = nil;
    if (!keyName || [UFTools uf_isEmpty:keyName]) {
        errorDesc = @"no keyName";
    }else if(checkInput && !input){
        errorDesc = @"no input data";
    }
    if (errorDesc != nil) {
        log4cplus_warn("UFileSDK", "argument error , error info-->%s",[errorDesc UTF8String]);
        handler([UFError sysErrorWithInvalidArgument:errorDesc],nil);
        return YES;
    }
    return NO;
}

#pragma mark- 文件上传
- (void)uploadWithKeyName:(NSString * _Nonnull)keyName
                 filePath:(NSString * _Nonnull)filePath
                 mimeType:(NSString * _Nullable)mimeType
                 progress:(UFProgress)uploadProgress
            uploadHandler:(UFUploadHandler _Nonnull)handler
{
    NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
    [self uploadWithKeyName:keyName fileData:contentData mimeType:mimeType progress:uploadProgress uploadHandler:handler];
}

- (void)uploadWithKeyName:(NSString * _Nonnull)keyName
                 fileData:(NSData * _Nonnull)data
                 mimeType:(NSString * _Nullable)mimeType
                 progress:(UFProgress)uploadProgress
            uploadHandler:(UFUploadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:data isCheck:YES handler:handler]) {
        return;
    }
    mimeType = mime(mimeType);
    NSString *contentMD5  = [UFTools convertDataToMD5:data];
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"PUT" key:keyName md5Data:contentMD5 contentType:mimeType callBack:nil];
    NSURL *url = [self fileUrl:keyName params:nil];
    UFMutableURLRequest *request = NULL;
    @try {
        NSDictionary * option = @{kUFileSDKOptionFileType:mimeType, kUFileSDKOptionMD5: contentMD5,kUFileSDKOptionTimeoutInterval:[NSNumber numberWithFloat:10.0]};
        NSArray *headers = [self constructHeadersForType:UFHttpResponseTypeUpload author:strAuth options:option length:[data length]];
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"PUT" timeout:self.timeoutIntervalForRequest headers:headers httpBody:data];
    } @catch (NSException *exception) {
        log4cplus_warn("UFSDK_Upload", "upload error , error info %s\n",[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    NSURLSessionUploadTask *task = [self.localSessionManager uploadTaskWithRequest:request fromFile:nil progress:NULL completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFUploadResponse *uploadResponse = [self constructHttpResponseObject:UFHttpResponseTypeUpload response:response body:responseObject filePath:nil handler:handler];
        if (uploadResponse) {
            log4cplus_info("UFSDK_Upload", "upload succ , server response info-->%s\n",[uploadResponse.description UTF8String]);
            handler(nil,uploadResponse);
        }
    }];
    [task resume];
}

#pragma mark- 极速上传
- (void)hitUploadWithKeyName:(NSString * _Nonnull)keyName
                    filePath:(NSString *)filePath
                    mimeType:(NSString * _Nullable)mimeType
               uploadHandler:(UFUploadHandler _Nonnull)handler
{
    NSData *contentData = [[NSData alloc] initWithContentsOfFile:filePath];
    [self hitUploadWithKeyName:keyName fileData:contentData mimeType:mimeType uploadHandler:handler];
}

- (void)hitUploadWithKeyName:(NSString * _Nonnull)keyName
                    fileData:(NSData * _Nonnull)data
                    mimeType:(NSString * _Nullable)mimeType
               uploadHandler:(UFUploadHandler _Nonnull)handler
{
    NSData *contentData = data;
    if ([UFFileClient checkParametersAndNotify:keyName input:data isCheck:YES handler:handler]) {
        return;
    }
    int fileSize  = (int)contentData.length;
    mimeType = mime(mimeType);
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"POST" key:keyName md5Data:@"" contentType:mimeType callBack:nil];
    NSString *etag = [UFTools calcEtagForData:contentData];
    NSURL *url = [self fileUrl:@"uploadhit" params:@{@"Hash":etag, @"FileName":keyName, @"FileSize":[@(fileSize) stringValue]}];
    UFMutableURLRequest *request = NULL;
    @try {
        NSArray* headers = @[@[@"Authorization",strAuth],@[@"Content-Type", mimeType]];
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"POST" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    } @catch (NSException *exception) {
        log4cplus_warn("UFSDK_Upload_Fast", "upload error , error info %s\n",[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFUploadResponse *uploadResponse = [self constructHttpResponseObject:UFHttpResponseTypeUpload response:response body:responseObject filePath:nil handler:handler];
        if (uploadResponse) {
            log4cplus_info("UFSDK_Upload_Fast", "upload succ , server response info-->%s\n",[uploadResponse.description UTF8String]);
            handler(nil,uploadResponse);
        }
    }];
    [dataTask resume];
}

#pragma mark- 分片上传
- (void)prepareMultipartUploadWithKeyName:(NSString * _Nonnull)keyName
                                 mimeType:(NSString * _Nullable)mimeType
            prepareMultiPartUploadHandler:(UFPrepareMultiPartUploadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:nil isCheck:NO handler:handler]) {
        return;
    }
    mimeType = mime(mimeType);
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"POST" key:keyName md5Data:@"" contentType:mimeType callBack:nil];
    NSURL *url = [self fileUrl:keyName params:@{@"uploads": @""}];
    UFMutableURLRequest *request = NULL;
    try {
        NSArray* headers = @[@[@"Authorization", strAuth],@[@"Content-Type", mimeType]];
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"POST" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    } catch (NSException *exception) {
        log4cplus_warn("UFSDK_MultipartUpload", "%s , error info %s\n",__func__,[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFMultiPartInfo *multiPartInfo = [self constructHttpResponseObject:UFHttpResponseTypeMultiPartInfo response:response body:responseObject filePath:nil handler:handler];
        if (multiPartInfo) {
            log4cplus_info("UFSDK_MultipartUpload", "prepare multipart upload succ , server response info-->%s\n",[multiPartInfo.description UTF8String]);
            handler(nil,multiPartInfo);
        }
        
    }];
    [dataTask resume];
}

- (void)startMultipartUploadWithKeyName:(NSString * _Nonnull)keyName
                               mimeType:(NSString * _Nullable)mimeType
                               uploadId:(NSString * _Nonnull)upId
                              partIndex:(NSInteger)partIndex
                               fileData:(NSData * _Nonnull)data
                               progress:(UFProgress _Nonnull)uploadProgress
                          uploadHandler:(UFUploadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:data isCheck:YES handler:handler]) {
        return;
    }
    if (!upId) {
        log4cplus_warn("UFSDK_MultipartUpload", "%s, uploadId or file data is null..\n",__func__);
        handler([UFError sysErrorWithInvalidArgument:@"no uploadId"],nil);
        return;
    }
    mimeType = mime(mimeType);
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"PUT" key:keyName md5Data:@"" contentType:mimeType callBack:nil];
    NSURL *url = [self fileUrl:keyName params:@{@"uploadId":upId, @"partNumber":[@(partIndex) stringValue]}];
    UFMutableURLRequest *request = NULL;
    try {
        NSArray * headers = @[
                              @[@"Authorization",strAuth],
                              @[@"Content-Length",[NSString stringWithFormat:@"%lu",(unsigned long)[data length]]],
                              @[@"Content-Type", mimeType]
                              ];
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"PUT" timeout:self.timeoutIntervalForRequest headers:headers httpBody:data];
    } catch (NSException *exception) {
        log4cplus_warn("UFSDK_MultipartUpload", "%s , error info %s\n",__func__,[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:uploadProgress downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFUploadResponse *uploadResponse = [self constructHttpResponseObject:UFHttpResponseTypeUpload response:response body:responseObject filePath:nil handler:handler];
        log4cplus_info("UFSDK_MultipartUpload", "start multipart upload succ , server response info-->%s\n",[uploadResponse.description UTF8String]);
        handler(nil,uploadResponse);
        
    }];
    [dataTask resume];
}

- (void)multipartUploadAbortWithKeyName:(NSString * _Nonnull)keyName
                               mimeType:(NSString * _Nullable)mimeType
                               uploadId:(NSString * _Nonnull)upId
                          uploadHandler:(UFUploadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:upId isCheck:YES handler:handler]) {
        return;
    }
    mimeType = mime(mimeType);
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"DELETE" key:keyName md5Data:@"" contentType:mimeType callBack:nil];
    NSURL *url = [self fileUrl:keyName params:@{@"uploadId":upId}];
    UFMutableURLRequest *request = NULL;
    try {
        NSArray * headers = @[
                              @[@"Authorization",strAuth],
                              @[@"Content-Type", mimeType]
                              ];
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"DELETE" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    } catch (NSException *exception) {
        log4cplus_warn("UFSDK_MultipartUpload", "%s , error info %s\n",__func__,[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFUploadResponse *uploadResponse = [self constructHttpResponseObject:UFHttpResponseTypeUpload response:response body:responseObject filePath:nil handler:handler];
        log4cplus_info("UFSDK_MultipartUpload", "abort multipart upload succ , server response info-->%s\n",[uploadResponse.description UTF8String]);
        handler(nil,uploadResponse);
    }];
    [dataTask resume];
}

- (void)multipartUploadFinishWithKeyName:(NSString * _Nonnull)keyName
                                mimeType:(NSString * _Nullable)mimeType
                                uploadId:(NSString * _Nonnull)upId
                              newKeyName:(NSString * _Nullable)newKeyName
                                   etags:(NSArray * _Nonnull)etags
            finishMultipartUploadHandler:(UFFinishMultipartUploadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:upId isCheck:YES handler:handler]) {
        return;
    }
    if (!etags) {
        log4cplus_warn("UFSDK_MultipartUpload", "func:%s , line:%d , file etags is nil..\n",__func__,__LINE__);
        handler([UFError sysErrorWithInvalidArgument:@"no etags"],nil);
        return;
    }
    mimeType = mime(mimeType);
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"POST" key:keyName md5Data:@"" contentType:mimeType callBack:nil];
    NSData *body = [[etags componentsJoinedByString:@","] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *paramDict = newKeyName == NULL ? @{@"uploadId":upId} : @{@"uploadId":upId, @"newKey":newKeyName};
    NSURL *url = [self fileUrl:keyName params:paramDict];
    UFMutableURLRequest *request = NULL;
    try {
        NSArray * headers = @[@[@"Authorization", strAuth],
                              @[@"Content-type", mimeType],
                              @[@"Content-Length", [NSString stringWithFormat:@"%lu", (unsigned long)body.length]]];
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"POST" timeout:self.timeoutIntervalForRequest headers:headers httpBody:body];
    } catch (NSException *exception) {
        log4cplus_warn("UFSDK_MultipartUpload", "%s , error info %s\n",__func__,[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFFinishMultipartUploadResponse *finishMultipartUpRes = [self constructHttpResponseObject:UFHttpResponseTypeFinishMultipartUpload response:response body:responseObject filePath:nil handler:handler];
        if (finishMultipartUpRes) {
            log4cplus_info("UFSDK_MultipartUpload", "finish multipart upload succ , server response info-->%s\n",[finishMultipartUpRes.description UTF8String]);
            handler(nil,finishMultipartUpRes);
        }
        
    }];
    [dataTask resume];
}

#pragma mark- 文件下载
- (void)downloadWithKeyName:(NSString * _Nonnull)keyName
              downloadRange:(UFDownloadFileRange)range
                   progress:(UFProgress _Nullable)downloadProgress
            downloadHandler:(UFDownloadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:NULL isCheck:NO handler:handler]) {
        return;
    }
    
    if (range.begin <0 || range.end < 0) {
        log4cplus_warn("UFSDK_Download", "file range illegal, range(%ld,%ld)",(long)range.begin,(long)range.end);
        handler([UFError sysErrorWithInvalidArgument:@"range invalid"],nil);
        return;
    }
    NSDictionary *option = nil;
    if (range.begin >= 0 && range.end >= 0 && range.end > range.begin) {
        option = @{kUFileSDKOptionRange:[NSString stringWithFormat:@"%ld-%ld",(long)range.begin,(long)range.end]};
    }
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"GET" key:keyName md5Data:nil contentType:nil callBack:nil];
    NSArray *headers  =[self constructHeadersForType:UFHttpResponseTypeDownload author:strAuth options:option length:0];
    headers = nil;  // 私有空间不需要构造headers
//    NSURL *url = [self fileUrl:keyName params:nil];
    NSURL *url = [NSURL URLWithString:[self filePrivateUrlWithKeyName:keyName expiresTime:0]];
    UFMutableURLRequest *request = NULL;
    try {
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"GET" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    } catch (NSException *exception) {
        log4cplus_warn("UFSDK_Download", "download error , error info %s\n",[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    
    NSURLSessionDataTask *task = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFDownloadResponse *downResponse = [self constructHttpResponseObject:UFHttpResponseTypeDownload response:response body:responseObject filePath:nil handler:handler];
        log4cplus_info("UFSDK_Download", "download succ , server response info-->%s\n",[downResponse.description UTF8String]);
        handler(nil,downResponse);
    }];
    [task resume];
}

- (void)downloadWithKeyName:(NSString * _Nonnull)keyName
            destinationPath:(NSString * _Nonnull)path
              downloadRange:(UFDownloadFileRange)range
                   progress:(UFProgress _Nullable)downloadProgress
            downloadHandler:(UFDownloadHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:path isCheck:YES handler:handler]) {
        return;
    }
    
    if (range.begin <0 || range.end < 0) {
        log4cplus_warn("UFSDK_Download_ToPath", "file range illegal, range(%ld,%ld)",(long)range.begin,(long)range.end);
        handler([UFError sysErrorWithInvalidArgument:@"range invalid"],nil);
        return;
    }
    
    NSDictionary *option = nil;
    if (range.begin >= 0 && range.end >= 0 && range.end > range.begin) {
        option = @{kUFileSDKOptionRange:[NSString stringWithFormat:@"%ld-%ld",(long)range.begin,(long)range.end]};
    }
    
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"GET" key:keyName md5Data:nil contentType:nil callBack:nil];
    NSArray *headers  =[self constructHeadersForType:UFHttpResponseTypeDownload author:strAuth options:option length:0];
    headers = nil;
//    NSURL *url = [self fileUrl:keyName params:nil];
    NSURL *url = [NSURL URLWithString:[self filePrivateUrlWithKeyName:keyName expiresTime:0]];
    UFMutableURLRequest *request = NULL;
    try {
        request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"GET" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    } catch (NSException *exception) {
        log4cplus_warn("UFSDK_Download", "upload error , error info %s\n",[exception.description UTF8String]);
        handler([UFError sysErrorWithInvalidElements:@"construct request error"],nil);
        return;
    }
    
    NSURLSessionDownloadTask *task = [self.localSessionManager downloadTaskWithRequest:request destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return  [NSURL fileURLWithPath:path];
    } progress:downloadProgress completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        if ([self processingHttpResponseError:error response:response body:nil handler:handler]) {
            return;
        }
        UFDownloadResponse *downResponse = [self constructHttpResponseObject:UFHttpResponseTypeDownload response:response body:nil filePath:filePath handler:handler];
        log4cplus_info("UFSDK_Download", "download succ , server response info-->%s\n",[downResponse.description UTF8String]);
        handler(nil,downResponse);
    }];
    
    [task resume];
}

#pragma mark- 文件删除
- (void)deleteWithKeyName:(NSString * _Nonnull)keyName deleteHandler:(UFDeleteHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:NULL isCheck:NO handler:handler]) {
        return;
    }
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"DELETE" key:keyName md5Data:@"" contentType:@"" callBack:nil];
    NSURL *url = [self fileUrl:keyName params:nil];
    UFMutableURLRequest *request  = NULL;
    NSArray *headers = @[@[@"Authorization",strAuth]];
    request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"DELETE" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        log4cplus_info("UFSDK_Delete", "delete succ..\n");
        handler(nil,nil);
    }];
    [dataTask resume];
}

#pragma mark- 文件查询
- (void)queryWithKeyName:(NSString * _Nonnull)keyName queryHandler:(UFQueryHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:NULL isCheck:NO handler:handler]) {
        return;
    }
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"HEAD" key:keyName md5Data:@"" contentType:@"" callBack:nil];
    NSURL *url = [self fileUrl:keyName params:nil];
    UFMutableURLRequest *request  = NULL;
    NSArray *headers = @[@[@"Authorization",strAuth]];
    request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"HEAD" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFQueryFileResponse *queryFileResp = [self constructHttpResponseObject:UFHttpResponseTypeQueryFile response:response body:responseObject filePath:nil handler:handler];
        if (queryFileResp) {
            log4cplus_info("UFSDK_Query", "query  succ , server response info-->%s\n",[queryFileResp.description UTF8String]);
            handler(nil,queryFileResp);
        }
    }];
    [dataTask resume];
}

#pragma mark- get file list
- (void)prefixFileListWithPrefix:(NSString * _Nullable)prefix
                          marker:(NSString * _Nullable)marker
                           limit:(NSInteger)limit
           prefixFileListHandler:(UFPrefixFileListHandler _Nonnull)handler
{
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"GET" key:@"" md5Data:@"" contentType:@"" callBack:nil];
    if (limit <= 0) {
        limit = 20;
    }
    if (!prefix) {
        prefix = @"";
    }
    if (!marker) {
        marker = @"";
    }
    
    NSString *limit_str = [NSString stringWithFormat:@"%lu",limit];
    NSArray *headers = [self constructHeadersForType:UFHttpResponseTypePrefixFileList author:strAuth options:nil length:0];
    NSString *urlStr  = self.ufConfig.baseURL.absoluteString;
    urlStr = [urlStr stringByAppendingString:@"?list"];
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&prefix=%@",prefix]];
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&marker=%@",marker]];
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&limit=%@",limit_str]];
    urlStr = [UFTools urlEncode:urlStr];
    NSURL *url = [NSURL URLWithString:urlStr];
    UFMutableURLRequest *request = NULL;
    request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"GET" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFPrefixFileList *prefixFileList = [self constructHttpResponseObject:UFHttpResponseTypePrefixFileList
                                                                    response:response body:responseObject filePath:nil handler:handler];
        if (prefixFileList) {
            log4cplus_info("UFSDK_FileList", "get prefix filelist  succ , server response info-->%s\n",[prefixFileList.description UTF8String]);
            handler(nil,prefixFileList);
        }
    }];
    [dataTask resume];
}

#pragma mark- get the file address in the private bucket
- (NSString *)filePrivateUrlWithKeyName:(NSString * _Nonnull)keyName
                            expiresTime:(NSTimeInterval)timeInterval
{
    if ( !keyName && [UFTools uf_isEmpty:keyName]) {
        log4cplus_warn("UFileSDK", "argument error , keyName is nil..\n");
        return nil;
    }
    if (timeInterval <= 0) {
        timeInterval = 60*60*24;  // 如果用户传递时间非法，则默认是24小时
    }
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval expiresTime = nowTime + timeInterval;
    NSString *expires_str = [NSString stringWithFormat:@"%lu",(NSInteger)expiresTime];
    NSString *strAuth = [self.ufConfig signatureForGetFileUrlWithHttpMethod:@"GET" key:keyName md5Data:@"" contentType:@"" expiresTime:expires_str];
    if (strAuth == nil) {
        log4cplus_warn("UFileSDK", "signature error..\n");
        return nil;
    }
    NSString *urlStr  = self.ufConfig.baseURL.absoluteString;
    urlStr = [urlStr stringByAppendingString:@"/"];
    urlStr = [urlStr stringByAppendingString:keyName];;
    urlStr = [urlStr stringByAppendingString:@"?"];
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"UCloudPublicKey=%@",self.ufConfig.publicToken]];
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&Expires=%@",expires_str]];
    urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"&Signature=%@",strAuth]];
    NSString *finalUrlStr = [UFTools urlEncode:urlStr];
    log4cplus_info("UFSDK_DownloadURL", "get private bucket file download url, url:%s\n",[finalUrlStr UTF8String]);
    return finalUrlStr;
}

- (NSString *)filePublicUrlWithKeyName:(NSString * _Nonnull)keyName
{
    if ( !keyName && [UFTools uf_isEmpty:keyName]) {
        log4cplus_warn("UFileSDK", "argument error , keyName is nil..\n");
        return nil;
    }
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@/%@",self.ufConfig.baseURL.absoluteString,keyName];
    log4cplus_info("UFSDK_DownloadURL", "get publick bucket file download url, url:%s\n",[finalUrlStr UTF8String]);
    return finalUrlStr;
}

#pragma mark- get headfile
- (void)headFileWithKeyName:(NSString * _Nonnull)keyName
                        success:(UFHeadFileHandler _Nonnull)handler
{
    if ([UFFileClient checkParametersAndNotify:keyName input:NULL isCheck:NO handler:handler]) {
        return;
    }
    NSString *strAuth = [self.ufConfig signatureForFileOperationWithHttpMethod:@"HEAD" key:keyName md5Data:@"" contentType:@"" callBack:nil];
    NSURL *url = [self fileUrl:keyName params:nil];
    UFMutableURLRequest *request  = NULL;
    NSArray *headers = @[@[@"Authorization",strAuth]];
    request = [[UFMutableURLRequest alloc] initUFMutableURLRequestWithURL:url httpMethod:@"HEAD" timeout:self.timeoutIntervalForRequest headers:headers httpBody:nil];
    
    NSURLSessionDataTask *dataTask = [self.localSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if ([self processingHttpResponseError:error response:response body:responseObject handler:handler]) {
            return;
        }
        UFHeadFile *headFile = [self constructHttpResponseObject:UFHttpResponseTypeHeadFile response:response body:responseObject filePath:nil handler:handler];
        if (headFile) {
             log4cplus_info("UFSDK_HeadFile", "get headFile  succ , server response info-->%s\n",[headFile.description UTF8String]);
             handler(nil,headFile);
        }
    }];
    [dataTask resume];
}

#pragma mark- get file etag
- (NSString *)fileEtagWithFileData:(NSData *)fileData
{
    if (fileData) {
        NSString *etag = [UFTools calcEtagForData:fileData];
        log4cplus_info("UFileSDK", "calc file etag succ, file etag: %s \n",[etag UTF8String]);
        return etag;
    }
    log4cplus_warn("UFileSDK", "calc file etag error, input parameter is nil..\n");
    return NULL;
}

#pragma mark- compare etags between local files and files in the bucket
- (void)compireFileEtagWithRemoteKeyName:(NSString *)remoteKeyName
                           localFileData:(NSData *)data
                          compireResults:(UFCompireFileEtagHandler)callBack
{
    if (!remoteKeyName || !data) {
        log4cplus_warn("UFileSDK", "compire  file etag error, input parameter error(remoteKeyName or data is nil)..\n");
        callBack(NO);
        return;
    }
    
    NSString *etag =[self fileEtagWithFileData:data];
    if (!etag) {
        callBack(NO);
        return;
    }
    [self headFileWithKeyName:remoteKeyName success:^(UFError * _Nonnull ufError, UFHeadFile * _Nonnull ufHeadFile) {
        if (ufError) {
            callBack(NO);
            return;
        }
        if ([ufHeadFile.etag isEqualToString:[NSString stringWithFormat:@"\"%@\"",etag]]) {
            callBack(YES);
            return;
        }
        callBack(NO);
             
    }];
}
@end
