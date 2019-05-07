//
//  UFileSDKConst.h
//  UFileSDK
//
//  Created by ethan on 2018/10/31.
//  Copyright © 2018 ucloud. All rights reserved.
//

/********** For log4cplus  ************/
#ifndef UFile_Log_IOS
#define UFile_Log_IOS
#endif

#ifndef UFileSDKConst_h
#define UFileSDKConst_h

/********** 错误信息 ************/
static NSString * domain = @"ucloud.cn";
static const int KUFInvalidArguments = -2;
static const int KUFInvalidElements = -3; // instance array or dictionary error

/********** upload  http response  ************/


#define kUFileSDKOptionFileType   @"filetype"
#define kUFileSDKOptionRange  @"range"
#define kUFileSDKOptionModifiedSince @"If-Modified-Since"
#define kUFileSDKOptionMD5  @"md5"
#define kUFileSDKOptionTimeoutInterval  @"timeoutInterval"

#define kUFileRespXSession  @"X-SessionId"
#define KUFHeadFileContentType  @"Content-Type"
#define KUFHeadFileContentLength  @"Content-Length"
#define KUFHeadFileContentRange  @"Content-Range"
#define kUFileRespRetCode  @"RetCode"
#define kUFileRespHttpStatusCode  @"StatusCode"
#define kUFileRespErrMsg  @"ErrMsg"
#define kUFileSDKAPIErrorDomain  @"UFile_SDK_API_ERROR"

#define kUFileRespHeaderEtag  @"ETag"
#define kUFileRespLength      @"length"

#define KUFileRespPartNumber  @"PartNumber"

#define KUFileRespFileSize  @"FileSize"

#define  KUFileSDKDownloadData   @"UFDownloadData"
#define  KUFileSDKDownloadDestinationPath  @"UFDownloadDestinationPath"

#define  KUFileSDKVersion  @"3.0.5"


/****    for UFMultiPartInfo  ****/
#define  KBlkSize  @"BlkSize"
#define  KBucket   @"Bucket"
#define  KKey      @"Key"
#define  KUploadId  @"UploadId"

#endif /* UFileSDKConst_h */
