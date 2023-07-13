//
//  UFDataManager.m
//  UFileAssistant
//
//  Created by ethan on 2018/11/15.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFDataManager.h"
@interface UFDataManager()
@property (nonatomic,strong) NSData *fileData;
@property (nonatomic,assign) NSInteger fileSize;
@property (nonatomic,assign) NSInteger allParts;
@end

@implementation UFDataManager

- (instancetype)initUFDataManagerWithUFMultiPartInfo:(UFMultiPartInfo *)multiPartInfo filePath:(NSString *)filePath 
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.multiPartInfo = multiPartInfo;
    self.filePath = filePath;
    self.fileData = [NSData dataWithContentsOfFile:self.filePath];
    NSDictionary *fileAttributes =  [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil];
    self.fileSize = (NSInteger)[fileAttributes fileSize];
    _allParts = (self.fileSize + self.multiPartInfo.blkSize - 1)/self.multiPartInfo.blkSize;

    self.etags = [NSMutableDictionary dictionary];
    return self;
}

- (NSInteger)allParts
{
    return _allParts;
}

- (void)resetTableData
{
    _multiPartInfo = nil;
    _filePath = NULL;
    _etags = [NSMutableDictionary dictionary];
    _allParts = 0;
}

- (NSData *)getDataForPart:(NSInteger)partNumber
{
    if (partNumber >= self.allParts) {
        return nil;
    }
    
    NSInteger loc = partNumber*self.multiPartInfo.blkSize;
    NSInteger  length = self.multiPartInfo.blkSize;
    NSInteger totalen = loc + length;
    if (totalen > self.fileSize) {
        length = self.fileSize - loc;
    }
    return [self.fileData subdataWithRange:NSMakeRange(loc, length)];
}

- (NSString *)writeData:(NSData *)data fileName:(NSString *)fileName {
    NSString *tempDirectory = NSTemporaryDirectory();
    NSString *tempDataDirectory = [tempDirectory stringByAppendingPathComponent:@"tempData"];
    // 创建文件夹
    NSError *error;
    NSString *filePath;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:tempDataDirectory
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&error];
    if (success) {
        // 创建文件路径
        filePath = [tempDataDirectory stringByAppendingPathComponent:fileName];
        // 将数据写入文件
        success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        if (success) {
            return filePath;
        }
    }
    return nil;
}

- (void)addEtag:(NSString *)etag partNumber:(NSInteger)partNumber
{
    [self.etags setObject:etag forKey:[NSString stringWithFormat:@"%ld",partNumber]];
}
@end
