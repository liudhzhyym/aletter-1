//
//  MOLPlayVoiceManager.m
//  aletter
//
//  Created by moli-2017 on 2018/8/16.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPlayVoiceManager.h"
#import "STKAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MOLPlayVoiceManager ()<STKAudioPlayerDelegate>
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign, readwrite) NSInteger playType;   // 0未播放 1 播放 2暂停 3 缓冲中...
@property (nonatomic, assign, readwrite) MOLPlayVoiceManagerType musicType;

@property (nonatomic, strong, readwrite) NSString *currentMusicId;  // 当前播放的ID
@property (nonatomic, strong, readwrite) NSString *currentMusicPath;  // 当前播放的地址

@property (nonatomic, strong) STKAudioPlayer *player;  // 播放器

@property (nonatomic, strong) AVAudioSession *session;
@end

@implementation MOLPlayVoiceManager

+ (instancetype)sharePlayVoiceManager
{
    static MOLPlayVoiceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[MOLPlayVoiceManager alloc] init];
            [instance initialPlayer];
            
            // 中断处理
            [[NSNotificationCenter defaultCenter] addObserver:instance
                                                     selector:@selector(handleInterreption:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:[AVAudioSession sharedInstance]];
        }
    });
    return instance;
}

// 初始化播放器
- (void)initialPlayer
{
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
//    [session setActive:YES error:nil];
    
    if (self.player == nil) {
        self.player = [[STKAudioPlayer alloc] init];
        self.player.volume = 1;
        self.player.delegate = self;
        [self startUpdatingMeter];
    }
}
#pragma mark - 中断处理
-(void)handleInterreption:(NSNotification *)sender
{
    AVAudioSessionInterruptionType type = [sender.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self playManager_pause];
    }
}

#pragma mark - 定时器
- (void)startUpdatingMeter {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        self.displayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
    }
}

- (void)updateMeters
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_process" object:nil];
}

// 暂停定时器
- (void)pauseUpdatingMeter {
    self.displayLink.paused = YES;
}

// 继续定时器
- (void)continueUpdatingMeter {
    self.displayLink.paused = NO;
}

// 废弃定时器
- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 获取音频时长
// 获取播放音频的总时间
- (NSTimeInterval)totalDuration
{
    return self.player.duration;
}
// 获取播放音频的当前时间
- (NSTimeInterval)currentDuration
{
    return self.player.progress;
}

#pragma mark - 播放器代理
/// 开始播放
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [self continueUpdatingMeter];
}

/// 完成加载
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    [self continueUpdatingMeter]; // 继续定时器
}
/// 播放状态改变
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    if (state == STKAudioPlayerStateBuffering) {
        self.playType = 3;
        [self pauseUpdatingMeter]; // 停止定时器
    } else if (state == STKAudioPlayerStatePlaying) {
        self.playType = 1;
        [self continueUpdatingMeter]; // 继续定时器
    } else if (state == STKAudioPlayerStatePaused) {
        self.playType = 2;
        [self pauseUpdatingMeter]; // 继续定时器
    } else {
        self.playType = 0;
        [self pauseUpdatingMeter]; // 停止定时器
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_statusChange" object:nil];
}
/// 播放结束  // stopReason 结束原因
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_finish" object:nil];
    // 暂停定时器
    [self pauseUpdatingMeter];
    
    if (stopReason == STKAudioPlayerStopReasonNone || stopReason == STKAudioPlayerStopReasonEof) {
        
    }
}
/// 发生错误
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_finish" object:nil];
    // 暂停定时器
    [self pauseUpdatingMeter];
}


#pragma mark - 播放方法
/* --------------------------------------------- 播放单曲 ---------------------------------------- */
/// 内部播放方法
- (void)playManager_playWithUrlString:(NSString *)urlString
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [session setActive:YES error:nil];
    
    [self.player dispose];
    self.player = nil;
    [self initialPlayer];
    if (self.musicType == MOLPlayVoiceManagerType_local) {
        [self.player playURL:[NSURL fileURLWithPath:urlString]];
    }else{
        [self.player playURL:[NSURL URLWithString:urlString]];
    }
}

/// 播放
- (void)playManager_playVoiceWithFileUrlString:(NSString *)file modelId:(NSString *)modelId playType:(MOLPlayVoiceManagerType)type
{
    self.musicType = type;
    self.currentMusicId = modelId.length ? modelId : @"-1";
    
    if ([self.currentMusicPath isEqualToString:file]) { // 同一条
        [self initialPlayer];
        if (self.player.state == STKAudioPlayerStatePaused) { // 暂停状态
            [self playManager_resume];  // 继续
        }else if (self.player.state == STKAudioPlayerStatePlaying){
            [self playManager_pause];
        }else if (self.player.state == STKAudioPlayerStateBuffering){
            [self playManager_pause];
        }else{
            [self playManager_playWithUrlString:file];
        }
    }else{
        self.currentMusicPath = file;
        [self playManager_playWithUrlString:file];
    }
}

/// 暂停
- (void)playManager_pause
{
    [self.player pause];
    [self pauseUpdatingMeter];
}

/// 继续
- (void)playManager_resume
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [session setActive:YES error:nil];
    
    [self.player resume];
    [self continueUpdatingMeter];
}

@end
