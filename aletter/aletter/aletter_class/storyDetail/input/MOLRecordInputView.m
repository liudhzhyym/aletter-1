//
//  MOLRecordInputView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLRecordInputView.h"
#import "SpectrumView.h"
#import "MOLAnimateVoiceView.h"
#import "MOLHead.h"
#import "MOLInputRecordManger.h"
#import "JAPermissionHelper.h"
#import <AVFoundation/AVFoundation.h>

#define kRecordCommentTime 59

@interface MOLRecordInputView () <MOLInputRecordMangerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) SpectrumView *voiceAnimateView; // 振幅动画view
@property (nonatomic, weak) UILabel *timeLabel;   // 时间

@property (nonatomic, weak) UILabel *recordWordLabel;  // 录音文字label / 未能识别语音内容
@property (nonatomic, weak) MOLAnimateVoiceView *voiceView;  // 录音音频view
@property (nonatomic, weak) UIButton *againRecordButton;  // 重录

@property (nonatomic, weak) UIImageView *recordImageView;   // 录音按钮
@property (nonatomic, strong) UILongPressGestureRecognizer *longP;

@property (nonatomic, weak) UILabel *bottomLabel;   // 按住说 / 松开结束

@property (nonatomic, strong) MOLInputRecordManger *recordManager;

@property (nonatomic, strong) NSString *fileString;
@property (nonatomic, strong) NSString *time;
@end

@implementation MOLRecordInputView

- (void)dealloc
{
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRecordInputViewUI];
        self.recordManager = [[MOLInputRecordManger alloc] init];
        self.recordManager.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    return self;
}

// 清空数据
- (void)recordInputView_resetData
{
//    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
    // 清空资源
    [self.recordManager inputRecord_resetResource];
    self.keyBoardType = MOLRecordInputViewType_begin;
}

#pragma mark - MOLInputRecordMangerDelegate
- (void)inputRecord_recordDuration:(CGFloat)durarion volum:(CGFloat)volum
{
    if (durarion >= kRecordCommentTime) {
        // 结束录制
//        [self.recordManager inputRecord_Stop];
//        self.keyBoardType = MOLRecordInputViewType_end;
//        if ([self.delegate respondsToSelector:@selector(recordInputView_endRecord)]) {
//            [self.delegate recordInputView_endRecord];
//        }
        self.longP.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.longP.enabled = YES;
        });
        return;
    }
    
    if (self.indicatorView.isAnimating && volum > 0) {
        [self.indicatorView stopAnimating];
        self.timeLabel.hidden = NO;
    }
    
    // 变化UI
    self.timeLabel.text = [NSString stringWithFormat:@"%lds",(NSInteger)durarion];
    self.voiceAnimateView.level = volum;
}
- (void)inputRecord_recordFinishWithVoice:(NSString *)file results:(NSArray *)results voiceTime:(NSInteger)time
{
    if (self.keyBoardType == MOLRecordInputViewType_end) {
        self.recordWordLabel.hidden = results.count;
       
        self.voiceView.showTime = [NSString stringWithFormat:@"%ld",time];
    }
    self.fileString = file;
    self.time = [NSString stringWithFormat:@"%ld",time];
    
    if ([self.delegate respondsToSelector:@selector(recordInputView_recordWithVoiceFile:voiceTime:iflyResults:)]) {
        [self.delegate recordInputView_recordWithVoiceFile:file voiceTime:time iflyResults:results];
    }
}
- (void)inputRecord_recordError
{
    [self recordInputView_resetData];
}

#pragma mark -  NSNotificationCenter
- (void)playStatusChange_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:@"-1"] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.fileString]) {
        NSInteger status = [MOLPlayVoiceManager sharePlayVoiceManager].playType;
        if (status == 0) {
            [self.voiceView animateVoiceView_stop];
            
        }else if (status == 1){
            [self.voiceView animateVoiceView_start];
            
        }else if (status == 2){
            [self.voiceView animateVoiceView_stop];
            
        }else if (status == 3){  // 缓冲。。。
            [self.voiceView animateVoiceView_stop];
        }
    }else{
        [self.voiceView animateVoiceView_stop];
        self.voiceView.showTime = self.time;
    }
}

- (void)playProcess_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:@"-1"] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.fileString]) {
        [self.voiceView animateVoiceView_start];
        NSInteger time = (NSInteger)[MOLPlayVoiceManager sharePlayVoiceManager].totalDuration - [MOLPlayVoiceManager sharePlayVoiceManager].currentDuration;
        self.voiceView.showTime = [NSString stringWithFormat:@"%ld",time];
    }else{
        [self.voiceView animateVoiceView_stop];
        self.voiceView.showTime = self.time;
    }
}

