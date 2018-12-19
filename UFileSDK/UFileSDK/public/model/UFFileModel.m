//
//  UFFileModel.m
//  UFileSDK
//
//  Created by ethan on 2018/11/27.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFFileModel.h"
#import "UFileSDKConst.h"

@implementation UFFileOperateResponse
- (instancetype)initWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag
{
    if (self = [super init]) {
        _statusCode = statusCode;
        _etag = etag;
    }
    return self;
}

+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag
{
    return [[self alloc] initWithStatusCode:statusCode etag:etag];
}

@end

@implementation UFUploadResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag partNumber:(NSUInteger)partNumber
{
    if (self = [super initWithStatusCode:statusCode etag:etag]) {
        _partNumber = partNumber;
    }
    return self;
}

+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag partNumber:(NSUInteger)partNumber
{
    return [[self alloc] initWithStatusCode:statusCode etag:etag partNumber:partNumber];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%@ , %@:%@ ,%@:%lu",kUFileRespHeaderEtag,self.etag,kUFileRespHttpStatusCode,[NSString stringWithFormat:@"%ld",self.statusCode],KUFileRespPartNumber,(unsigned long)self.partNumber];
}

@end

@implementation UFDownloadResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag data:(NSData *)data destPath:(NSString *)destPath
{
    if (self = [super initWithStatusCode:statusCode etag:etag]) {
        _data = data;
        _destPath = destPath;
    }
    return self;
}

+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode etag:(NSString *)etag data:(NSData *)data destPath:(NSString *)destPath
{
    return [[self alloc] initWithStatusCode:statusCode etag:etag data:data destPath:destPath];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%@ , %@:%@ , %@:%@ ,dataLength:%lu",KUFileSDKDownloadDestinationPath, self.destPath , kUFileRespHttpStatusCode , [NSString stringWithFormat:@"%ld",self.statusCode],kUFileRespHeaderEtag,self.etag,self.data.length];
}
@end

@implementation UFMultiPartInfo

- (instancetype)initWithBlkSize:(NSUInteger)blkSize
                         bucket:(NSString *)bucket
                            key:(NSString *)key
                       uploadId:(NSString *)uploadId
{
    if (self = [super init]) {
        _blkSize = blkSize;
        _bucket = bucket;
        _key = key;
        _uploadId = uploadId;
    }
    return self;
}

+ (instancetype)instanceWithBlkSize:(NSUInteger)blkSize
                             bucket:(NSString *)bucket
                                key:(NSString *)key
                           uploadId:(NSString *)uploadId
{
    return [[self alloc] initWithBlkSize:blkSize bucket:bucket key:key uploadId:uploadId];
}

