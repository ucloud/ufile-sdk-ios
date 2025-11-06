//
//  UFFileClientTests.m
//  UFileSDKTests
//
//  Created by ethan on 2018/11/22.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UFileSDK/UFileSDK.h>
@interface UFFileClientTests : XCTestCase
@property (nonatomic,strong) UFFileClient *fileClient;
@property (nonatomic,strong) XCTestExpectation *exception;
@end

@implementation UFFileClientTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    /***
     // 使用本地签名，不推荐使用这种方式
     UFConfig *ufConfig = [UFConfig instanceConfigWithPrivateToken:@"bucket私钥" publicToken:@"bucket公钥" bucket:@"bucket名称" fileOperateEncryptServer:nil fileAddressEncryptServer:nil proxySuffix:@"域名后缀" customDomain:nil isHttps:YES];
     */
    
    // 使用服务器签名，推荐使用
    UFConfig *ufConfig = [UFConfig instanceConfigWithPrivateToken:nil publicToken:@"bucket公钥" bucket:@"bucket名称" fileOperateEncryptServer:@"文件操作签名服务器" fileAddressEncryptServer:@"获取文件URL的签名服务器" proxySuffix:@"域名后缀" customDomain:nil isHttps:YES];
    
    _fileClient = [UFFileClient instanceFileClientWithConfig:ufConfig];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (XCTestExpectation *)exception
{
    if (!_exception) {
        _exception = [self expectationWithDescription:@"Expectation"];
    }
    return _exception;
}

- (void)outputTestResWithModel:(NSString *)model ufError:(UFError *)ufError responseObj:(NSObject *)obj needFulfill:(BOOL)needFulfill
{
    if (needFulfill) {
        [self.exception fulfill];
    }
    XCTAssertNil(ufError,@"test SDK interface:  Pass");
    
    if (!ufError) {
        NSLog(@"%@, 成功 , 信息： %@",model,obj);
        return;
    }
    ufError.type == UFErrorType_Server ? NSLog(@"%@, 失败 , 信息： %@",model,ufError.fileClientError) :
    NSLog(@"%@, 失败 , 信息： %@",model,ufError.error.description);
}

#pragma mark- 文件上传

/**
 文件上传，以路径方式
 */
- (void)testFileUpload_Path
{
    [self exception];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"test" ofType:@"jpg"];
    
    [_fileClient uploadWithKeyName:@"test.jpg" filePath:strPath mimeType:@"image/jpeg" progress:^(NSProgress * _Nonnull progress) {
        
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self outputTestResWithModel:@"文件上传(文件路径方式)" ufError:ufError responseObj:ufUploadResponse  needFulfill:YES];
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}


/**
 文件上传，以NSData方式
 */
- (void)testFileUPload_data
{
    [self exception];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"test" ofType:@"jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:strPath];

    [_fileClient uploadWithKeyName:@"test_data.jpg" fileData:fileData mimeType:@"image/jpeg" progress:^(NSProgress * _Nonnull progress) {
        
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self outputTestResWithModel:@"文件上传(NSData方式)" ufError:ufError responseObj:ufUploadResponse  needFulfill:YES];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}

#pragma mark- 文件秒传

/**
 文件秒传，以路径方式
 */
- (void)testHitUpload_Path
{
    [self exception];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"test" ofType:@"jpg"];
    
    [_fileClient hitUploadWithKeyName:@"test_path.jpg" filePath:strPath mimeType:@"image/jpge" uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self outputTestResWithModel:@"文件秒传(路径方式)" ufError:ufError responseObj:ufUploadResponse  needFulfill:YES];
    }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}

/**
 文件秒传，以NSData方式
 */
- (void)testHitUpload_Data
{
    [self exception];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"test" ofType:@"jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:strPath];

    [_fileClient hitUploadWithKeyName:@"test_data.jpg" fileData:fileData mimeType:@"image/jpeg" uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self outputTestResWithModel:@"文件秒传(NSData方式)" ufError:ufError responseObj:ufUploadResponse  needFulfill:YES];
     }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}

#pragma mark- 分片上传
/**
 为了避免逻辑复杂，此处我们使用的是一个小文件进行测试的，该文件只被分成一片即可上传成功
 */
