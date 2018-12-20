//
//  QRCodeVC.m
//  UFileSDKDemo
//
//  Created by ethan on 2018/12/5.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "QRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "UFileSDKDemoConst.h"
#import "DataTools.h"

@interface QRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *scanView;

@property (nonatomic,strong) AVCaptureDevice *m_device;
@property (nonatomic,strong) AVCaptureSession *m_session;
@property (nonatomic,strong) AVCaptureMetadataOutput *metadata_output;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *m_previewLayer;

@end

@implementation QRCodeVC

- (AVCaptureSession *)m_session
{
    if (!_m_session) {
        NSError *error;
        _m_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input =[AVCaptureDeviceInput deviceInputWithDevice:_m_device error:&error];
        if (!input) {
            NSLog(@"%@",[error localizedDescription]);
        }
        _m_session = [[AVCaptureSession alloc] init];
        if ([_m_session canAddInput:input]) {
            [_m_session addInput:input];
        }
        _metadata_output = [[AVCaptureMetadataOutput alloc] init];
        if ([_m_session canAddOutput:_metadata_output]) {
            [_m_session addOutput:_metadata_output];
        }
        
        dispatch_queue_t videoQueue = dispatch_queue_create("videoQueue", NULL);
        [_metadata_output setMetadataObjectsDelegate:self queue:videoQueue];
        
        // 设置元数据类型
        [_metadata_output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        
        _m_previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_m_session];
        [_m_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_m_previewLayer setFrame:self.scanView.layer.bounds];
        [self.scanView.layer insertSublayer:_m_previewLayer atIndex:0];
    }
    return _m_session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startPreview];
}


- (void)startPreview
{
    if (![self.m_session isRunning]) {
        [self.m_session startRunning];
    }
}

- (void)stopPreview
{
    if ([self.m_session isRunning]) {
        [self.m_session stopRunning];
    }
}

#pragma mark -AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects == nil || [metadataObjects count] <= 0) {
        return;
    }
    
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
    NSString *result;
    if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
        result = metadataObj.stringValue;
    }else{
        NSLog(@"Your scanning is not QR code..");
        return;
    }
    [self stopPreview];
    result = metadataObj.stringValue;
    [self performSelectorOnMainThread:@selector(dealwithScanResult:) withObject:result waitUntilDone:NO];
   
}

- (void)dealwithScanResult:(NSString *)result
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself stopPreview];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"扫描结果" message:result preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"填充" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself parseJsonStrAndStore:result];
            [weakself.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:okAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"重扫" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakself startPreview];
        }];
        [alert addAction:cancelAction];
        
        [weakself presentViewController:alert animated:YES completion:nil];
    });
    NSLog(@"%@",result);
    
}

- (void)parseJsonStrAndStore:(NSString *)jsonStr
{
    if (!jsonStr) {
        NSLog(@"scan QR Code, jsonStr is nil..");
        return;
    }

    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
    if (jsonError) {
        NSLog(@"scan QR Code, parse jsonStr error ,error info-->%@",jsonError.description);
        return;
    }
    
    if (dict) {
        NSArray *keys = @[KBucketPublicKey,KBucketPrivateKey,KProfixSuffix,KBucketName,KFileOperateEncryptServer,KFileAddressEncryptServer];
        for (NSString *key in keys) {
            [DataTools storeStrData:[dict objectForKey:key] keyName:key];
        }
    }
        

}

@end
