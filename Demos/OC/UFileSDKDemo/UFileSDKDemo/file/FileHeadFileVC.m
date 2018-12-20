//
//  FileHeadFileVC.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/5.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileHeadFileVC.h"

@interface FileHeadFileVC ()
@property (weak, nonatomic) IBOutlet UITextField *fileNameTF;
@property (weak, nonatomic) IBOutlet UITextView *resTV;

@end

@implementation FileHeadFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)processHeadFileHandler:(UFError *)ufError response:(UFHeadFile *)ufHeadFile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!ufError) {
            self.resTV.text = [NSString stringWithFormat:@"获取文件的HeadFile成功，服务器返回信息--> %@",ufHeadFile.description];
            return;
        }
        
        if (ufError.type == UFErrorType_Sys) {
            self.resTV.text = [NSString stringWithFormat:@"获取文件的HeadFile失败，系统错误信息--> %@",ufError.error.description];
            return;
        }
        self.resTV.text = [NSString stringWithFormat:@"获取文件的HeadFile失败，服务器返回错误信息--> %@",ufError.fileClientError.description];
    });
}

- (IBAction)onPressedButtonFileHeadFile:(id)sender {
    [self hideKeyboard];
    self.resTV.text = NULL;
    __weak typeof(self) weakself = self;
    
    [_fileClient headFileWithKeyName:self.fileNameTF.text success:^(UFError * _Nullable ufError, UFHeadFile * _Nullable ufHeadFile) {
        [weakself processHeadFileHandler:ufError response:ufHeadFile];
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    if ([self.fileNameTF isFirstResponder]) {
        [self.fileNameTF resignFirstResponder];
    }
    
}


@end
