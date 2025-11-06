//
//  FileManagerVC.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/4.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileManagerVC.h"
#import <UFileSDK/UFileSDK.h>
#import "FileUploadVC.h"
#import "FileDownloadVC.h"
#import "FileDeleteQueryVC.h"
#import "FileMutipartUploadVC.h"
#import "FileListVC.h"
#import "FileHeadFileVC.h"
#import "DataTools.h"

@interface FileManagerVC ()
@property (nonatomic,strong) UFFileClient *fileClient;
@end

@implementation FileManagerVC

- (UFFileClient *)fileClient
{
    if (!_fileClient) {
        NSString *bucketPublicKey = [DataTools getStrData:KBucketPublicKey];
        NSString *bucketPrivateKey = [DataTools getStrData:KBucketPrivateKey];
        NSString *bucketName = [DataTools getStrData:KBucketName];
        NSString *proxySuffix = [DataTools getStrData:KProfixSuffix];
        NSString *fileOperateEncryptServer = [DataTools getStrData:KFileOperateEncryptServer];
        NSString *fileAddressEncryptServer = [DataTools getStrData:KFileAddressEncryptServer];
        NSString *customDomain = [DataTools getStrData:KCustomDomain];

        BOOL hasCustomDomain = customDomain && customDomain.length > 0 && ![customDomain isEqualToString:@" "];
        BOOL hasProxySuffix = proxySuffix && proxySuffix.length > 0 && ![proxySuffix isEqualToString:@" "];
        
        if (!bucketPublicKey || !bucketName || (!hasCustomDomain && !hasProxySuffix)) {
            return nil;
        }
        UFConfig *ufConfig = [UFConfig instanceConfigWithPrivateToken:bucketPrivateKey publicToken:bucketPublicKey bucket:bucketName fileOperateEncryptServer:fileOperateEncryptServer fileAddressEncryptServer:fileAddressEncryptServer proxySuffix:proxySuffix customDomain:customDomain isHttps:YES];
        _fileClient = [UFFileClient instanceFileClientWithConfig:ufConfig];
    }
    return _fileClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"uploadFile"]) {
        FileUploadVC *uploadVC = segue.destinationViewController;
        uploadVC.fileClient = self.fileClient;
    }else if([segue.identifier isEqualToString:@"downloadFile"]){
        FileDownloadVC *downloadVC  = segue.destinationViewController;
        downloadVC.fileClient = self.fileClient;
    }else if([segue.identifier isEqualToString:@"deleteAndQueryFile"]){
        FileDeleteQueryVC *deleteQueryVC = segue.destinationViewController;
        deleteQueryVC.fileClient = self.fileClient;
    }else if([segue.identifier isEqualToString:@"multipartUploadFile"])
    {
        FileMutipartUploadVC *muVC = segue.destinationViewController;
        muVC.fileClient = self.fileClient;
    }else if([segue.identifier isEqualToString:@"FileList"])
    {
        FileListVC *fileListVC = segue.destinationViewController;
        fileListVC.fileClient = self.fileClient;
    }else if([segue.identifier isEqualToString:@"HeadFile"])
    {
        FileHeadFileVC *headFileVC = segue.destinationViewController;
        headFileVC.fileClient = self.fileClient;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
