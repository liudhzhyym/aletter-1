//
//  MOLInputRecordManger.m
//  aletter
//
//  Created by moli-2017 on 2018/8/15.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInputRecordManger.h"
#import "JAPermissionHelper.h"

#import <iflyMSC/IFlyPcmRecorder.h>
#import <iflyMSC/IFlyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "LameManager.h"
#import "MOLHead.h"

@interface MOLInputRecordManger ()<IFlyPcmRecorderDelegate,IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;
@property (nonatomic, strong) NSString *mp3FilePath;
@property (nonatomic, strong) NSMutableArray *iflyResults;

@property (nonatomic, assign) CGFloat fileDuration;  // 实时录制的时长（停止的时候会清零）

@end

@implementation MOLInputRecordManger

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.iflyResults = [NSMutableArray array];
    }
    return self;
}

/// 开始录制
- (void)inputRecord_Start
{
    NSString *docDic = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // 获取当前的时间戳
    NSInteger time = [NSString mol_timeWithCurrentTimestamp];
    self.pcmFilePath = [docDic stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld_record_pcm",time]];
    self.mp3FilePath = [docDic stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld_record.mp3",time]];
//    self.pcmFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
//    self.mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.mp3"];
    
    // 移除原有的文件 2.5.0 bug
    [self inputRecord_resetResource];
    
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    // 初始化识别
    [self iflyDiscriminate];
    // 初始化录音
    [IFlyPcmRecorder sharedInstance].delegate = self;
    [[IFlyPcmRecorder sharedInstance] setSample:[IATConfig sharedInstance].sampleRate];
    [[IFlyPcmRecorder sharedInstance] setPowerCycle:0.1];
    
    [[IFlyPcmRecorder sharedInstance] setSaveAudioPath:self.pcmFilePath];
    
    [[IFlySpeechRecognizer sharedInstance] startListening];
    
    [IFlyAudioSession initRecordingAudioSession];
    [IFlySpeechRecognizer sharedInstance].delegate = self;
    
    
    [[IFlyPcmRecorder sharedInstance] start];
}

// 结束录音
- (void)inputRecord_Stop
{
    // 停止识别
    if ([IFlySpeechRecognizer sharedInstance].isListening) {
        [[IFlySpeechRecognizer sharedInstance] stopListening];
    }
    
    // 停止录音
    [[IFlyPcmRecorder sharedInstance] stop];
    
    [MBProgressHUD showMessage:@"录音保存中..."];
    [LameManager encodeAudioFile:self.pcmFilePath output:self.mp3FilePath complete:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            // 通知外面录制保存完成
            if ([self.delegate respondsToSelector:@selector(inputRecord_recordFinishWithVoice:results:voiceTime:)]) {
                [self.delegate inputRecord_recordFinishWithVoice:self.mp3FilePath results:self.iflyResults voiceTime:(NSInteger)self.fileDuration];
            }
        });
    } failure:^(NSString *reason) {
        [MBProgressHUD hideHUD];
        [MOLToast toast_showWithWarning:YES title:@"保存录音文件失败，请重录"];
        [self inputRecord_resetResource];
        // 通知外面录制失败
        if ([self.delegate respondsToSelector:@selector(inputRecord_recordError)]) {
            [self.delegate inputRecord_recordError];
        }
        
    }];
    
    //取消屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

/// 清空资源
- (void)inputRecord_resetResource
{
    [self removeAvailFile];
    self.fileDuration = 0.0;
    [self.iflyResults removeAllObjects];
}

#pragma mark - 讯飞识别
//识别结果返回代理
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    if (resultFromJson.length) {
        
        [self.iflyResults addObject:resultFromJson];
    }
    
}
//识别会话结束返回代理
- (void)onError: (IFlySpeechError *) error{}

- (void) onCompleted:(IFlySpeechError *) errorCode{}

#pragma mark - 讯飞的代理回调

/*!
 *  回调录音音量
 *
 *  @param power 音量值
 */
- (void) onIFlyRecorderVolumeChanged:(int) power
{
//    CGFloat vol = (arc4random() % 1000 + 9000) / 10000.0;
//    CGFloat volume = vol * (power) * 2 / 3.0;
    self.fileDuration += 0.1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(inputRecord_recordDuration:volum:)]) {
            [self.delegate inputRecord_recordDuration:self.fileDuration volum:power];
        }
    });
    
    // **秒钟以后就停止监听
    if (self.fileDuration >= MOL_Ifly_Time - 1) {
        if ([IFlySpeechRecognizer sharedInstance].isListening) {
            [[IFlySpeechRecognizer sharedInstance] stopListening];
        }
    }
}

/*!
 *  回调音频数据
 *
 *  @param buffer 音频数据
 *  @param size   表示音频的长度
 */
- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    int ret = [[IFlySpeechRecognizer sharedInstance] writeAudio:audioBuffer];
    if (!ret)
    {
        [[IFlySpeechRecognizer sharedInstance] stopListening];
    }
}

/*!
 *  回调音频的错误码
 *
 *  @param recoder 录音器
 *  @param error   错误码
 */
- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}


// 讯飞识别
- (void)iflyDiscriminate
{
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //set recognition domain
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    [IFlySpeechRecognizer sharedInstance].delegate = self;
    
    IATConfig *instance = [IATConfig sharedInstance];
    
    //set timeout of recording
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //set VAD timeout of end of speech(EOS)
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
    //set VAD timeout of beginning of speech(BOS)
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
    //set network timeout
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    
    //set sample rate, 16K as a recommended option
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //set language
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
    //set accent
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
    
    //set whether or not to show punctuation in recognition results
    [[IFlySpeechRecognizer sharedInstance] setParameter:[IATConfig isDot] forKey:[IFlySpeechConstant ASR_PTT]];
    
    // 音频流识别
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [[IFlySpeechRecognizer sharedInstance] setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //Set audio stream
}


- (void)dealloc
{
    // 不停止可能导致科大讯飞的crash
    if ([IFlySpeechRecognizer sharedInstance].isListening) {
        [[IFlySpeechRecognizer sharedInstance] stopListening];
    }
}

// 移除文件
- (void)removeAvailFile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *pcmFilePath = self.pcmFilePath;//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
    NSString *mp3FilePath = self.mp3FilePath;;//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.mp3"];
    
    BOOL isExists = [manager fileExistsAtPath:pcmFilePath];
    if (isExists) {
        [manager removeItemAtPath:pcmFilePath error:nil];
    }
    BOOL isExists1 = [manager fileExistsAtPath:mp3FilePath];
    if (isExists1) {
        [manager removeItemAtPath:mp3FilePath error:nil];
    }
}
@end
