//
//  FileDownloadVC.m
//  UFileAssistant
//
//  Created by ethan on 2018/11/8.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileDownloadVC.h"

@interface FileDownloadVC ()
@property (weak, nonatomic) IBOutlet UITextField *fileNameText;
@property (weak, nonatomic) IBOutlet UITextField *rangeBeginText;
@property (weak, nonatomic) IBOutlet UITextField *rangeEndText;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextView *resTV;

@property (nonatomic,copy) NSString* strDownloadPath;


@end

@implementation FileDownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fileNameText.text = @"initscreen.jpg";
}

- (void)processDownloadHandler:(UFError *)ufError response:(UFDownloadResponse *)ufDownloadResponse
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!ufError) {
            if (ufDownloadResponse.data) {
                [self.imgView setImage:[UIImage imageWithData:ufDownloadResponse.data]];
            }else if(ufDownloadResponse.destPath){
                NSData *imgData  = [[NSData alloc] initWithContentsOfFile:self.strDownloadPath];
                [self.imgView setImage:[UIImage imageWithData:imgData]];
            }
            self.resTV.text = [NSString stringWithFormat:@"下载成功，服务器返回信息--> %@",ufDownloadResponse.description];
            return;
        }
        
        if (ufError.type == UFErrorType_Sys) {
            self.resTV.text = [NSString stringWithFormat:@"下载失败，系统错误信息--> %@",ufError.error.description];
            return;
        }
        self.resTV.text = [NSString stringWithFormat:@"下载失败，服务器返回错误信息--> %@",ufError.fileClientError.description];
    });
}

- (IBAction)onpressedButtonDownload:(id)sender {
    self.resTV.text = NULL;
    
    [self processingUIBeforeDownload];
    NSString *fileName  = self.fileNameText.text;
    UFDownloadFileRange range = [self validUserInputRange];
    
    [self.fileClient downloadWithKeyName:fileName downloadRange:range progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progress setProgress:progress.fractionCompleted  animated:YES];
        });
    } downloadHandler:^(UFError * _Nullable ufError, UFDownloadResponse * _Nullable ufDownloadResponse) {
        [self processDownloadHandler:ufError response:ufDownloadResponse];
        
    }];
}

- (IBAction)onpressedButtonDownloadToFile:(id)sender {
    self.resTV.text = NULL;
    [self processingUIBeforeDownload];
    NSString *fileName  = self.fileNameText.text;
    UFDownloadFileRange range = [self validUserInputRange];
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _strDownloadPath = [NSString stringWithFormat:@"%@/%@",path.firstObject,fileName];
    
    [self.fileClient downloadWithKeyName:fileName destinationPath:_strDownloadPath downloadRange:range progress:^(NSProgress * _Nonnull progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progress setProgress:progress.fractionCompleted  animated:YES];
        });
    } downloadHandler:^(UFError * _Nullable ufError, UFDownloadResponse * _Nullable ufDownloadResponse) {
        [self processDownloadHandler:ufError response:ufDownloadResponse];
    }];
}

- (void)processingUIBeforeDownload
{
    [self hideKeyBoard];
    
    [self.imgView setImage:NULL];
    self.progress.progress = 0.0;
    self.progress.progressTintColor = [UIColor blueColor];
}

- (UFDownloadFileRange)validUserInputRange
{
    NSString *rangeBegin  = self.rangeBeginText.text;
    NSString *rangEnd  = self.rangeEndText.text;
    UFDownloadFileRange range = {0,0};
    if (rangeBegin.length > 0 && rangEnd.length > 0) {
        range.begin = [rangeBegin integerValue];
        range.end = [rangEnd integerValue];
    }
    return range;
}

- (void)hideKeyBoard
{
    if ([self.fileNameText isFirstResponder]) {
        [self.fileNameText resignFirstResponder];
    }
    if ([self.rangeBeginText isFirstResponder]) {
        [self.rangeBeginText resignFirstResponder];
    }
    if ([self.rangeEndText isFirstResponder]) {
        [self.rangeEndText resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyBoard];
}




@end