+ (instancetype)ufMultiPartInfoWithDict:(NSDictionary *)dict
{
    return [self instanceWithBlkSize:[[dict objectForKey:KBlkSize] unsignedIntegerValue]
                              bucket:[dict objectForKey:KBucket]
                                 key:[dict objectForKey:KKey]
                            uploadId:[dict objectForKey:KUploadId]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%ld, %@:%@ , %@:%@ , %@:%@",KBlkSize, self.blkSize ,KBucket,self.bucket,KKey,self.key,KUploadId,self.uploadId];
}
@end

@implementation UFFinishMultipartUploadResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode
                              etag:(NSString *)etag
                            bucket:(NSString *)bucket
                               key:(NSString *)key
                          fileSize:(NSUInteger)fileSize
{
    if (self = [super initWithStatusCode:statusCode etag:etag]) {
        _bucket = bucket;
        _key = key;
        _fileSize = fileSize;
    }
    return self;
}

+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode
                                  etag:(NSString *)etag
                                bucket:(NSString *)bucket
                                   key:(NSString *)key
                              fileSize:(NSUInteger)fileSize
{
    return [[self alloc] initWithStatusCode:statusCode etag:etag bucket:bucket key:key fileSize:fileSize];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%ld, %@:%@ , %@:%@ , %@:%ld",kUFileRespHttpStatusCode, (long)self.statusCode ,KBucket,self.bucket,KKey,self.key,KUFileRespFileSize,(long)self.fileSize];
}

@end


@implementation UFQueryFileResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode
                              etag:(NSString *)etag
                       contentType:(NSString *)contentType
                     contentLength:(NSUInteger)contentLength
{
    if (self = [super initWithStatusCode:statusCode etag:etag]) {
        _contentType = contentType;
        _contentLength = contentLength;
    }
    return self;
}

+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode
                                  etag:(NSString *)etag
                           contentType:(NSString *)contentType
                         contentLength:(NSUInteger)contentLength
{
    return  [[self alloc] initWithStatusCode:statusCode etag:etag contentType:contentType contentLength:contentLength];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%ld, %@:%@ , Content-Type:%@ , Content-Length:%lu",kUFileRespHttpStatusCode,self.statusCode,kUFileRespHeaderEtag,self.etag,self.contentType,self.contentLength];
}

@end

@implementation UFHeadFile


- (instancetype)initWithStatusCode:(NSInteger)statusCode
                              etag:(NSString *)etag
                       contentType:(NSString *)contentType
                     contentLength:(NSUInteger)contentLength
                      contentRange:(NSString *)contentRange
{
    if (self = [super initWithStatusCode:statusCode etag:etag contentType:contentType contentLength:contentLength]) {
        _contentRange = contentRange;
    }
    return self;
}

+ (instancetype)instanceWithStatusCode:(NSInteger)statusCode
                                  etag:(NSString *)etag
                           contentType:(NSString *)contentType
                         contentLength:(NSUInteger)contentLength
                          contentRange:(NSString *)contentRange
{
    return [[self alloc] initWithStatusCode:statusCode etag:etag contentType:contentType contentLength:contentLength contentRange:contentRange];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%ld , %@:%@ , %@:%lu , %@:%@ , %@:%@ ",kUFileRespHttpStatusCode,self.statusCode,KUFHeadFileContentType,self.contentType,KUFHeadFileContentLength,self.contentLength,KUFHeadFileContentRange,self.contentRange,kUFileRespHeaderEtag,self.etag];
}

@end

@implementation UFPrefixFileList

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (!self) {
        return nil;
    }
    if ([dict objectForKey:@"BucketName"]) {
        _bucketName = [dict objectForKey:@"BucketName"];
    }
    if ([dict objectForKey:@"BucketId"]) {
        _bucketId = [dict objectForKey:@"BucketId"];
    }
    if ([dict objectForKey:@"NextMarker"]) {
        _nextMarker = [dict objectForKey:@"NextMarker"];
    }
    id dataSet_array = [dict objectForKey:@"DataSet"];
    if (dataSet_array && [dataSet_array isKindOfClass:[NSArray class]]) {
        NSMutableArray *mut_array = [NSMutableArray array];
        for (id ele in dataSet_array) {
            
            if ([ele isKindOfClass:[NSDictionary class]]) {
                UFPrefixFileDataSetItem *dataItem = [UFPrefixFileDataSetItem ufPrefixFileDataSetItemWithDict:ele];
                [mut_array addObject:dataItem];
            }
            
        }
        _dataSet = mut_array;
    }
    return self;
}

+ (instancetype)ufPrefixFileListResponseWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"BucketName:%@ , BucketId:%@ , NextMarker:%@ , DataSet:%@",self.bucketName,self.bucketId,self.nextMarker,self.dataSet];
}

@end

@implementation UFPrefixFileDataSetItem

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if ([dict objectForKey:@"BucketName"]) {
        _bucketName = [dict objectForKey:@"BucketName"];
    }
    if ([dict objectForKey:@"FileName"]) {
        _fileName = [dict objectForKey:@"FileName"];
    }
    if ([dict objectForKey:@"Hash"]) {
        _hashStr = [dict objectForKey:@"Hash"];
    }
    if ([dict objectForKey:@"MimeType"]) {
        _mimeType = [dict objectForKey:@"MimeType"];
    }
    if ([dict objectForKey:@"Size"]) {
        _size = [[dict objectForKey:@"Size"] integerValue];
    }
    if ([dict objectForKey:@"CreateTime"]) {
        _createTime = [[dict objectForKey:@"CreateTime"] integerValue];
    }
    if ([dict objectForKey:@"ModifyTime"]) {
        _modifyTime = [[dict objectForKey:@"ModifyTime"] integerValue];
    }
    return self;
}

+ (instancetype)ufPrefixFileDataSetItemWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"BucketName:%@ , FileName:%@ , Hash:%@ , MimeType:%@ , Size:%lu , CreateTime:%lu , ModifyTime:%lu",self.bucketName,self.fileName,self.hashStr,self.mimeType,self.size,self.createTime,self.modifyTime];
}

@end


