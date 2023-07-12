//
//  UFURLSessionManager.m
//  UFileSDK
//
//  Created by ethan on 2018/11/2.
//  Copyright © 2018 ucloud. All rights reserved.
//

#import "UFURLSessionManager.h"
#import <objc/runtime.h>
#import "UFTools.h"


#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif


static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue =
        dispatch_queue_create("com.ucloud.mobile.ufilesdk.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return queue;
}

static void url_session_manager_create_task_safely(dispatch_block_t block) {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        // Fix of bug
        // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
        // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
        dispatch_sync(url_session_manager_creation_queue(), block);
    } else {
        block();
    }
}

static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.ucloud.mobile.ufilesdk.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return queue;
}

static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t queueGroup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queueGroup = dispatch_group_create();
    });
    
    return queueGroup;
}

typedef NSURL * (^AFURLSessionDownloadTaskDidFinishDownloadingBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^AFURLSessionDownloadTaskDidWriteDataBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^AFURLSessionDownloadTaskDidResumeBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *);

typedef void (^AFURLSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);
@interface UFURLSessionManagerTaskDelegate: NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>
- (instancetype)initWithTask:(NSURLSessionTask *)task;
@property (nonatomic, weak) UFURLSessionManager *manager;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSProgress *uploadProgress;
@property (nonatomic, strong) NSProgress *downloadProgress;
@property (nonatomic, copy) NSURL *downloadFileURL;
@property (nonatomic, copy) AFURLSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock uploadProgressBlock;
@property (nonatomic, copy) AFURLSessionTaskProgressBlock downloadProgressBlock;
@property (nonatomic, copy) AFURLSessionTaskCompletionHandler completionHandler;
@end

@implementation UFURLSessionManagerTaskDelegate

- (instancetype)init
{
    self  = [super init];
    if (!self) {
        return nil;
    }
    
    self.mutableData = [NSMutableData data];
    self.uploadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    self.uploadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    
    self.downloadProgress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    self.downloadProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
    return self;
}

- (void)setupProgressForTask:(NSURLSessionTask *)task {
    __weak __typeof__(task) weakTask = task;
    
    self.uploadProgress.totalUnitCount = task.countOfBytesExpectedToSend;
    self.downloadProgress.totalUnitCount = task.countOfBytesExpectedToReceive;
    
    
    for (NSProgress *progress in @[self.uploadProgress,self.downloadProgress]) {
        [progress setCancellable:YES];
        [progress setCancellationHandler:^{
            __typeof__(weakTask) strongTask = weakTask;
            [strongTask cancel];
        }];
        [progress setPausable:YES];
        [progress setPausingHandler:^{
            __typeof__(weakTask) strongTask = weakTask;
            [strongTask suspend];
        }];
        if( [progress respondsToSelector:@selector(setResumingHandler:)] )
        {
            [progress setResumingHandler:^{
                __typeof__(weakTask) strongTask = weakTask;
                [strongTask resume];
            }];
        }
        
        [progress addObserver:self
                                forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                                   options:NSKeyValueObservingOptionNew
                                   context:NULL];
    }
    
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))
              options:NSKeyValueObservingOptionNew
              context:NULL];
    [task addObserver:self
           forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)cleanUpProgressForTask:(NSURLSessionTask *)task {
    if ([task respondsToSelector:@selector(countOfBytesReceived)]) {
        [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesReceived))];
    }
    if ([task respondsToSelector:@selector(countOfBytesExpectedToReceive)]) {
        [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))];
    }
    if ([task respondsToSelector:@selector(countOfBytesSent)]) {
        [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesSent))];
    }
    if ([task respondsToSelector:@selector(countOfBytesExpectedToSend)]) {
        [task removeObserver:self forKeyPath:NSStringFromSelector(@selector(countOfBytesExpectedToSend))];
    }
    if ([self.downloadProgress respondsToSelector:@selector(fractionCompleted)]) {
        [self.downloadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }
    if ([self.uploadProgress respondsToSelector:@selector(fractionCompleted)]) {
        [self.uploadProgress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isKindOfClass:[NSURLSessionTask class]]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesReceived))]) {
            self.downloadProgress.completedUnitCount = [change[@"new"] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToReceive))]) {
            self.downloadProgress.totalUnitCount = [change[@"new"] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesSent))]) {
            self.uploadProgress.completedUnitCount = [change[@"new"] longLongValue];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(countOfBytesExpectedToSend))]) {
            self.uploadProgress.totalUnitCount = [change[@"new"] longLongValue];
        }
    }
    else if ([object isEqual:self.downloadProgress]) {
        if (self.downloadProgressBlock) {
            self.downloadProgressBlock(object);
        }
    }
    else if ([object isEqual:self.uploadProgress]) {
        if (self.uploadProgressBlock) {
            self.uploadProgressBlock(object);
        }
    }
}

