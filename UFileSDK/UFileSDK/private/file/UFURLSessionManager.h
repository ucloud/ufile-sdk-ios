//
//  UFURLSessionManager.h
//  UFileSDK
//
//  Created by ethan on 2018/11/2.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//extern NSString* _Nullable UFilePercentEscapedStringFromString(NSString* _Nonnull);


@interface UFURLSessionManager : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

/**
 The dispatch queue for `completionBlock`. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t uf_completionQueue;
/**
 The dispatch group for `completionBlock`. If `NULL` (default), a private dispatch group is used.
 */
@property (nonatomic, strong, nullable) dispatch_group_t uf_completionGroup;



- (NSURLSessionUploadTask* _Nullable)uploadTaskWithRequest:(nonnull NSURLRequest*)request
                                                  fromFile:(NSURL*)fileURL
                                                  progress:(void (^ _Nullable)(NSProgress* _Nonnull)) uploadProgressBlock
                                         completionHandler:(void (^ _Nullable)(NSURLResponse* _Nonnull response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

- (NSURLSessionDownloadTask *)startBackgroundDownloadTask:(NSData *)resumeData
                                              destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                 progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                        completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

- (NSURLSessionDownloadTask *)recoverDownloadTask:(NSData *)resumeData
                                              destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                 progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

- (void)removeDelegateForTask:(NSURLSessionTask *)task;

@end

NS_ASSUME_NONNULL_END
