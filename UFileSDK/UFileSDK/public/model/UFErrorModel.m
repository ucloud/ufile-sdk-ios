//
//  UFErrorModel.m
//  UFileSDK
//
//  Created by ethan on 2018/11/26.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFErrorModel.h"
#import "UFileSDKConst.h"
@implementation UFError

- (instancetype)init:(UFErrorType)type
            sysError:(NSError *)error
{
    if (self = [super init]) {
        _type = type;
        _error = error;
    }
    return self;
}

- (instancetype)init:(UFErrorType)type
            sysError:(NSError *)error
           fileClientError:(UFFileClientError *)fileClientError
{
    if (self = [self init:type sysError:error]) {
        _fileClientError = fileClientError;
    }
    return self;
}

//- (instancetype)init:(UFErrorType)type
//            sysError:(NSError * _Nullable)error
//  bucketManagerError:(UFBucketManagerError * _Nullable)bucketManagerError
//{
//    if (self = [self init:type sysError:error]) {
//        _bucketManagerError = bucketManagerError;
//    }
//    return self;
//}

/**
 @brief 构造系统错误
 @discussion 当用户传递参数发生错误时，可利用此方法构造错误

 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidArgument:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KUFInvalidArguments userInfo:@{@"error":desc}];
    return [[self alloc] init:UFErrorType_Sys sysError:error];
}

+ (instancetype)sysErrorWithInvalidElements:(NSString *)desc
{
    NSError *error = [[NSError alloc] initWithDomain:domain code:KUFInvalidElements userInfo:@{@"error":desc}];
    return [[self alloc] init:UFErrorType_Sys sysError:error ];
}


+ (instancetype)sysErrorWithError:(NSError *)error
{
    return [[self alloc] init:UFErrorType_Sys sysError:error];
}

+ (instancetype)httpErrorWithFileClientError:(UFFileClientError *)fileClientError
{
    return [[self alloc] init:UFErrorType_Server sysError:nil fileClientError:fileClientError];
}

//+ (instancetype)httpErrorWithBucketManagerError:(UFBucketManagerError *)bucketManagerError
//{
//    return [[self alloc] init:UFErrorType_Server sysError:nil bucketManagerError:bucketManagerError];
//}
@end

@implementation UFFileClientError

- (instancetype)initWithSessionId:(NSString *)sessionID
                       statusCode:(NSInteger)statusCode
                          retCode:(NSInteger)retCode
                           errMsg:(NSString *)errMsg
{
    if (self = [super init]) {
        _sessionID = sessionID;
        _statusCode = statusCode;
        _retCode = retCode;
        _errMsg = errMsg;
    }
    return self;
}

+ (instancetype)initUFHttpErrorWithSession:(NSString * _Nullable)sessionID
                                statusCode:(NSInteger)statusCode
                                   retCode:(NSInteger)retCode
                                    errMsg:(NSString * _Nullable)errMsg
{
    return [[self alloc] initWithSessionId:sessionID statusCode:statusCode retCode:retCode errMsg:errMsg];
}

- (NSString *)description
{
    return  [NSString stringWithFormat:@"%@:%@ , %@:%lu , %@:%ld , %@:%@",kUFileRespXSession,self.sessionID,kUFileRespHttpStatusCode,self.statusCode,kUFileRespRetCode,self.retCode,kUFileRespErrMsg,self.errMsg];
}


@end


//@implementation UFBucketManagerError
//
//- (instancetype)initWithDict:(NSDictionary *)dict
//{
//    self = [super init];
//    if (!self) {
//        return nil;
//    }
//
//    if ([dict objectForKey:@"RetCode"]) {
//        self.RetCode = [[dict objectForKey:@"RetCode"] integerValue];
//    }
//
//    if ([dict objectForKey:@"Message"]) {
//        self.Message = [dict objectForKey:@"Message"];
//    }
//    return self;
//}
//
//+ (instancetype)ufBucketManagerErrorWithDict:(NSDictionary *)dict
//{
//    return [[self alloc] initWithDict:dict];
//}
//
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"RegCode:%lu , Message:%@",self.RetCode,self.Message];
//}
//
//@end

