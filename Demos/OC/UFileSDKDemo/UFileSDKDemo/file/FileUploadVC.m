//
//  FileUploadVC.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/4.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileUploadVC.h"

@interface FileUploadVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *resTV;
@property (nonatomic,strong)UIImagePickerController *imagePickerVC;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation FileUploadVC

- (UIImagePickerController *)imagePickerVC
{
    if (!_imagePickerVC) {
        _imagePickerVC = [[UIImagePickerController alloc] init];
        if (_imagePickerVC.mediaTypes.count < 2) {
            _imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            _imagePickerVC.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_imagePickerVC.sourceType];
        }
        [_imagePickerVC setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        _imagePickerVC.allowsEditing = YES;
        _imagePickerVC.delegate = self;
    }
    return _imagePickerVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)clearRestv
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resTV.text = @"";
    });
    
}

- (void)processUploadHandler:(UFError *)ufError response:(UFUploadResponse *)ufUploadResponse
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!ufError) {
            self.resTV.text = [NSString stringWithFormat:@"上传成功，服务器返回信息--> %@",ufUploadResponse.description];
            return;
        }
        
        if (ufError.type == UFErrorType_Sys) {
            self.resTV.text = [NSString stringWithFormat:@"上传失败，系统错误信息--> %@",ufError.error.description];
            return;
        }
        self.resTV.text = [NSString stringWithFormat:@"上传失败，服务器返回错误信息--> %@",ufError.fileClientError.description];
    });
}

- (void)processingUIBeforeDownload
{
    self.progressView.progress = 0.0;
    self.progressView.progressTintColor = [UIColor blueColor];
}

- (IBAction)onpressedButtonUpload:(id)sender {
    [self clearRestv];
    [self processingUIBeforeDownload];
    NSString*  fileName = @"test.jpg";
    NSString* strPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    
    [self.fileClient uploadWithKeyName:fileName filePath:strPath mimeType:@"image/jpeg" progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress.fractionCompleted animated:YES];
        });
        
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self processUploadHandler:ufError response:ufUploadResponse];
    }];
}

- (IBAction)onpressedButtonUploadHit:(id)sender {
    [self clearRestv];
    
    NSString*  fileName = @"initscreen.jpg";
    NSString* strPath = [[NSBundle mainBundle] pathForResource:@"initscreen" ofType:@"jpg"];
    
    [self.fileClient hitUploadWithKeyName:fileName filePath:strPath mimeType:@"image/jpeg"  uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self processUploadHandler:ufError response:ufUploadResponse];
    }];
}

- (IBAction)onpressedButtonUploadFileWithFileMethod:(id)sender {
    [self clearRestv];
    [self processingUIBeforeDownload];
    NSString *fileName = @"123.jpg";
    NSString* strPath = [[NSBundle mainBundle] pathForResource:@"initscreen" ofType:@"jpg"];
    [self.fileClient uploadWithKeyName:fileName filePath:strPath mimeType:@"image/jpeg" progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress.fractionCompleted animated:YES];
        });
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
       [self processUploadHandler:ufError response:ufUploadResponse];
    }];
}

- (IBAction)onpressedButtonUploadNSData:(id)sender {
    [self clearRestv];
    [self processingUIBeforeDownload];
    NSString *key = @"hello";
    NSData *data  = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
    [self.fileClient uploadWithKeyName:key fileData:data mimeType:NULL progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress.fractionCompleted animated:YES];
        });
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
         [self processUploadHandler:ufError response:ufUploadResponse];
    }];
}

- (IBAction)onpressedButtonFromAlbum:(id)sender {
    [self clearRestv];
    [self presentViewController:self.imagePickerVC animated:YES completion:^{
        
    }];
}

#pragma mark --UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage]; // 获取编辑后的图片
    NSData *imageData  = UIImagePNGRepresentation(image);
    NSString *keyName  = @"photo.jpg";
    [self.fileClient uploadWithKeyName:keyName fileData:imageData mimeType:@"image/jpeg" progress:^(NSProgress * _Nonnull progress) {
        
    } uploadHandler:^(UFError * _Nullable ufError, UFUploadResponse * _Nullable ufUploadResponse) {
        [self processUploadHandler:ufError response:ufUploadResponse];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
