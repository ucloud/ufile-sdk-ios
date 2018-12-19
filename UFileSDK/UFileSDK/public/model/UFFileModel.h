//
//  UFFileModel.h
//  UFileSDK
//
//  Created by ethan on 2018/11/27.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 这是`NSObject`的一个子类，它是文件上传和下载时服务器响应数据模型的超类
 */
@interface UFFileOperateResponse : NSObject

/**
 @brief 网络响应状态码
 */
@property (nonatomic,readonly) NSInteger statusCode;

/**
 @brief 文件的`etag`值  在`UFile`中，每一个文件都有一个唯一对应的`etag`值
 */
@property (nonatomic,readonly) NSString *etag;

/**
 @brief 实例化UFFileOperateResponse

 @param statusCode 网络响应状态码
 @param etag 文件的etag
 @return UFFileOperateResponse实例
 */
- (instancetype)initWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag;

/**
 @brief 实例化UFFileOperateResponse（内部使用）

 @param statusCode 网络响应状态码
 @param etag 文件的etag
 @return UFFileOperateResponse实例
 */
+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag;
@end


/**
 这是`UFFileOperateResponse`的一个子类，该类用于文件上传时服务器返回信息的展示
 */
@interface UFUploadResponse : UFFileOperateResponse

/**
 @brief 分片上传时，片索引(普通上传没有该字段)。  eg: 比如一个文件100M，如果按照10M一个分片的话，那么总共分成10片，那么片索引就是 1,2,3...10
 */
@property (nonatomic,readonly) NSUInteger partNumber;

/**
 @brief 实例化UFUploadResponse（内部使用）
 
 @param statusCode 网络响应状态码
 @param etag 文件的etag
 @param partNumber 分片索引，只有在分片上传时有该属性
 @return UFUploadResponse实例
 */
+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag partNumber:(NSUInteger)partNumber;
@end


/**
 这是`UFFileOperateResponse`的一个子类，该类用于下载文件的结果。
 */
@interface UFDownloadResponse : UFFileOperateResponse

/**
 @brief 文件数据，有时候可能为空
 @discussion 在下载文件到制定目录时，SDK不返回该字段，会自动把文件数据写进你指定的目录
 */
@property (nonatomic,readonly) NSData *data;

/**
 @brief 下载文件到制定目录时，SDK会返回最后文件所在的路径
 */
@property (nonatomic,readonly) NSString *destPath;


/**
 @brief 实例化 UFDownloadResponse（内部使用）

 @param statusCode 网络响应状态码
 @param etag 文件的etag
 @param data 文件数据
 @param destPath 下载文件到制定目录时，SDK会返回最后文件所在的路径
 @return UFDownloadResponse实例
 */
+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag data:(NSData *)data destPath:(NSString *)destPath;
@end

/**
 这是`NSObject`的一个子类，用于表示分片信息
 */
@interface UFMultiPartInfo : NSObject

/**
 @brief 分片大小，在开始分片上传的时候需要用到
 */
@property (nonatomic,readonly) NSUInteger blkSize;

/**
 @brief 上传文件所属`bucket`的名称
 */
@property (nonatomic,readonly) NSString *bucket;

/**
 @brief 上传文件在`bucket`中的 Key 名称
 */
@property (nonatomic,readonly) NSString *key;

/**
 @brief uploadId,在开始分片上传和结束分片上传的使用会被用到
 */
@property (nonatomic,readonly) NSString *uploadId;

/**
 @brief 实例化`UFMultiPartInfo`

 @param blkSize 分片大小
 @param bucket 上传文件所属`bucket`的名称
 @param key 上传文件在`bucket`中的 Key 名称
 @param uploadId 上传ID
 @return `UFMultiPartInfo`实例
 */
+ (instancetype)instanceWithBlkSize:(NSUInteger)blkSize
                             bucket:(NSString *)bucket
                                key:(NSString *)key
                           uploadId:(NSString *)uploadId;

/**
 @brief 实例化`UFMultiPartInfo`（内部使用）

 @param dict 字段字典
 @return `UFMultiPartInfo`实例
 */
+ (instancetype)ufMultiPartInfoWithDict:(NSDictionary *)dict;
@end

/**
 这是`UFFileOperateResponse`的一个子类，用于表示结束分片上传时服务器响应信息展示
 */
@interface UFFinishMultipartUploadResponse : UFFileOperateResponse

