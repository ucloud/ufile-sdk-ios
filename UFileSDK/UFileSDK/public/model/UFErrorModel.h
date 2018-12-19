//
//  UFErrorModel.h
//  UFileSDK
//
//  Created by ethan on 2018/11/26.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

typedef enum UFErrorType
{
    UFErrorType_Sys = 0,   // 系统错误
    UFErrorType_Server     // 系统无错误，但UFile服务器返回异常信息
}UFErrorType;


/**
 这是`NSObject`的一个子类，该类用于展示`http`请求响应的错误信息
 */
@interface UFFileClientError : NSObject
/**
 @brief  本次请求对应的`session id`
 */
@property (nonatomic,readonly) NSString  *sessionID;

/**
 @brief 网络响应的状态码
 */
@property (nonatomic,readonly) NSInteger statusCode;

/**
 @brief `UFile`服务器返回的回执码
 */
@property (nonatomic,readonly) NSInteger retCode;

/**
 @brief `UFile`服务器返回的错误信息
 */
@property (nonatomic,readonly) NSString *errMsg;


/**
 @brief 构造HTTP错误
 
 @param sessionID 错误SessionID,可能为空
 @param statusCode 网络状态码
 @param retCode 服务器端返回的回执码
 @param errMsg 服务器端返回的错误信息，可能为空
 @return HTTP错误实例
 */
- (instancetype)initWithSessionId:(NSString *)sessionID
                       statusCode:(NSInteger)statusCode
                          retCode:(NSInteger)retCode
                           errMsg:(NSString *)errMsg;


/**
 @brief 构造HTTP错误
 
 @param sessionID 错误SessionID,可能为空
 @param statusCode 网络状态码
 @param retCode 服务器端返回的回执码
 @param errMsg 服务器端返回的错误信息，可能为空
 @return HTTP错误实例
 */
+ (instancetype)initUFHttpErrorWithSession:(NSString * _Nullable)sessionID
                                statusCode:(NSInteger)statusCode
                                   retCode:(NSInteger)retCode
                                    errMsg:(NSString * _Nullable)errMsg;
@end


///**
// 这是`NSObject`的一个子类，该类用于展示Bucket管理相关的HTTP错误
// */
//@interface UFBucketManagerError : NSObject
///**
// @brief 服务器返回的回执码
// */
//@property (nonatomic,assign) NSInteger RetCode;
//
///**
// @brief 服务器返回的信息
// */
//@property (nonatomic,copy) NSString * Message;
//
//
///**
// @brief 创建一个`UFBucketManagerError`实例 (内部使用)
//
// @param dict 字段字典
// @return `UFBucketManagerError`实例
// */
//+ (instancetype)ufBucketManagerErrorWithDict:(NSDictionary *)dict;
//@end



/**
 这是`NSObject`的一个子类，该类用于展示UFileSDK的错误信息
 */
@interface UFError:NSObject

/**
 *  错误类型，分为系统错误和服务器错误，如果是服务器错误服务器会返回错误信息
 */
@property (nonatomic,readonly)  UFErrorType type;

/**
 *  系统错误信息
 */
@property (nonatomic,readonly)  NSError     *error;

/**
 *  服务器错误,文件操作
 */
@property (nonatomic,readonly)  UFFileClientError *fileClientError;

///**
// *  服务器错误,Bucket管理
// */
//@property (nonatomic,readonly)  UFBucketManagerError *bucketManagerError;

/**
 * 构造错误(参数错误)
 * @param desc 错误信息
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidArgument:(NSString *)desc;

/**
 @brief 构造错误(容器中的元素非法)

 @param desc 错误描述
 @return 错误实例
 */
+ (instancetype)sysErrorWithInvalidElements:(NSString *)desc;

/**
 构造错误

 @param error 系统错误实例
 @return 错误实例
 */
+ (instancetype)sysErrorWithError:(NSError *)error;

/**
 构造错误

 @param fileClientError 文件操作时UFile服务器返回的错误
 @return 错误实例
 */
+ (instancetype)httpErrorWithFileClientError:(UFFileClientError *)fileClientError;

///**
// UFBucketQueryHandler
//
// @param bucketManagerError `bucket`管理时`UFile`服务器返回的错误
// @return 错误实例
// */
//+ (instancetype)httpErrorWithBucketManagerError:(UFBucketManagerError *)bucketManagerError;

/**
 @brief 构造错误

 @param type 错误类型
 @param error 系统错误描述
 @param fileClientError 服务器返回错误描述
 @return UFileError错误实例
 */
- (instancetype)init:(UFErrorType)type
            sysError:(NSError * _Nullable)error
           fileClientError:(UFFileClientError * _Nullable)fileClientError;

///**
// @brief 构造错误
//
// @param type 错误类型
// @param error 系统错误描述
// @param bucketManagerError bucket操作时，服务器返回错误描述
// @return UFFileError错误实例
// */
//- (instancetype)init:(UFErrorType)type
//            sysError:(NSError * _Nullable)error
//  bucketManagerError:(UFBucketManagerError * _Nullable)bucketManagerError;
@end


NS_ASSUME_NONNULL_END