- (void)playFinish_refreshUI
{
    [self.voiceView animateVoiceView_stop];
    self.voiceView.showTime = self.time;
    if ([self.delegate respondsToSelector:@selector(recordInputView_endListen)]) {
        [self.delegate recordInputView_endListen];
    }
}

#pragma mark - 按钮点击
- (void)button_clickAgainButton  // 重录按钮
{
    // 清空资源
    [self.recordManager inputRecord_resetResource];
    
    // 重置键盘 重新录制
    self.keyBoardType = MOLRecordInputViewType_begin;
    if ([self.delegate respondsToSelector:@selector(recordInputView_againRecord)]) {
        [self.delegate recordInputView_againRecord];
    }
}

- (void)button_beginlisten   // 开始试听
{
    NSInteger status = [MOLPlayVoiceManager sharePlayVoiceManager].playType;
    if (status == 0) {
        if ([self.delegate respondsToSelector:@selector(recordInputView_beginListen)]) {
            [self.delegate recordInputView_beginListen];
        }
    }
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_playVoiceWithFileUrlString:self.fileString modelId:nil playType:MOLPlayVoiceManagerType_local];
}

#pragma mark - 手势
- (void)beginRecord:(UILongPressGestureRecognizer *)longP
{
    if (longP.state == UIGestureRecognizerStateBegan) {
        
        [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
        if (TARGET_IPHONE_SIMULATOR){
            self.keyBoardType = MOLRecordInputViewType_record;

            [self.indicatorView startAnimating];
            self.timeLabel.hidden = YES;
            
            [self.recordManager inputRecord_Start];   // 开始录制
            if ([self.delegate respondsToSelector:@selector(recordInputView_beginRecord)]) {
                [self.delegate recordInputView_beginRecord];
            }
  
        }else{
            if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
                self.keyBoardType = MOLRecordInputViewType_record;
                [self.indicatorView startAnimating];
                self.timeLabel.hidden = YES;
                
                 // 开始录制
                [self.recordManager performSelector:@selector(inputRecord_Start) withObject:nil afterDelay:0.0f inModes:@[NSRunLoopCommonModes]];
                if ([self.delegate respondsToSelector:@selector(recordInputView_beginRecord)]) {
                    [self.delegate recordInputView_beginRecord];
                }

            }else{
                [JAPermissionHelper systemPermissionsWithVoice_getSuccess:nil getFailure:nil];
            }
        }
        
    }else if(longP.state != UIGestureRecognizerStateChanged){
        
        if (TARGET_IPHONE_SIMULATOR){
            if (self.indicatorView.isAnimating) {
                [self.indicatorView stopAnimating];
                self.timeLabel.hidden = NO;
            }
            // 结束录制
            [self.recordManager inputRecord_Stop];
            self.keyBoardType = MOLRecordInputViewType_end;
            if ([self.delegate respondsToSelector:@selector(recordInputView_endRecord)]) {
                [self.delegate recordInputView_endRecord];
            }
        }else{
            
            if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
                if (self.indicatorView.isAnimating) {
                    [self.indicatorView stopAnimating];
                    self.timeLabel.hidden = NO;
                }
                // 结束录制
                [self.recordManager inputRecord_Stop];
                self.keyBoardType = MOLRecordInputViewType_end;
                if ([self.delegate respondsToSelector:@selector(recordInputView_endRecord)]) {
                    [self.delegate recordInputView_endRecord];
                }
            }
        }
        
        
    }
}

- (void)setKeyBoardType:(MOLRecordInputViewType)keyBoardType
{
    _keyBoardType = keyBoardType;
    if (keyBoardType == MOLRecordInputViewType_begin){
        self.voiceAnimateView.hidden = YES;
        self.timeLabel.hidden = YES;
        self.recordWordLabel.hidden = YES;
        self.voiceView.hidden = YES;
        self.againRecordButton.hidden = YES;
        self.recordImageView.hidden = NO;
        self.bottomLabel.hidden = NO;
        self.bottomLabel.text = @"按住说";
    }else if (keyBoardType == MOLRecordInputViewType_record){
        self.voiceAnimateView.hidden = NO;
        self.timeLabel.hidden = NO;
        self.recordWordLabel.hidden = YES;
        self.voiceView.hidden = YES;
        self.againRecordButton.hidden = YES;
        self.recordImageView.hidden = NO;
        self.bottomLabel.hidden = NO;
        self.bottomLabel.text = @"松开结束";
    }else if (keyBoardType == MOLRecordInputViewType_end){
        self.voiceAnimateView.hidden = YES;
        self.timeLabel.hidden = YES;
        self.recordWordLabel.hidden = NO;
        self.voiceView.hidden = NO;
        self.againRecordButton.hidden = NO;
        self.recordImageView.hidden = YES;
        self.bottomLabel.hidden = YES;
    }
}