- (void)testMultipartUpload
{
    [self exception];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"test" ofType:@"jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:strPath];
    
    [_fileClient prepareMultipartUploadWithKeyName:@"test.jpg" mimeType:@"image/jpeg" prepareMultiPartUploadHandler:^(UFError * _Nullable ufError, UFMultiPartInfo * _Nullable multiPartInfo) {
        [self outputTestResWithModel:@"准备分片上传" ufError:ufError responseObj:multiPartInfo  needFulfill:NO];
       
        if (!ufError) {
            [self->_fileClient startMultipartUploadWithKeyName:@"test.jpg" mimeType:@"image/jpeg" uploadId:multiPartInfo.uploadId partIndex:0 fileData:fileData progress:^(NSProgress * _Nonnull progress) {
                
            } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
                
                [self outputTestResWithModel:@"开始分片上传" ufError:ufError responseObj:ufUploadResponse  needFulfill:NO];
                if (!ufError) {
                    [self->_fileClient multipartUploadFinishWithKeyName:@"test.jpg" mimeType:@"image/jpeg" uploadId:multiPartInfo.uploadId newKeyName:nil etags:@[ufUploadResponse.etag] finishMultipartUploadHandler:^(UFError * _Nullable ufError, UFFinishMultipartUploadResponse * _Nullable finishUploadInfo) {
                        [self outputTestResWithModel:@"结束分片上传" ufError:ufError responseObj:finishUploadInfo  needFulfill:YES];
                    }];
                }
                
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];

}

#pragma mark- 文件下载

/**
 直接下载
 */
- (void)testFileDownload_data
{
    [self exception];
    UFDownloadFileRange range = {0,0};
    
    [_fileClient downloadWithKeyName:@"test.jpg" downloadRange:range progress:^(NSProgress * _Nonnull progress) {
        
    } downloadHandler:^(UFError * _Nullable ufError, UFDownloadResponse * _Nullable ufDownloadResponse) {
        [self outputTestResWithModel:@"文件下载" ufError:ufError responseObj:ufDownloadResponse  needFulfill:YES];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}


/**
 下载文件到制定目录
 */
- (void)testFileDownload_path
{
    [self exception];
    UFDownloadFileRange range = {0,0};

    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* strDownloadPath = [NSString stringWithFormat:@"%@/test.jpg",path.firstObject];
    [_fileClient downloadWithKeyName:@"test.jpg" destinationPath:strDownloadPath downloadRange:range progress:^(NSProgress * _Nonnull progress) {
        
    } downloadHandler:^(UFError * _Nullable ufError, UFDownloadResponse * _Nullable ufDownloadResponse) {
        [self outputTestResWithModel:@"文件下载(指定目录)" ufError:ufError responseObj:ufDownloadResponse  needFulfill:YES];
    }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}


- (void)testBigFileDownload_path
{
    [self exception];
    UFDownloadFileRange range = {0,0};
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* strDownloadPath = [NSString stringWithFormat:@"%@/testVideo.MOV",path.firstObject];
    [_fileClient downloadWithKeyName:@"testVideo.MOV" destinationPath:strDownloadPath downloadRange:range progress:^(NSProgress * _Nonnull progress) {
        
    } downloadHandler:^(UFError * _Nullable ufError, UFDownloadResponse * _Nullable ufDownloadResponse) {
        [self outputTestResWithModel:@"文件下载(指定目录)" ufError:ufError responseObj:ufDownloadResponse  needFulfill:YES];
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark- 查询文件
- (void)testQueryFile
{
    [self exception];
    [_fileClient queryWithKeyName:@"test.jpg" queryHandler:^(UFError * _Nullable ufError, UFQueryFileResponse * _Nullable ufQueryFileResponse) {
        [self outputTestResWithModel:@"查询文件" ufError:ufError responseObj:ufQueryFileResponse  needFulfill:YES];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark- 删除文件
- (void)testDeleteFile
{
    [self exception];
    [_fileClient deleteWithKeyName:@"test.jpg" deleteHandler:^(UFError * _Nullable ufError, NSObject * _Nullable obj) {
       [self outputTestResWithModel:@"文件删除" ufError:ufError responseObj:obj  needFulfill:YES];
    }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}

#pragma mark- 获取Bucket中的文件列表
- (void)testGetFileList
{
    [self exception];
    [_fileClient prefixFileListWithPrefix:NULL marker:NULL limit:5 prefixFileListHandler:^(UFError * _Nullable ufError, UFPrefixFileList * _Nullable ufPrefixFileList) {
        [self outputTestResWithModel:@"获取Bucket中的文件列表" ufError:ufError responseObj:ufPrefixFileList  needFulfill:YES];
    }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}

#pragma mark- 获取文件私有地址
- (void)testGetPrivateURL
{
    NSString *url_str = [_fileClient filePrivateUrlWithKeyName:@"test.jpg" expiresTime:3600];
    XCTAssertNotNil(url_str,@"Pass");
    NSLog(@"获取文件私有地址: %@",url_str);
}

- (void)testGetPublicURL
{
    [_fileClient filePublicUrlWithKeyName:@"test.jpg"];
    NSString *url_str = [_fileClient filePublicUrlWithKeyName:@"test.jpg"];
    XCTAssertNotNil(url_str,@"Pass");
    NSLog(@"获取文件公有地址: %@",url_str);
}

#pragma mark- 获取文件HeadFile
- (void)testGetHeadFile
{
    [self exception];
    [_fileClient headFileWithKeyName:@"testVideo.MOV" success:^(UFError * _Nullable ufError, UFHeadFile * _Nullable ufHeadFile) {
        [self outputTestResWithModel:@"获取文件HeadFile" ufError:ufError responseObj:ufHeadFile  needFulfill:YES];
    }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}

#pragma mark- 返回文件的Etag
- (void)testFileEtag
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"initscreen" ofType:@"jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:strPath];
    if (!fileData) {
        NSLog(@"文件的Etag, file data 为空..");
    }
    NSString *etag = [_fileClient fileEtagWithFileData:fileData];
    NSLog(@"文件的Etag， 文件：%@ ， Etag：%@",strPath,etag);
}

#pragma mark- 对比文件的Etag
- (void)testCompireFileEtag
{
    [self exception];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString* strPath = [bundle pathForResource:@"initscreen" ofType:@"jpg"];
    NSData *fileData = [NSData dataWithContentsOfFile:strPath];
    
    [_fileClient compireFileEtagWithRemoteKeyName:@"initscreen.jpg" localFileData:fileData compireResults:^(BOOL result) {
        [self.exception fulfill];
        if (result) {
            NSLog(@"对比文件的Etag， 对比成功");
            return;
        }
         NSLog(@"对比文件的Etag， 对比失败");
    }];

    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {

    }];
}


@end
