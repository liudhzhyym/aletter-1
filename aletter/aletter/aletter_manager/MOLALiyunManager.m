//
//  MOLALiyunManager.m
//  aletter
//
//  Created by moli-2017 on 2018/8/15.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLALiyunManager.h"
#import <AliyunOSSiOS/OSSService.h>
#import "MOLHead.h"

#define Ali_EndPoint @"oss-cn-zhangjiakou.aliyuncs.com"
#define Ali_bucketName @"moli2017"
#define Ali_successUrl @"http://file.xsawe.top"

@interface MOLALiyunManager ()
@property (nonatomic, strong) OSSClient *client;
@end

@implementation MOLALiyunManager

+ (instancetype)shareALiyunManager
{
    static MOLALiyunManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[MOLALiyunManager alloc] init];
            
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 自实现签名，可以用本地签名也可以远程加签
        id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
            NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:@"R8Pf6CLZ4I2nZDbuENGfrhIWe3huA2"];
            if (error != NULL) {
                if (signature != nil) {
                    *error = nil;
                } else {
                    // construct error object           com.molikeji.aletter   com.moli.jasmine
                    *error = [NSError errorWithDomain:@"com.moli.jasmine" code:OSSClientErrorCodeSignFailed userInfo:nil];
                    return nil;
                }
            }
            return [NSString stringWithFormat:@"OSS %@:%@", @"LTAIB4bui61O93Aj", signature];
        }];
    
        OSSClientConfiguration * conf = [OSSClientConfiguration new];
        conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
        conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
        conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
        
        self.client = [[OSSClient alloc] initWithEndpoint:Ali_EndPoint credentialProvider:credential clientConfiguration:conf];
    }
    return self;
}

/// 上传图片
- (void)aLiyun_uploadImages:(NSArray *)images complete:(void(^)(NSArray<NSDictionary *> *names))complete
{
    dispatch_queue_t uploadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t uploadGroup = dispatch_group_create();
    
    NSMutableArray *resultNames = [NSMutableArray array];
    
    for (NSInteger i = 0; i < images.count; i++) {
        
        dispatch_group_async(uploadGroup, uploadQueue, ^{
            
            UIImage *image = images[i];
            
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            put.bucketName = Ali_bucketName;
            NSString *deviceId = [[NSUUID UUID] UUIDString];
            NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
            // 毫秒值+随机字符串+文件类型
            NSString *imageName = [NSString stringWithFormat:@"aletter/image/iOS_%lld%@.%@",(long long)interval,deviceId,@"jpg"];
            put.objectKey = imageName;
            
            NSData *data = [image mol_compressWithLengthLimit:300.0 * 1024.0];
            
            put.uploadingData = data;
            
            OSSTask * putTask = [self.client putObject:put];
            [putTask waitUntilFinished]; // 阻塞直到上传完成
            
            if (!putTask.error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",Ali_successUrl,put.objectKey];
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    dic[@"height"] = @(image.size.height);
                    dic[@"src"] = imageUrl;
                    dic[@"width"] = @(image.size.width);
                    [resultNames addObject:dic];
                });
            }
            
        });
    }
    
    dispatch_group_notify(uploadGroup, uploadQueue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(resultNames);
            }
        });
    });
}

/// 上传音频
- (void)aLiyun_uploadVoiceFile:(NSString *)voiceFile fileType:(NSString *)fileType complete:(void(^)(NSString * filePath))complete
{
    [self aLiyun_uploadVoiceFile:voiceFile fileType:fileType progress:nil complete:complete];
}

/// 上传音频
- (void)aLiyun_uploadVoiceFile:(NSString *)voiceFile fileType:(NSString *)fileType progress:(void(^)(NSUInteger totalByteSent))progress complete:(void(^)(NSString * filePath))complete
{
    NSData *data = [NSData dataWithContentsOfFile:voiceFile];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    // 必填字段
    put.bucketName = Ali_bucketName;
    NSString *deviceId = [[NSUUID UUID] UUIDString];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    // 毫秒值+随机字符串+文件类型
    NSString *filePath = [NSString stringWithFormat:@"aletter/audio/iOS_%lld%@.%@",(long long)interval,deviceId,fileType];
    put.objectKey = filePath;
    put.uploadingData = data; // 直接上传NSData
    // 可选字段，可不设置
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        // 当前上传段长度、当前已经上传总长度、一共需要上传的总长度
//        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        if (progress) {
            progress(totalByteSent);
        }
    };
    if (fileType.length) {
        NSDictionary *fileTypesByMimeType =
        @{
          @"mp3": @"audio/mpeg",
          @"wav": @"audio/wav",
          @"aifc": @"audio/aifc",
          @"aiff": @"audio/aiff",
          @"m4a": @"audio/x-m4a",
          @"mp4": @"audio/x-mp4",
          @"caf": @"audio/caf",
          @"aac": @"audio/aac",
          @"ac3": @"audio/ac3",
          @"3gp": @"audio/3gp"
          };
        NSString *contentType = fileTypesByMimeType[fileType];
        if (contentType.length) {
            put.contentType = contentType;
        }
    }
    OSSTask * putTask = [self.client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!task.error) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",Ali_successUrl,put.objectKey];
                if (complete) {
                    complete(imageUrl);
                }
            } else {
                if (complete) {
                    complete(nil);
                }
            }
        });
        return nil;
    }];
}
@end
