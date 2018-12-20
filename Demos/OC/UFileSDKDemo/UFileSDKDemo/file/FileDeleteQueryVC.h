//
//  FileDeleteQueryVC.h
//  UFileAssistant
//
//  Created by ethan on 2018/11/9.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UFileSDK/UFileSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileDeleteQueryVC : UIViewController
@property (nonatomic,strong) UFFileClient *fileClient;
@end

NS_ASSUME_NONNULL_END
