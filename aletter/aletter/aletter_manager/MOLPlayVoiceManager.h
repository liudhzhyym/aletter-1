//
//  MOLPlayVoiceManager.h
//  aletter
//
//  Created by moli-2017 on 2018/8/16.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MOLPlayVoiceManagerType) {
    MOLPlayVoiceManagerType_stream,  // 流文件
    MOLPlayVoiceManagerType_local,  // 本地file(eg:试听)
};

@interface MOLPlayVoiceManager : NSObject
+ (instancetype)sharePlayVoiceManager;

/// 播放器的状态
@property (nonatomic, assign, readonly) NSInteger playType;   // 0未播放 1 播放 2暂停 3 缓冲中...

/// 播放器的播放类型
@property (nonatomic, strong, readonly) NSString *currentMusicPath;  // 当前播放的地址
@property (nonatomic, strong, readonly) NSString *currentMusicId;  // 当前播放的ID

@property (nonatomic, assign, readonly) NSTimeInterval currentDuration;
@property (nonatomic, assign, readonly) NSTimeInterval totalDuration;

/// 播放
- (void)playManager_playVoiceWithFileUrlString:(NSString *)file modelId:(NSString *)modelId playType:(MOLPlayVoiceManagerType)type;

/// 暂停
- (void)playManager_pause;

@end
