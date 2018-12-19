//
//  UFSDKHelper.h
//  UFileSDK
//
//  Created by ethan on 2018/10/31.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UFFileModel.h"
#import "UFErrorModel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark- 全局

/**
 @brief 日志级别，这是一个枚举定义
 
 @discussion 建议在开发的时候，把SDK的日志级别设置为`UFSDKLogLevel_DEBUG`,这样便于开发调试。等上线时再把级别改为较高级别的`UFSDKLogLevel_ERROR`
 */
typedef NS_ENUM(NSUInteger,UFSDKLogLevel) {
    /// FATAL 级别
    UFSDKLogLevel_FATAL,
    /// ERROR 级别
    UFSDKLogLevel_ERROR,
    /// WARN 级别
    UFSDKLogLevel_WARN,
    /// INFO 级别
    UFSDKLogLevel_INFO,
    /// DEBUG 级别
    UFSDKLogLevel_DEBUG
};

#pragma mark- 文件管理模块
/**
 @brief 文件Rang (文件范围)
 
 @discussion 下载文件时，可以选择下载文件的范围。例如一个文件100Byte,你可以下载 0-10Byte数据，也可以现在中间 50-60Byte数据
 */
typedef struct UFDownloadFileRange
{
    /// 开始值
    NSUInteger begin;
    /// 结束值
    NSUInteger end;
}UFDownloadFileRange;


/**
 @brief 进度信息

 @discussion  progress 是一个`NSProgress`对象，显示进度信息
 
 @param progress 进度
 */
typedef void (^ UFProgress)(NSProgress * _Nonnull progress);

/**
 @brief  文件上传操作的回调

 @discussion ufError 如果为空，则表示文件上传成功，具体信息请参考`UFError`； ufUploadResponse 文件操作成功时的反馈信息，具体信息请参考`UFUploadResponse`
 */
typedef void (^ UFUploadHandler)(UFError * _Nullable ufError,UFUploadResponse* _Nullable ufUploadResponse);

/**
 @brief  文件下载操作的回调
 
 @discussion ufError 如果为空，则表示文件下载成功，具体信息请参考`UFError`;  ufDownloadResponse  文件下载成功时的反馈信息，具体信息请参考`UFDownloadResponse`
 */
typedef void (^ UFDownloadHandler)(UFError * _Nullable ufError,UFDownloadResponse * _Nullable ufDownloadResponse);

/**
 @brief  文件删除操作的回调

 @discussion ufError  如果为空，则表示文件删除成功，具体信息请参考`UFError`; obj 文件操作成功时的反馈信息
 */
typedef void (^ UFDeleteHandler)(UFError * _Nullable ufError, NSObject * _Nullable obj);

/**
 @brief  文件查询操作的回调

 @discussion ufError  如果为空，则表示文件查询成功，具体信息请参考`UFError`; ufQueryFileResponse 文件操作成功时的反馈信息，具体信息请参考`UFQueryFileResponse`
 */
typedef void (^ UFQueryHandler)(UFError * _Nullable ufError, UFQueryFileResponse * _Nullable ufQueryFileResponse);

/**
 @brief  准备分片上传操作的回调
 
 @discussion ufError 如果为空，则表示准备分片上传操作成功，具体信息请参考`UFError`; multiPartInfo 准备分片上传操作成功时的反馈信息，具体信息请参考`UFMultiPartInfo`
 */
typedef void (^ UFPrepareMultiPartUploadHandler)(UFError * _Nullable ufError,UFMultiPartInfo * _Nullable multiPartInfo);

/**
 @brief  结束分片上传操作的回调
 
 @discussion ufError  如果为空，则表示结束分片上传操作成功，具体信息请参考`UFError`; finishUploadInfo 分片上传操作成功时的反馈信息，具体信息请参考`UFFinishMultipartUploadResponse`
 */
typedef void (^ UFFinishMultipartUploadHandler)(UFError * _Nullable ufError,UFFinishMultipartUploadResponse* _Nullable finishUploadInfo);

/**
 @brief  获取bucket下的文件列表的回调

 @discussion ufError  如果为空，则表示获取bucket下文件列表传操作成功，具体信息请参考`UFError`; ufPrefixFileList 获取bucket下文件列表操作成功时的反馈信息，具体信息请参考`UFPrefixFileList`
 */
typedef void (^ UFPrefixFileListHandler)(UFError * _Nullable ufError,UFPrefixFileList * _Nullable ufPrefixFileList);

/**
 @brief  获取文件信息的回调

 @discussion
 获取文件的headfile操作，其实就是获取文件的信息，包括文件长度，类型，范围等信息。
 
 ufError  如果为空，则表示获取文件headfile操作成功，具体信息请参考`UFError`; ufHeadFile 获取文件headfile操作成功时的反馈信息，具体信息请参考`UFHeadFile`
 */
typedef void (^ UFHeadFileHandler) (UFError * _Nullable ufError,UFHeadFile * _Nullable ufHeadFile);

/**
 @brief  比对本地文件与`bucket`中该文件的`Etag`操作的回调
 
 @discussion result YES: 本地和远端Etag一致； NO:不一致
 */
typedef void (^ UFCompireFileEtagHandler)(BOOL result);

NS_ASSUME_NONNULL_END