#pragma mark - UI
- (void)setupRecordInputViewUI
{
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.indicatorView];
    
    SpectrumView *voiceAnimateView = [[SpectrumView alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    _voiceAnimateView = voiceAnimateView;
    voiceAnimateView.level = 0.5;
    [self addSubview:voiceAnimateView];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = [NSString stringWithFormat:@"%ds",1];
    timeLabel.textColor = HEX_COLOR(0x999EAD);
    timeLabel.font = MOL_REGULAR_FONT(16);
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:timeLabel];
    
    UILabel *recordWordLabel = [[UILabel alloc] init];
    _recordWordLabel = recordWordLabel;
    recordWordLabel.text = @"未能识别语音内容";
    recordWordLabel.textColor = HEX_COLOR(0x999EAD);
    recordWordLabel.font = MOL_REGULAR_FONT(12);
    [self addSubview:recordWordLabel];
    
    MOLAnimateVoiceView *voiceView = [[MOLAnimateVoiceView alloc] init];
    _voiceView = voiceView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_beginlisten)];
    [voiceView.backViewButton addGestureRecognizer:tap];
    [self addSubview:voiceView];
    
    UIButton *againRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _againRecordButton = againRecordButton;
    [againRecordButton setTitle:@"重录" forState:UIControlStateNormal];
    [againRecordButton setTitleColor:HEX_COLOR(0x999EAD) forState:UIControlStateNormal];
    againRecordButton.titleLabel.font = MOL_REGULAR_FONT(16);
    [againRecordButton addTarget:self action:@selector(button_clickAgainButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:againRecordButton];
    
    UIImageView *recordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"meet_record"]];
    _recordImageView = recordImageView;
    recordImageView.backgroundColor = HEX_COLOR(0x74BDF5);
    recordImageView.contentMode = UIViewContentModeCenter;
    recordImageView.userInteractionEnabled = YES;
    [self addSubview:recordImageView];
    self.longP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginRecord:)];
    self.longP.minimumPressDuration = 0.2;
    [self.recordImageView addGestureRecognizer:self.longP];
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    _bottomLabel = bottomLabel;
    bottomLabel.text = @"按住说";
    bottomLabel.textColor = HEX_COLOR(0x999EAD);
    bottomLabel.font = MOL_MEDIUM_FONT(12);
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:bottomLabel];
}

- (void)calculatorRecordInputViewFrame
{
    self.voiceAnimateView.width = 150;
    self.voiceAnimateView.height = 25;
    self.voiceAnimateView.centerX = self.width * 0.5;
    self.voiceAnimateView.y = 25;
    
    self.timeLabel.width = 30;
    self.timeLabel.height = 25;
    self.timeLabel.centerX = self.voiceAnimateView.centerX;
    self.timeLabel.centerY = self.voiceAnimateView.centerY;
    
    // 设置指示器位置
    self.indicatorView.centerX = self.timeLabel.centerX;
    self.indicatorView.centerY = self.timeLabel.centerY;
    
    [self.recordWordLabel sizeToFit];
    self.recordWordLabel.centerX = self.width * 0.5;
    self.recordWordLabel.y = 60;
    
    self.voiceView.width = 230;
    self.voiceView.height = 40;
    self.voiceView.centerX = self.width * 0.5;
    self.voiceView.y = self.recordWordLabel.bottom + 20;
    
    self.againRecordButton.width = 64;
    self.againRecordButton.height = 30;
    self.againRecordButton.centerX = self.width * 0.5;
    self.againRecordButton.y = self.voiceView.bottom + 35;
    self.againRecordButton.layer.cornerRadius = self.againRecordButton.height * 0.5;
    self.againRecordButton.layer.borderColor = HEX_COLOR(0x999EAD).CGColor;
    self.againRecordButton.layer.borderWidth = 1;
    self.againRecordButton.layer.masksToBounds = YES;
    
    self.recordImageView.width = 80;
    self.recordImageView.height = 80;
    self.recordImageView.centerX = self.width * 0.5;
    self.recordImageView.centerY = self.height * 0.5;
    self.recordImageView.layer.cornerRadius = self.recordImageView.height * 0.5;
    self.recordImageView.layer.masksToBounds = YES;
    
    self.bottomLabel.width = 150;
    self.bottomLabel.height = 17;
    self.bottomLabel.centerX = self.recordImageView.centerX;
    self.bottomLabel.y = self.recordImageView.bottom + 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorRecordInputViewFrame];
}
@end