#pragma mark -NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
    __strong UFURLSessionManager *manager = self.manager;
    __block id responseObject = nil;
    
    //Performance Improvement from #2672
    if (self.mutableData) {
        responseObject = [self.mutableData copy];
        //We no longer need the reference, so nil it out to gain back some memory.
        self.mutableData = nil;
    }
    
    if (error) {
        
        dispatch_group_async(manager.uf_completionGroup ?: url_session_manager_completion_group(), manager.uf_completionQueue ?: dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }
        });
    } else {
        dispatch_async(url_session_manager_processing_queue(), ^{
            
            if (self.downloadFileURL) {
                responseObject = self.downloadFileURL;
            }
            
            dispatch_group_async(manager.uf_completionGroup ?: url_session_manager_completion_group(), manager.uf_completionQueue ?: dispatch_get_main_queue(), ^{
                if (self.completionHandler) {
                    self.completionHandler(task.response, responseObject, nil);
                }
            });
        });
    }
#pragma clang diagnostic pop
}

#pragma mark - NSURLSessionDataTaskDelegate
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data];
}

#pragma mark - NSURLSessionDownloadTaskDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    self.downloadFileURL = nil;
    
    if (self.downloadTaskDidFinishDownloading) {
        self.downloadFileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (self.downloadFileURL) {
            NSData *fileData = [NSData dataWithContentsOfURL:location];
            [fileData writeToURL:self.downloadFileURL atomically:YES];
        }
    }
}


@end



typedef NSURL  * (^UFileDestinationURL)(NSURL *targetPath, NSURLResponse *response);
@interface UFURLSessionManager()

@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;
@property (readonly, nonatomic, copy) NSString *taskDescriptionForSessionTasks;
@property (readwrite, nonatomic, strong) NSLock *lock;

@property (readonly, nonatomic, strong) NSURLSession * defaultSession;
@property (readonly, nonatomic, strong) NSURLSession * backgroundSession;

@end



@implementation UFURLSessionManager

-(instancetype)init
{
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    _defaultSession = [NSURLSession sessionWithConfiguration:config
                                                    delegate:self
                                               delegateQueue:self.operationQueue];
    
    NSURLSessionConfiguration *backgroundSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:UFTools.appBundleIdentifier];
    backgroundSessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundSessionConfig
                                                               delegate:self
                                                          delegateQueue:self.operationQueue];
    
    self.mutableTaskDelegatesKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
    return self;
}

- (NSString *)taskDescriptionForSessionTasks {
    return [NSString stringWithFormat:@"%p", self];
}

- (void)setDelegate:(UFURLSessionManagerTaskDelegate *)delegate
            forTask:(NSURLSessionTask *)task
{
    NSParameterAssert(task);
    NSParameterAssert(delegate);
    [self.lock lock];
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    [delegate setupProgressForTask:task];
    [self.lock unlock];
}

- (void)addDelegateForUploadTask:(NSURLSessionUploadTask *)uploadTask
                        progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock
               completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    UFURLSessionManagerTaskDelegate *delegate = [[UFURLSessionManagerTaskDelegate alloc] init];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    delegate.uploadProgressBlock = uploadProgressBlock;
    uploadTask.taskDescription = self.taskDescriptionForSessionTasks;
    
    [self setDelegate:delegate forTask:uploadTask];
}


