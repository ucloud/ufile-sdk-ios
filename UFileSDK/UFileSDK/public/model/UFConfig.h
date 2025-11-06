//
//  UFConfig.h
//  UFileSDK
//
//  Created by ethan on 2018/11/6.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFSDKHelper.h"

NS_ASSUME_NONNULL_BEGIN

/**
 这是`NSObject`的一个子类，该类用于配置文件操作所必须的一些信息
 */
@interface UFConfig : NSObject

/**
 私有token
 */
@property (nonatomic,readonly) NSString *privateToken;

/**
 公有token
 */
@property (nonatomic,readonly, nullable) NSString *publicToken;

/**
 bucket
 */
@property (nonatomic,readonly) NSString *bucket;


/**
 文件操作的签名服务器，该签名服务器用于文件上传和下载时签名
 */
@property (nonatomic,readonly) NSString *fileOperateEncryptServer;

/**
 获取文件地址时的签名服务器，该签名服务在获取私有`bucket`下的文件url时会用到
 */
@property (nonatomic,readonly) NSString *fileAddressEncryptServer;


/**
 默认域名后缀 eg: ufile.cloud.cn
 */
@property (nonatomic,readonly) NSString *proxySuffix;

/**
 自定义域名，如果设置了自定义域名，将优先使用自定义域名
 eg: https://cdn.example.com 或 https://files.mydomain.com
 */
@property (nonatomic,readonly, nullable) NSString *customDomain;

/**
 请求服务地址，内部使用
 */
@property (nonatomic,readonly) NSURL *baseURL;


/**
 是否是Https请求
 */
@property (nonatomic, readonly) BOOL isHttps;

/**
 @brief 使用SDK所必须的一些参数设置
 
 @discussion 建议使用签名服务器的方式进行签名，这样做避免了私钥暴露在app中，这样做更加安全。签名服务器地址有两个，一个是文件操作签名服务器地址，另一个是获取文件地址时的签名服务器地址。其应用场景如下：
 
 文件操作签名服务器地址：在文件上传和下载时用该服务器签名。
 获取文件地址签名服务器: 在获取私有`bucket`空间下的文件下载地址时，会用到该签名服务器。
 
 具体签名逻辑及各服务端实现的示例代码`UCloud`有提供，可访问`UCloud`官方文档查看或者联系`UCloud`技术支持
 
 @param privateToken 私有token,可选参数，如果该字段为空，表示要用服务器签名，那么`fileOperateEncryptServer`和`fileAddressEncryptServer`必须填写
 @param publicToken  公有token
 @param bucket       bucket
 @param fileOperateEncryptServer 文件操作的签名服务器地址,如果该字段为空，则进行本地签名
 @param fileAddressEncryptServer 获取文件地址时的签名服务器，如果该字段为空，则进行本地签名
 @param proxySuffix   默认域名后缀 eg: ufile.cloud.cn（如果提供了customDomain，则不需要；否则必需）
 @param customDomain 自定义域名，完整URL格式，如：https://cdn.example.com 或 http://files.mydomain.com（可选，如果提供则不需要proxySuffix，走自定义域名逻辑）
 @param isHttps   是否使用https请求
 @return 返回一个 `UFAuthor` 实例
 */
+ (instancetype)instanceConfigWithPrivateToken:(NSString * _Nullable)privateToken
                               publicToken:(NSString * _Nullable)publicToken
                                    bucket:(NSString * _Nonnull)bucket
                             fileOperateEncryptServer:(NSString * _Nullable)fileOperateEncryptServer
                          fileAddressEncryptServer:(NSString * _Nullable)fileAddressEncryptServer
                                   proxySuffix:(NSString * _Nullable)proxySuffix
                                  customDomain:(NSString * _Nullable)customDomain
                                       isHttps:(BOOL)isHttps;

/**
 @breif 生成签名(内部使用)

 @param httpMethod http请求方式
 @param keyName 文件的keyName
 @param contentMd5 文件数据的md5格式
 @param contentType 文件的mime类型
 @param policy 签名服务
 @return 签名
 */
- (id)signatureForFileOperationWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType callBack:(NSDictionary * __nullable)policy;


/**
 @brief 生成签名(内部使用)

 @param httpMethod http请求方式
 @param keyName 文件的keyName
 @param contentMd5 文件数据的md5格式
 @param contentType 文件的mime类型
 @param expiresTime 过期时间
 @return 签名
 */
- (id)signatureForGetFileUrlWithHttpMethod:(NSString *)httpMethod key:(NSString *)keyName md5Data:(NSString * __nullable)contentMd5 contentType:(NSString *)contentType expiresTime:(NSString *)expiresTime;
@end

NS_ASSUME_NONNULL_END
