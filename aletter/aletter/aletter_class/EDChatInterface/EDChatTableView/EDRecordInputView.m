//
//  EDRecordInputView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDRecordInputView.h"
#import "SpectrumView.h"
#import "MOLHead.h"
#import "JAPermissionHelper.h"
//#import "CWRecorder.h"
#import "MOLInputRecordManger.h"

@interface EDRecordInputView ()<MOLInputRecordMangerDelegate>
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) SpectrumView *voiceAnimateView; // 振幅动画view
@property (nonatomic, weak) UILabel *timeLabel;   // 时间

@property (nonatomic, weak) UIImageView *recordImageView;   // 录音按钮
@property (nonatomic, strong) UILongPressGestureRecognizer *longP;

@property (nonatomic, weak) UILabel *bottomLabel;   // 按住说 / 松开结束

@property (nonatomic, strong) MOLInputRecordManger *recordManager;

@property (nonatomic, strong) NSString *audioFile;

@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) CADisplayLink *levelTimer;
@end

@implementation EDRecordInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRecordInputViewUI];
        self.recordManager = [[MOLInputRecordManger alloc] init];
        self.recordManager.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
//        self.audioFile = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/audioMsg.wav"];
    }
    return self;
}

#pragma mark - MOLInputRecordMangerDelegate

- (void)inputRecord_recordDuration:(CGFloat)durarion volum:(CGFloat)volum
{
    if (durarion >= 59) {
        self.longP.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.longP.enabled = YES;
        });
        return;
    }
    
    [self recorderRecording];
    self.timeLabel.text = [NSString stringWithFormat:@"%lds",(NSInteger)durarion];
    self.voiceAnimateView.level = volum;
}
- (void)inputRecord_recordFinishWithVoice:(NSString *)file results:(NSArray *)results voiceTime:(NSInteger)time
{
    if ([self.delegate respondsToSelector:@selector(record_endWithFile:time:ifyResult:)]) {
        [self.delegate record_endWithFile:file time:time ifyResult:results];
    }
}
- (void)inputRecord_recordError
{
    [self recorderFailed];
}
/**
 * 准备中
 */
- (void)recorderPrepare
{
    [self.indicatorView startAnimating];
    self.timeLabel.hidden = YES;
    self.voiceAnimateView.hidden = YES;
    self.bottomLabel.text = @"松开结束";
}

/**
 * 录音中
 */
- (void)recorderRecording
{
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    self.timeLabel.hidden = NO;
    self.voiceAnimateView.hidden = NO;
    self.bottomLabel.text = @"松开结束";
}

/**
 * 录音失败
 */
- (void)recorderFailed
{
    if (self.indicatorView.isAnimating) {
        [self.indicatorView stopAnimating];
    }
    self.timeLabel.hidden = YES;
    self.voiceAnimateView.hidden = YES;
    self.bottomLabel.text = @"按住说";
    self.timeLabel.text = @"1s";
    
//    [self stopMeterTimer];
    
    if ([self.delegate respondsToSelector:@selector(record_fail)]) {
        [self.delegate record_fail];
    }
}

#pragma mark - 手势
- (void)beginRecord:(UILongPressGestureRecognizer *)longP
{
    if (longP.state == UIGestureRecognizerStateBegan) {
        
        if (TARGET_IPHONE_SIMULATOR){
            
            [self recorderPrepare];
            
            [self.recordManager inputRecord_Start];
            // 开启定时器
//            [self startMeterTime];
        }else{
            if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {

//                [self.recordManager inputRecord_Start];
                [self.recordManager performSelector:@selector(inputRecord_Start) withObject:nil afterDelay:0.0f inModes:@[NSRunLoopCommonModes]];
//                [self startMeterTime];
                
            }else{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"hidden_msg_recordInput" object:nil];
                [JAPermissionHelper systemPermissionsWithVoice_getSuccess:nil getFailure:nil];
            }
        }
        
    }else if(longP.state != UIGestureRecognizerStateChanged){
        
        if (TARGET_IPHONE_SIMULATOR){
            if (self.indicatorView.isAnimating) {
                [self.indicatorView stopAnimating];
            }
            self.timeLabel.hidden = YES;
            self.voiceAnimateView.hidden = YES;
            self.bottomLabel.text = @"按住说";
            self.timeLabel.text = @"1s";
            [self.recordManager inputRecord_Stop];  // 停止录音
        }else{
            if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
                if (self.indicatorView.isAnimating) {
                    [self.indicatorView stopAnimating];
                }
                self.timeLabel.hidden = YES;
                self.voiceAnimateView.hidden = YES;
                self.bottomLabel.text = @"按住说";
                self.timeLabel.text = @"1s";
                [self.recordManager inputRecord_Stop];  // 停止录音
            }
        }
    }
}

//#pragma mark 定时器
//- (void)startMeterTime
//{
//    self.levelTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeter)];
//
//    if (@available(iOS 10.0, *)) {
//        self.levelTimer.preferredFramesPerSecond = 10;
//    } else {
//        self.levelTimer.frameInterval = 6;
//    }
//    [self.levelTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//
//    // 开启定时器
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(drawLevels) userInfo:nil repeats:YES];
//}
//
//- (void)stopMeterTimer {
//    [self.levelTimer invalidate];
//    self.levelTimer = nil;
//
//    [self.timer invalidate];
//    self.timer = nil;
//}
//
//- (void)updateMeter
//{
//    self.voiceAnimateView.level = [self.recordManager levels];
//}
//
//- (void)drawLevels
//{
//    NSInteger num = [[self.timeLabel.text substringToIndex:self.timeLabel.text.length - 1] integerValue];
//    num ++;
//    self.timeLabel.text = [NSString stringWithFormat:@"%lds",num];
//}

#pragma mark - UI
- (void)setupRecordInputViewUI
{
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:self.indicatorView];
    
    SpectrumView *voiceAnimateView = [[SpectrumView alloc] initWithFrame:CGRectMake(0, 0, 150, 25)];
    _voiceAnimateView = voiceAnimateView;
    voiceAnimateView.level = 0.5;
    voiceAnimateView.hidden = YES;
    [self addSubview:voiceAnimateView];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = [NSString stringWithFormat:@"%ds",1];
    timeLabel.textColor = HEX_COLOR(0x999EAD);
    timeLabel.font = MOL_REGULAR_FONT(16);
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.hidden = YES;
    [self addSubview:timeLabel];
    
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
