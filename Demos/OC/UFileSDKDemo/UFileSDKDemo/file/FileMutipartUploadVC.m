//
//  FileMutipartUploadVC.m
//  UFileAssistant
//
//  Created by ethan on 2018/11/15.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileMutipartUploadVC.h"
#import "UFMultiPartCell.h"

@interface FileMutipartUploadVC ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *prepareBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

@property (nonatomic,strong) UFDataManager *dataManager;

@end

@implementation FileMutipartUploadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    
    self.cancelBtn.enabled = NO;
    self.finishBtn.enabled = NO;
    
}

- (IBAction)onpressedButtonPrepareUpload:(id)sender {
    self.prepareBtn.enabled = NO;
    self.cancelBtn.enabled = YES;
    self.finishBtn.enabled = YES;
    
    NSString * keyName = @"testVideo.MOV";
    __block NSString * filePath = [[NSBundle mainBundle] pathForResource:@"testVideo" ofType:@"MOV"];
    
    __weak typeof(self) weakself = self;
    
    [self.fileClient prepareMultipartUploadWithKeyName:keyName mimeType:@"video/quicktime" prepareMultiPartUploadHandler:^(UFError * _Nullable ufError, UFMultiPartInfo * _Nullable multiPartInfo) {
        if (!ufError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataManager = [[UFDataManager alloc] initUFDataManagerWithUFMultiPartInfo:multiPartInfo filePath:filePath];
                [weakself.tableView reloadData];
            });
            
            NSString* msg = [NSString stringWithFormat:@" uploadId=%@\n blocksize=%lu \n bucketName=%@ \n Key=%@\n",multiPartInfo.uploadId,(long)multiPartInfo.blkSize ,multiPartInfo.bucket,multiPartInfo.key];
            [weakself showAlertWithTitle:@"Prepare Multipart Upload" andMessage:msg];
            return;
        }
        
        NSString*erMsg = @"";
        if(ufError.type == UFErrorType_Server){
            erMsg = ufError.fileClientError.errMsg;
        }else{
            erMsg = ufError.error.description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"Prepare Multipart Upload" andMessage:erMsg];
        });
    }];
}


- (IBAction)onpressedButtonCancelUpload:(id)sender {
    self.cancelBtn.enabled = NO;
    self.finishBtn.enabled = NO;
    self.prepareBtn.enabled = YES;
    __weak typeof(self) weakself = self;
    
    [self.fileClient multipartUploadAbortWithKeyName:self.dataManager.multiPartInfo.key mimeType:@"video/quicktime" uploadId:self.dataManager.multiPartInfo.uploadId uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        if (!ufError && ufUploadResponse.statusCode == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.dataManager resetTableData];
                [weakself.tableView reloadData];
                [weakself showAlertWithTitle:@"Cancel upload" andMessage:@"succeed cancel upload!"];
            });
            return;
        }
        
        NSString*erMsg = @"";
        if(ufError.type == UFErrorType_Server){
            erMsg = ufError.fileClientError.errMsg;
        }else{
            erMsg = ufError.error.description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"Cancel upload" andMessage:erMsg];
        });
        
    }];
}


- (IBAction)onpressedButtonFinishUpload:(id)sender {

    self.cancelBtn.enabled = NO;
    self.finishBtn.enabled = NO;
    self.prepareBtn.enabled = YES;
    __weak typeof(self) weakself = self;
    
    [self.fileClient multipartUploadFinishWithKeyName:self.dataManager.multiPartInfo.key mimeType:@"video/quicktime" uploadId:self.dataManager.multiPartInfo.uploadId newKeyName:NULL etags:self.dataManager.etags.allValues finishMultipartUploadHandler:^(UFError * _Nullable ufError, UFFinishMultipartUploadResponse * _Nullable finishUploadInfo) {
        if (!ufError) {
            [weakself.dataManager resetTableData];
            [weakself.tableView reloadData];
            [weakself showAlertWithTitle:@"Finish Upload" andMessage:finishUploadInfo.description];
            return;
        }
        
        NSString*erMsg = @"";
        if(ufError.type == UFErrorType_Server){
            erMsg = ufError.fileClientError.errMsg;
        }else{
            erMsg = ufError.error.description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself showAlertWithTitle:@"Finish Upload Error" andMessage:erMsg];
        });
        
    }];
    
}


- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)msg
{
    UIAlertController* alterView =  [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alterView addAction:okAction];
    [self presentViewController:alterView animated:YES completion:nil];
}

#pragma mark- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataManager.allParts) {
        return self.dataManager.allParts;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UFMultiPartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"multipartcell" forIndexPath:indexPath];
    
    [cell setDataManager:self.dataManager ufFileClient:self.fileClient PartNumber:indexPath.row];
    return cell;
}

@end