- (NSURLSessionUploadTask* _Nullable)uploadTaskWithRequest:(nonnull NSURLRequest*)request
                                                  fromFile:(NSURL*)fileURL
                                                  progress:(void (^ _Nullable)(NSProgress* _Nonnull)) uploadProgressBlock
                                         completionHandler:(void (^ _Nullable)(NSURLResponse* _Nonnull response, id _Nullable responseObject, NSError  * _Nullable error))completionHandler
{
    __block NSURLSessionUploadTask *uploadTask = nil;
    url_session_manager_create_task_safely(^{
        uploadTask = [self.backgroundSession uploadTaskWithRequest:request fromFile:fileURL];
    });
    
    
    if (!uploadTask) {
        return nil;
    }
    [self addDelegateForUploadTask:uploadTask progress:uploadProgressBlock completionHandler:completionHandler];
    
    return uploadTask;
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler {
    __block NSURLSessionDataTask *dataTask = nil;
    url_session_manager_create_task_safely(^{
        dataTask = [self.defaultSession dataTaskWithRequest:request];
//        NSLog(@"%@", dataTask);
    });
    [self addDelegateForDataTask:dataTask uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];
    
    return dataTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    __block NSURLSessionDownloadTask *downloadTask = nil;
    url_session_manager_create_task_safely(^{
        downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    });

    [self addDelegateForDownloadTask:downloadTask progress:downloadProgressBlock destination:destination completionHandler:completionHandler];
    return downloadTask;
}

- (void)addDelegateForDataTask:(NSURLSessionDataTask *)dataTask
                uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
              downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
             completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    UFURLSessionManagerTaskDelegate *delegate = [[UFURLSessionManagerTaskDelegate alloc] init];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    
    dataTask.taskDescription = self.taskDescriptionForSessionTasks;
    [self setDelegate:delegate forTask:dataTask];
    
    delegate.uploadProgressBlock = uploadProgressBlock;
    delegate.downloadProgressBlock = downloadProgressBlock;
}

- (void)addDelegateForDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                          progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                       destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                 completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    UFURLSessionManagerTaskDelegate *delegate = [[UFURLSessionManagerTaskDelegate alloc] init];
    delegate.manager = self;
    delegate.completionHandler = completionHandler;
    if (destination) {
        delegate.downloadTaskDidFinishDownloading = ^NSURL * (NSURLSession * __unused session, NSURLSessionDownloadTask *task, NSURL *location) {
            return destination(location, task.response);
        };
    }
    
    downloadTask.taskDescription = self.taskDescriptionForSessionTasks;
    
    [self setDelegate:delegate forTask:downloadTask];
    
    delegate.downloadProgressBlock = downloadProgressBlock;
}

- (UFURLSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    UFURLSessionManagerTaskDelegate *delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return delegate;
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    UFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    [self.lock lock];
    [delegate cleanUpProgressForTask:task];
    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}


#pragma mark -NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    UFURLSessionManagerTaskDelegate *delegate  = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask
{

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    UFURLSessionManagerTaskDelegate *delegate  = [self delegateForTask:dataTask];
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler
{
    if (completionHandler) {
        completionHandler(nil);
    }

}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    UFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    
    // delegate may be nil when completing a task in the background
    if (delegate && (error == nil)) {
        [delegate URLSession:session task:task didCompleteWithError:error];
        
        [self removeDelegateForTask:task];
    }
    
}

#pragma mark- NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    UFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if (delegate) {
        [delegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    UFURLSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    if ([delegate respondsToSelector:@selector(URLSession:downloadTask:didResumeAtOffset:expectedTotalBytes:)]) {
        [delegate URLSession:session downloadTask:downloadTask didResumeAtOffset:fileOffset expectedTotalBytes:expectedTotalBytes];
    }
}

@end


