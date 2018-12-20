//
//  FileListVC.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/5.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileListVC.h"

@interface FileListVC ()
@property (weak, nonatomic) IBOutlet UITextField *prefixTF;
@property (weak, nonatomic) IBOutlet UITextField *markerTF;
@property (weak, nonatomic) IBOutlet UITextField *limitTF;
@property (weak, nonatomic) IBOutlet UITextView *resTV;

@end

@implementation FileListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)processFileListHandler:(UFError *)ufError response:(UFPrefixFileList *)ufPrefixFileList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!ufError) {
            self.resTV.text = [NSString stringWithFormat:@"获取列表成功，服务器返回信息--> %@",ufPrefixFileList.description];
            return;
        }
        
        if (ufError.type == UFErrorType_Sys) {
            self.resTV.text = [NSString stringWithFormat:@"获取列表失败，系统错误信息--> %@",ufError.error.description];
            return;
        }
        self.resTV.text = [NSString stringWithFormat:@"获取列表失败，服务器返回错误信息--> %@",ufError.fileClientError.description];
    });
}

- (IBAction)onpressedButtonFileList:(id)sender {
    [self hideKeyboard];
    self.resTV.text = NULL;
    NSInteger limit = 0;
    if (self.limitTF.text) {
        limit = [self.limitTF.text integerValue];
    }
    
    __weak typeof(self) weakself = self;
    [_fileClient prefixFileListWithPrefix:self.prefixTF.text marker:self.markerTF.text limit:limit prefixFileListHandler:^(UFError * _Nullable ufError, UFPrefixFileList * _Nullable ufPrefixFileList) {
        [weakself processFileListHandler:ufError response:ufPrefixFileList];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    if ([self.prefixTF isFirstResponder]) {
        [self.prefixTF resignFirstResponder];
    }
    if ([self.markerTF isFirstResponder]) {
        [self.markerTF resignFirstResponder];
    }
    if ([self.limitTF isFirstResponder]) {
        [self.limitTF resignFirstResponder];
    }
    
}


@end
