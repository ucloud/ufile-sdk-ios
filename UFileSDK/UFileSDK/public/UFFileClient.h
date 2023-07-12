//
//  UFFileClient.h
//  UFileSDK
//
//  Created by ethan on 2018/11/1.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFSDKHelper.h"
#import "UFConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 这是 `NSObject` 的一个子类。用于文件操作，它是SDK的主要操作类。你可以使用该类完成以下功能：
 
 * 文件上传(以路径方式；以NSData方式；分片上传)
 * 文件下载(下载指定范围文件数据；下载整个文件；下载文件到路径)
 * 查询文件
 * 删除文件
 * 获取`bucket`下的文件列表(全部文件列表；指定前缀等条件的文件列表)
 * 获取`bucket`下文件的下载地址(公有`bucket`空间下文件下载地址；私有`bucket`空间下文件下载地址)
 * 获取文件的headfile信息(包括文件的mimetype,etag等)
 * 获取文件的`Etag`
 * 对比本地与远程文件的`Etag`
 
 */
@interface UFFileClient : NSObject

/**
 @brief http请求的超时时间，默认是60s
 */
@property (nonatomic,assign) NSTimeInterval timeoutIntervalForRequest;


/**
 @breif 创建 `UFFileClient` 实例

 @param ufConfig `UFConfig`实例
 @return `UFFileClient`对象
 */
+ (instancetype)instanceFileClientWithConfig:(UFConfig *)ufConfig;

#pragma mark- file upload
/**
 @brief 文件上传
 @discussion 用于文件上传，以文件方式上传（支持后台上传）
 @param keyName  文件的key，即你想把该文件设置的名称
 @param filePath 文件路径
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param uploadProgress 一个 `UFProgress` 类型的block,通过这个block告知用户上传进度
 @param handler 一个 `UFUploadHandler` 的block,用于处理上传结果
 */
- (void)uploadWithKeyName:(NSString * _Nonnull)keyName
                  filePath:(NSString * _Nonnull)filePath
                  mimeType:(NSString * _Nullable)mimeType
                  progress:(UFProgress)uploadProgress
             uploadHandler:(UFUploadHandler _Nonnull)handler;



/**
 @brief 文件上传， 以NSData形式
 @discussion  用于文件上传，上传NSData类型的数据
 @param keyName 文件的key，即你想把该文件设置的名称
 @param data 文件数据
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param uploadProgress 一个 `UFProgress` 类型的block,通过这个block告知用户上传进度
 @param handler 一个 `UFUploadHandler` 的block，用于处理上传结果
 */
- (void)uploadWithKeyName:(NSString * _Nonnull)keyName
                 fileData:(NSData * _Nonnull)data
                 mimeType:(NSString * _Nullable)mimeType
                 progress:(UFProgress)uploadProgress
            uploadHandler:(UFUploadHandler _Nonnull)handler;

/**
 @brief 文件秒传，以文件路径方式
 @disucssion 用于文件秒传，参数需要传入文件路径

 @param keyName 文件的key，即你想把该文件设置的名称
 @param filePath 文件路径
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param handler 一个 `UFUploadHandler` 的block，用于处理上传结果
 */
- (void)hitUploadWithKeyName:(NSString * _Nonnull)keyName
                     filePath:(NSString *)filePath
                     mimeType:(NSString * _Nullable)mimeType
                uploadHandler:(UFUploadHandler _Nonnull)handler;


/**
 @brief 文件秒传，以NSData方式
 @discussion 文件秒传，参数需要传入NSData

 @param keyName 文件的 keyName
 @param data 文件数据
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param handler 一个 `UFUploadHandler` 的block，用于处理上传结果
 */
- (void)hitUploadWithKeyName:(NSString * _Nonnull)keyName
                    fileData:(NSData * _Nonnull)data
                    mimeType:(NSString * _Nullable)mimeType
               uploadHandler:(UFUploadHandler _Nonnull)handler;