/**
 @brief 已上传文件所属`bucket`的名称
 */
@property (nonatomic,readonly) NSString *bucket;

/**
 @brief 已上传文件在`bucket`中的Key名称
 */
@property (nonatomic,readonly) NSString *key;

/**
 @brief 已上传文件的大小
 */
@property (nonatomic,readonly) NSUInteger fileSize;

/**
 @brief 实例化`UFFinishMultipartUploadResponse`（内部使用）

 @param statusCode 状态码
 @param etag etag值
 @param bucket 已上传文件在`bucket`中的Key名称
 @param key 已上传文件在`bucket`中的Key名称
 @param fileSize 文件大小
 @return `UFFinishMultipartUploadResponse`实例
 */
+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode
                                  etag:(NSString *)etag
                                bucket:(NSString *)bucket
                                   key:(NSString *)key
                              fileSize:(NSUInteger)fileSize;
@end

/**
 这是`UFFileOperateResponse`的一个子类，用于表示文件的信息
 */
@interface UFQueryFileResponse : UFFileOperateResponse

/**
 @brief  HTTP响应body部分的类型
 */
@property (nonatomic,readonly) NSString *contentType;

/**
 @brief HTTP响应body部分的长度
 */
@property (nonatomic,readonly) NSUInteger contentLength;

/**
 @brief 实例化`UFQueryFileResponse`（内部使用）
 
 @param statusCode 状态码
 @param etag etag值
 @param contentType HTTP响应body部分的类型
 @param contentLength HTTP响应body部分的长度
 @return `UFQueryFileResponse`实例
 */
+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode
                                  etag:(NSString *)etag
                           contentType:(NSString *)contentType
                         contentLength:(NSUInteger)contentLength;
@end


/**
 这是`UFQueryFileResponse`的一个子类，用于表示文件的`HeadFile`信息
 */
@interface UFHeadFile : UFQueryFileResponse

/**
 @brief 文件的范围
 */
@property (nonatomic,readonly) NSString *contentRange;


/**
 @brief 实例化`UFQueryFileResponse`（内部使用）

 @param statusCode 状态码
 @param etag etag值
 @param contentType 文件的mime类型
 @param contentLength 文件的长度
 @param contentRange 文件的范围
 @return `UFQueryFileResponse`实例
 */
+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode
                                  etag:(NSString *)etag
                           contentType:(NSString *)contentType
                         contentLength:(NSUInteger)contentLength
                          contentRange:(NSString *)contentRange;

@end

/**
 这是`NSObject`的一个子类，用于获取`bucket`下的文件列表查询
 */
@interface UFPrefixFileList : NSObject

/**
 @brief `bucket`名称
 */
@property (nonatomic,readonly) NSString *bucketName;

/**
 @brief `bucket`的ID
 */
@property (nonatomic,readonly) NSString *bucketId;

/**
 @brief 下一个标志字符串，utf-8编码
 */
@property (nonatomic,readonly) NSString *nextMarker;

/**
 @brief 文件列表
 */
@property (nonatomic,readonly) NSArray *dataSet;

/**
@brief 实例化`UFPrefixFileList`（内部使用）

 @param dict 字段字典
 @return `UFPrefixFileList`实例
 */
+ (instancetype)ufPrefixFileListResponseWithDict:(NSDictionary *)dict;
@end

/**
 这是`NSObject`的一个子类，用于表示`bucket`下的单个文件信息
 */
@interface UFPrefixFileDataSetItem : NSObject

/**
 @brief 文件所属`bucket`名称
 */
@property (nonatomic,readonly) NSString *bucketName;

/**
 @brief 文件名称,utf-8编码
 */
@property (nonatomic,readonly) NSString *fileName;

/**
 @brief 文件hash值
 */
@property (nonatomic,readonly) NSString *hashStr;

/**
 @brief 文件mime类型
 */
@property (nonatomic,readonly) NSString *mimeType;

/**
 @brief 文件大小
 */
@property (nonatomic,readonly) NSInteger size;

/**
 @brief 文件创建时间
 */
@property (nonatomic,readonly) NSInteger createTime;

/**
 @brief 文件修改时间
 */
@property (nonatomic,readonly) NSInteger modifyTime;

/**
 @brief 实例化`UFPrefixFileDataSetItem`（内部使用）

 @param dict 字段字典
 @return `UFPrefixFileDataSetItem`实例
 */
+ (instancetype)ufPrefixFileDataSetItemWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
