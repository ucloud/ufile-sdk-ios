//
//  UFDataManager.h
//  UFileAssistant
//
//  Created by ethan on 2018/11/15.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UFileSDK/UFileSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface UFDataManager : NSObject
@property (nonatomic, strong) UFMultiPartInfo* multiPartInfo;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic,strong) NSMutableDictionary *etags;

- (instancetype)initUFDataManagerWithUFMultiPartInfo:(UFMultiPartInfo *)multiPartInfo filePath:(NSString *)filePath ;
- (NSInteger)allParts;
- (void)resetTableData;

- (NSData *)getDataForPart:(NSInteger)partNumber;
- (NSString *)writeData:(NSData *)data fileName:(NSString *)fileName;

- (void)addEtag:(NSString *)etag partNumber:(NSInteger)partNumber;
@end

NS_ASSUME_NONNULL_END
