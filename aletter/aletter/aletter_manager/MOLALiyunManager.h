//
//  MOLALiyunManager.h
//  aletter
//
//  Created by moli-2017 on 2018/8/15.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOLALiyunManager : NSObject
+ (instancetype)shareALiyunManager;
/// 上传图片
- (void)aLiyun_uploadImages:(NSArray *)images complete:(void(^)(NSArray<NSDictionary *> *names))complete;

/// 上传音频
- (void)aLiyun_uploadVoiceFile:(NSString *)voiceFile fileType:(NSString *)fileType complete:(void(^)(NSString * filePath))complete;

/// 上传音频 (进度)
- (void)aLiyun_uploadVoiceFile:(NSString *)voiceFile fileType:(NSString *)fileType progress:(void(^)(NSUInteger totalByteSent))progress complete:(void(^)(NSString * filePath))complete;
@end