#pragma mark- multipart upload

/**
 @brief 准备分片上传

 @param keyName 文件的key，即你想把该文件设置的名称
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param handler 一个 `UFPrepareMultiPartUploadHandler` 的block，用于处理准备分片上传的结果
 */
- (void)prepareMultipartUploadWithKeyName:(NSString * _Nonnull)keyName
                                 mimeType:(NSString * _Nullable)mimeType
            prepareMultiPartUploadHandler:(UFPrepareMultiPartUploadHandler _Nonnull)handler;

/**
 @brief 开始分片上传
 @discussion 开始分片上传。用于上传每片文件数据

 @param keyName  文件的key，即你的文件的名称
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param upId 本次分片上传的id
 @param partIndex 片索引，即第几片
 @param data 文件数据
 @param uploadProgress 上传进度
 @param handler 一个 `UFUploadHandler` 的block，用于处理开始分片上传的结果
 */
- (void)startMultipartUploadWithKeyName:(NSString * _Nonnull)keyName
                               mimeType:(NSString * _Nullable)mimeType
                               uploadId:(NSString * _Nonnull)upId
                              partIndex:(NSInteger)partIndex
                               fileData:(NSData * _Nonnull)data
                               progress:(UFProgress _Nonnull)uploadProgress
                          uploadHandler:(UFUploadHandler _Nonnull)handler;

/**
 @brief 取消上传

 @param keyName 文件的key，即你的文件的名称
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param upId 本次分片上传的id
 @param handler 一个 `UFUploadHandler` 的block，用于处理取消分片上传的结果
 */
- (void)multipartUploadAbortWithKeyName:(NSString * _Nonnull)keyName
                               mimeType:(NSString * _Nullable)mimeType
                               uploadId:(NSString * _Nonnull)upId
                                uploadHandler:(UFUploadHandler _Nonnull)handler;


/**
 @brief 结束上传

 @param keyName 文件的key，即你的文件的名称
 @param mimeType 文件的mime类型，如果为空，默认就是二进制流 "application/octet-stream"; 如果不为空，就按照用户输入的mime类型
 @param upId 本次分片上传的id
 @param newKeyName 新的文件名称，可以不传。 由于可能传输时间较长，原来的 key 可能会被占用，可以传一个新的 key 来替代。
 @param etags 所有分片的etag数组
 @param handler 一个 `UFFinishMultipartUploadHandler` 的block，用于处理结束分片上传的结果
 */
- (void)multipartUploadFinishWithKeyName:(NSString * _Nonnull)keyName
                                mimeType:(NSString * _Nullable)mimeType
                                uploadId:(NSString * _Nonnull)upId
                              newKeyName:(NSString * _Nullable)newKeyName
                                   etags:(NSArray * _Nonnull)etags
            finishMultipartUploadHandler:(UFFinishMultipartUploadHandler _Nonnull)handler;


#pragma mark- file download

/**
 @brief 文件下载
 @discussion 用于文件下载

 @param keyName 文件的key，即你设置的文件的名称
 @param range 分片下载时，单次下载文件大小，单位是(Byte)。 如果你输入的大小大于文件大小，单次下载就会按照文件大小下载。
 @param downloadProgress 下载进度
 @param handler 一个 `UFDownloadHandler` 的block，用于处理下载结果
 */
- (void)downloadWithKeyName:(NSString * _Nonnull)keyName
              downloadRange:(UFDownloadFileRange)range
                   progress:(UFProgress _Nullable)downloadProgress
            downloadHandler:(UFDownloadHandler _Nonnull)handler;


/**
 @brief 文件下载到指定目录
 @discussion 注意：只有该方法支持文件后台下载

 @param keyName 文件名称
 @param path 文件要存储的目录
 @param range 文件下载范围
 @param downloadProgress 下载进度
 @param handler 一个 `UFDownloadHandler` 的block，用于处理下载结果
 */
