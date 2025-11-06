//
//  SettingVC.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/4.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "SettingVC.h"
#import "DataTools.h"
#import <UFileSDK/UFileSDK.h>

@interface SettingVC ()
@property (weak, nonatomic) IBOutlet UITextView *bucketPublicKeyTV;
@property (weak, nonatomic) IBOutlet UITextView *bucketPrivateKeyTV;
@property (weak, nonatomic) IBOutlet UITextView *proxySuffixTV;
@property (weak, nonatomic) IBOutlet UITextField *bucketTF;
@property (weak, nonatomic) IBOutlet UITextView *fOptEncryptServerTV;
@property (weak, nonatomic) IBOutlet UITextView *fAddressEncryptServerTV;
@property (weak, nonatomic) IBOutlet UITextView *customDomainTV;


@property (weak, nonatomic) IBOutlet UILabel *versionLabel;


@end

@implementation SettingVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"SDK v%@ ; APP v%@.%@",[[UFSDKManager shareInstance] version],appVersion,appBuild];
}

- (IBAction)onpressedButtonApplay:(id)sender {
    [self hideKeyBoard];
    [self storeData];
    [self restartApp];
    
}


- (IBAction)onpressedButtonGuide:(id)sender {
    [self hideKeyBoard];
    
}

- (void)restartApp
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"The setting is successful and takes effect after restarting" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        exit(0);
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showData
{
    self.bucketPublicKeyTV.text =    [DataTools getStrData:KBucketPublicKey];
    self.bucketPrivateKeyTV.text=    [DataTools getStrData:KBucketPrivateKey];
    self.proxySuffixTV.text     =    [DataTools getStrData:KProfixSuffix];
    self.bucketTF.text          =    [DataTools getStrData:KBucketName];
    self.fOptEncryptServerTV.text =  [DataTools getStrData:KFileOperateEncryptServer];
    self.fAddressEncryptServerTV.text = [DataTools getStrData:KFileAddressEncryptServer];
    self.customDomainTV.text    =    [DataTools getStrData:KCustomDomain];
}

- (void)storeData
{
    NSDictionary *inputDict = @{KBucketPublicKey:self.bucketPublicKeyTV,KBucketPrivateKey:self.bucketPrivateKeyTV,KProfixSuffix:self.proxySuffixTV,KBucketName:self.bucketTF,KFileOperateEncryptServer:self.fOptEncryptServerTV,KFileAddressEncryptServer:self.fAddressEncryptServerTV,KCustomDomain:self.customDomainTV};
    NSArray *keys = inputDict.allKeys;
    for (NSUInteger i = 0; i < keys.count; i++) {
        if([[inputDict objectForKey:keys[i]] isKindOfClass:[UITextField class]])
        {
            UITextField *tf = (UITextField *)[inputDict objectForKey:keys[i]];
            if (tf.text) {
                [DataTools storeStrData:tf.text keyName:keys[i]];
            }else{
                [DataTools storeStrData:@"" keyName:keys[i]];
            }
        }
        
        if([[inputDict objectForKey:keys[i]] isKindOfClass:[UITextView class]])
        {
            UITextView *tv = (UITextView *)[inputDict objectForKey:keys[i]];
            if (tv.text) {
                [DataTools storeStrData:tv.text keyName:keys[i]];
            }else{
                [DataTools storeStrData:@"" keyName:keys[i]];
            }
        }
    }
}

- (void)hideKeyBoard
{
    
    NSArray *inputTextAire = @[self.bucketPublicKeyTV,self.bucketPrivateKeyTV,self.proxySuffixTV,self.bucketTF,self.fOptEncryptServerTV,self.fAddressEncryptServerTV,self.customDomainTV];
    for (id input in inputTextAire) {
        if ([input isFirstResponder]) {
            [input resignFirstResponder];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideKeyBoard];
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
