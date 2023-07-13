//
//  UFMultiPartCell.m
//  UFileAssistant
//
//  Created by ethan on 2018/11/15.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFMultiPartCell.h"

@interface UFMultiPartCell()
@property (assign, nonatomic) BOOL   bUploaded;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *btnUpload;
@property (nonatomic, strong) UFDataManager* dataManager;

@end

@implementation UFMultiPartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.progress.progress = .0;
    self.progress.progressTintColor = [UIColor blueColor];
    
}

-(void)setDataManager:(UFDataManager *)dataManager ufFileClient:(UFFileClient *)flientClient PartNumber:(NSInteger)partnumber
{
    self.dataManager = dataManager;
    self.ufClient = flientClient;
    self.partNumber = partnumber;
    
    NSString *etag = [self.dataManager.etags objectForKey:[NSString stringWithFormat:@"%ld",partnumber]];
    if (!etag) {
        self.progress.progress = .0;
        self.btnUpload.enabled = YES;
    }else{
        self.progress.progress = 1;
        self.btnUpload.enabled = NO;
    }
//    if (!self.bUploaded) {
//        self.progress.progress = .0;
//        self.btnUpload.enabled = YES;
//    }
}

- (IBAction)onpressedButtonUpload:(id)sender {
    __weak typeof(self) weakself = self;
    
//    NSLog(@"%@,---data leng:%d",self.dataManager.multiPartInfo,(int)([self.dataManager getDataForPart:self.partNumber].length) );
    
    /*
     // 支持后台上传
     NSData *data = [self.dataManager getDataForPart:self.partNumber];
     NSString *filePath = [self.dataManager writeData:data fileName:@"video"];
     
     [self.ufClient startMultipartUploadWithKeyName:self.dataManager.multiPartInfo.key mimeType:@"video/quicktime" uploadId:self.dataManager.multiPartInfo.uploadId partIndex:self.partNumber dataLength: [data length] filePath:filePath progress:^(NSProgress * _Nonnull progress) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakself.progress setProgress:progress.fractionCompleted animated:YES];
         });
     } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
         if (!ufError) {
             weakself.bUploaded = YES;
             weakself.btnUpload.enabled = NO;
             [self.dataManager addEtag:ufUploadResponse.etag partNumber:ufUploadResponse.partNumber];
            // 上传成功，需要清理本地存储的临时文件
             return;
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             weakself.progress.progressTintColor = [UIColor redColor];
         });
     }];
     */
    
    [self.ufClient startMultipartUploadWithKeyName:self.dataManager.multiPartInfo.key mimeType:@"video/quicktime" uploadId:self.dataManager.multiPartInfo.uploadId partIndex:self.partNumber fileData:[self.dataManager getDataForPart:self.partNumber] progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.progress setProgress:progress.fractionCompleted animated:YES];
        });
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        if (!ufError) {
            weakself.bUploaded = YES;
            weakself.btnUpload.enabled = NO;
            [self.dataManager addEtag:ufUploadResponse.etag partNumber:ufUploadResponse.partNumber];
            
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakself.progress.progressTintColor = [UIColor redColor];
        });
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
