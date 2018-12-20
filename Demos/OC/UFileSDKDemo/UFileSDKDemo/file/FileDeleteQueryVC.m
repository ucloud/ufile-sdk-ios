//
//  FileDeleteQueryVC.m
//  UFileAssistant
//
//  Created by ethan on 2018/11/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "FileDeleteQueryVC.h"


@interface FileDeleteQueryVC ()
@property (weak, nonatomic) IBOutlet UITextField *fileNameTF;
@property (weak, nonatomic) IBOutlet UITextView *resTV;



@end

@implementation FileDeleteQueryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fileNameTF.text = @"initscreen.jpg";
}

- (void)processDQHandler:(UFError *)ufError response:(id)ufResponse
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!ufError) {
            if ([ufResponse isKindOfClass:[UFQueryFileResponse class]]) {
                UFQueryFileResponse *ufQueryFileResponse = (UFQueryFileResponse *)ufResponse;
                self.resTV.text = [NSString stringWithFormat:@"查询成功，服务器返回信息--> %@",ufQueryFileResponse.description];
                return;
            }
            if (ufResponse == nil) {
                self.resTV.text = @"删除成功";
                return;
            }
           
        }
        
        if (ufError.type == UFErrorType_Sys) {
            self.resTV.text = [NSString stringWithFormat:@"删除(查询)失败，系统错误信息--> %@",ufError.error.description];
            return;
        }
        self.resTV.text = [NSString stringWithFormat:@"删除(查询)失败，服务器返回错误信息--> %@",ufError.fileClientError.description];
    });
}

- (IBAction)onpressedButtonQuery:(id)sender
{
    self.resTV.text = NULL;
    [self hideKeyboard];
    NSString *fileName  = self.fileNameTF.text;
    if (fileName.length <= 0) {
        return;
    }
     __weak typeof(self) weakself = self;
    
    [self.fileClient queryWithKeyName:fileName queryHandler:^(UFError * _Nullable ufError, UFQueryFileResponse * _Nullable ufQueryFileResponse) {
        [weakself processDQHandler:ufError response:ufQueryFileResponse];
    }];
}

- (IBAction)onpressedButtonDelete:(id)sender {
    self.resTV.text = NULL;
    [self hideKeyboard];
    NSString *fileName  = self.fileNameTF.text;
    if (fileName.length <= 0) {
        return;
    }
     __weak typeof(self) weakself = self;
    
    [self.fileClient deleteWithKeyName:fileName deleteHandler:^(UFError * _Nullable ufError, NSObject * _Nullable obj) {
        [weakself processDQHandler:ufError response:obj];
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
