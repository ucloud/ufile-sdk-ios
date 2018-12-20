//
//  UFMultiPartCell.h
//  UFileAssistant
//
//  Created by ethan on 2018/11/15.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UFileSDK/UFileSDK.h>
#import "UFDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UFMultiPartCell : UITableViewCell
@property (nonatomic, assign) NSInteger           partNumber;
@property (nonatomic, strong) UFFileClient  *ufClient;

-(void)setDataManager:(UFDataManager *)dataManager ufFileClient:(UFFileClient *)flientClient PartNumber:(NSInteger)partnumber;


@end

NS_ASSUME_NONNULL_END