- (void)downloadWithKeyName:(NSString * _Nonnull)keyName
                 destinationPath:(NSString * _Nonnull)path
                   downloadRange:(UFDownloadFileRange)range
                        progress:(UFProgress _Nullable)downloadProgress
                 downloadHandler:(UFDownloadHandler _Nonnull)handler;

#pragma mark- delete file


/**
 @brief 删除文件

 @param keyName 文件的key
 @param handler 一个 `UFDeleteHandler` 的block，用于处理文件删除结果
 */
- (void)deleteWithKeyName:(NSString * _Nonnull)keyName deleteHandler:(UFDeleteHandler _Nonnull)handler;

#pragma mark- query file information
/**
 @brief 查询文件信息

 @param keyName 文件的key
 @param handler 一个 `UFQueryHandler` 的block，用于处理文件查询结果
 */
- (void)queryWithKeyName:(NSString * _Nonnull)keyName queryHandler:(UFQueryHandler _Nonnull)handler;

#pragma mark- get file list
/**
 获取bucket下的文件列表

 @param prefix 前缀，utf-8编码，默认为空字符串
 @param marker 标志字符串，utf-8编码，默认为空字符串)
 @param limit 文件列表数目，传0会默认为20
 @param handler  一个 `UFPrefixFileListHandler` 的block，用于处理bucket下文件列表查询的结果
 */
- (void)prefixFileListWithPrefix:(NSString * _Nullable)prefix
                          marker:(NSString * _Nullable)marker
                           limit:(NSInteger)limit
           prefixFileListHandler:(UFPrefixFileListHandler _Nonnull)handler;


#pragma mark- get file address
/**
 获取私有空间文件下载地址

 @param keyName 文件的key
 @param timeInterval 超时时间，单位是秒。 如果传入的时间非法(<=0),则默认超时时间是24小时(1天)
 @return  私有空间下载地址
 */
- (NSString *)filePrivateUrlWithKeyName:(NSString * _Nonnull)keyName
                            expiresTime:(NSTimeInterval)timeInterval;


/**
 获取公有空间文件下载地址

 @param keyName 文件的key
 @return 公有空间文件下载地址
 */
- (NSString *)filePublicUrlWithKeyName:(NSString * _Nonnull)keyName;

#pragma mark- query file basic information

/**
 @brief 获取文件的headfile，其内部包含了文件的 etag，contentType等信息

 @param keyName 文件的keyName
 @param handler  一个 `UFHeadFileHandler` 的block，用于处理获取文件的headfile信息的结果
 */
- (void)headFileWithKeyName:(NSString * _Nonnull)keyName  success:(UFHeadFileHandler _Nonnull)handler;

#pragma mark- calculator file Etag

/**
 @brief 获取文件数据的Etag

 @param fileData 文件数据
 @return 文件的etag值
 */
- (NSString *)fileEtagWithFileData:(NSData *)fileData;

#pragma mark- compire file etag

/**
 @breif 比较本地与远端文件的Etag
 
 @discussion 这个方法用于比较本地与远端文件的Etag,其内部实现就是根据上面两个方法实现的。 你也可以不用这个方法做比较，直接用上面的两个方法做etag比较。
 如果你的文件操作(eg:文件上传)服务器返回的有etag，可以直接用上面的方法计算出本地文件的etag和服务器返回的etag做对比即可。如果你执意要使用此方法，那么在服务器端返回的有etag的情况下，
 还会再发一次网络请求获取文件的headfile(headfile中有远端文件的etag等信息)，然后再对比，这样会增加网络开销。
 
 @param remoteKeyName 文件在服务器端的keyName
 @param data 本地文件数据
 @param callBack 一个 `UFCompireFileEtagHandler` 的block，用于处理比较结果
 */
- (void)compireFileEtagWithRemoteKeyName:(NSString *)remoteKeyName
                           localFileData:(NSData *)data
                          compireResults:(UFCompireFileEtagHandler)callBack;

@end

NS_ASSUME_NONNULL_END
