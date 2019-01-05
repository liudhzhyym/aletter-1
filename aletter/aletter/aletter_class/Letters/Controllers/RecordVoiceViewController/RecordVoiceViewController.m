//
//  RecordVoiceViewController.m
//  aletter
//
//  Created by xujin on 2018/8/20.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "RecordVoiceViewController.h"
#import "JATimelineView.h"
#import "JAVoiceWaveView.h"
#import "JARecordWaveView.h"
#import "JAPermissionHelper.h"
#import "JASensorsAnalyticsConstants.h"
#import "EZAudioPlayer.h"
#import "LameConver.h"
#import "NSString+JACategory.h"
#import "NSMutableArray+Queue.h"
#import "RMAudioProcess.h"
#import "EZMicrophone.h"
#import "EZAudioUtilities.h"
#import "MOLALiyunManager.h"

#import "MOLHead.h"

typedef NS_ENUM(NSInteger, JARecordStyle) {
    JARecordStyleRecord,
    JARecordStyleListen,
    JARecordStyleCrop
};

static const NSInteger kMaxRecordTime = 90;
static const NSInteger KBUFFERSIZE = 1024*10*4;
static const NSInteger nrSampleRate = 32000;

@interface RecordVoiceViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) JATimelineView *timelineView;
@property (nonatomic, strong) JAVoiceWaveView *voiceWaveView;
@property (nonatomic, strong) JARecordWaveView *mWaveFormView;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *pauseRecordButton;
@property (nonatomic, strong) UIButton *listenButton;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *recordTimeLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIButton *rerecordButton;

@property (nonatomic, strong) EZAudioPlayer * ezPlayer; //绘制图形第三方库
@property (nonatomic, strong) CADisplayLink *meterUpdateDisplayLink;
@property (nonatomic, assign) int maxCount; // 录音时view最多样本数
@property (nonatomic, strong) NSString * nrFilePath;
@property (nonatomic, strong) LameConver *conver;
@property (nonatomic, assign) char * wavForm;
@property (nonatomic, assign) int wavUsedSize;
@property (nonatomic, assign) char * pNRBuffer;
@property (nonatomic, assign) int nrBufferUsedSize;
// 降噪和增益
@property (nonatomic, assign) RMAudioProcess audioProcess;

@property (nonatomic, assign) CGPoint originalOffset;
@property (nonatomic, strong) EZMicrophone * ezMic;
@property (nonatomic, assign) JARecordStyle currentRecordStyle;
@property (nonatomic, assign) SInt64 totalFrames;

@property (nonatomic, strong) NSMutableArray *peakLevelQueue; //录制显示
@property (nonatomic, strong) NSMutableArray *allPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *currentPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *displayPeakLevelQueue;

@property (nonatomic, assign) BOOL hasChecked; // 已经检测过低分贝和是否识别出文字
@property (nonatomic, assign) BOOL lowVoice;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) AudioBufferList * nrBufferList;

@property (nonatomic, assign) BOOL hasRecordData;
@property (nonatomic, assign) BOOL hasRecord5sData;
@property (nonatomic, assign) BOOL isMicOn;  //表示开始录音
@property (nonatomic, assign) BOOL isContinueReplay;
@property (nonatomic, assign) int allCount;



@end


@implementation RecordVoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self layoutUI];
    [self setupTopView];
    [self setupBottomView];
    [self changeViewWithStyle:JARecordStyleRecord];
    
    //完成按钮初始化
    [self setRightButtonEnable:NO];
    [self setButtonDisableStatus];
    [self startUpdatingMeter];
    NSString *sourceRecordFile = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"record"] stringByAppendingPathExtension:@"mp3"];
    _nrFilePath = sourceRecordFile;
    [NSString ja_removeFilePath:self.nrFilePath];
    
    _conver = [[LameConver alloc] initWithFilePath:self.nrFilePath];
    
    _wavForm = (char*)malloc(KBUFFERSIZE);
    _wavUsedSize = 0;
    
    _pNRBuffer = (char*)malloc(KBUFFERSIZE);
    _nrBufferUsedSize = 0;
    
    _audioProcess = [self createAudioProcessFromConfig];
    
    self.maxCount = (int)(self.mWaveFormView.width/4.0);
}

- (void)initData{
    
}

- (void)layoutUI{
    [self.view setBackgroundColor: [UIColor whiteColor]];
    [self.view addSubview:self.backgroundView];
    //按钮
    [self.backgroundView addSubview:self.leftButton];
    [self.backgroundView addSubview:self.rightButton];
    [self.backgroundView addSubview:self.topView];
    
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGFloat waveHeigh = MOL_SCREEN_ADAPTER(150);
    if (iPhone4) {
        waveHeigh = 100;
    }
    
    [self.backgroundView setFrame:CGRectMake(0,20, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT-20)];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.backgroundView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.backgroundView.layer.mask = maskLayer;
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(6);
        make.width.mas_equalTo(14+16+14);
        make.height.mas_equalTo(14+16+14);
    }];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(6);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(14+16+14);
    }];
    
}

#pragma mark
#pragma mark - 懒加载
- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView =[UIView new];
        [_backgroundView setBackgroundColor:[UIColor whiteColor]];
    }
    return _backgroundView;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_leftButton setBackgroundColor: [UIColor clearColor]];
        [_leftButton setImage:[UIImage imageNamed:@"黑色关闭"] forState:(UIControlStateNormal)];
        [_leftButton addTarget:self action:@selector(closeControllerEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setBackgroundColor: [UIColor clearColor]];
        [_rightButton setTitle:@"完成" forState:UIControlStateNormal];
        [_rightButton setTitleColor:HEX_COLOR_ALPHA(0x091F38,0.3) forState:UIControlStateNormal];
        [_rightButton.titleLabel setFont:MOL_MEDIUM_FONT(14)];
        [_rightButton setEnabled:NO];
        [_rightButton addTarget:self action:@selector(rightButttonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UIView *)topView{
    if (!_topView) {
        _topView =[UIView new];
        [_topView setBackgroundColor:[UIColor whiteColor]];
    }
    return _topView;
}




#pragma mark - setupUI
- (void)setupTopView {
    CGFloat waveHeigh = MOL_SCREEN_ADAPTER(150);
    if (iPhone4) {
        waveHeigh = 100;
    }
    //__weak __typeof(self) weakSelf = self;
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(14+16+14+90);
        make.left.right.offset(0);
        make.height.offset(waveHeigh+50);
    }];
    
    self.timelineView =[[JATimelineView alloc] initWithFrame:CGRectMake(0,14+16+14+90+19,MOL_SCREEN_WIDTH, 30)];
    // [self.timelineView setBackgroundColor: [UIColor redColor]];
    [self.backgroundView addSubview:self.timelineView];
    
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEX_COLOR(0xd1d1d1);
    [self.topView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
    
    UIView *waveView = [UIView new];
    waveView.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:waveView];
    [waveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom);
        make.left.offset(0);
        make.width.offset(MOL_SCREEN_WIDTH);
        make.height.offset(waveHeigh);
    }];
    
    
    
    JAVoiceWaveView *voiceWaveView = [[JAVoiceWaveView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, waveHeigh)];
   //     voiceWaveView.backgroundColor = [UIColor yellowColor];
   // voiceWaveView.maskColor = HEX_COLOR(0x1CD39B);//#74BDF5 100%  //绘制颜色值
   // voiceWaveView.darkGrayColor = HEX_COLOR(0x1CD39B); //试听颜色值
     voiceWaveView.maskColor = HEX_COLOR(0x4A90E2);//#74BDF5 100%  //绘制颜色值
     voiceWaveView.darkGrayColor = HEX_COLOR(0x4A90E2); //试听颜色值
    voiceWaveView.sliderIV.drawColor = HEX_COLOR(0x44444);
    //    voiceWaveView.sliderIV.hidden = YES;
    voiceWaveView.sliderIV.stickWidth = 1;
    voiceWaveView.sliderIV.diameter = 5;
    voiceWaveView.sliderIV.height = waveHeigh+16;
    voiceWaveView.sliderIV.y = -11;
    [waveView addSubview:voiceWaveView];
    self.voiceWaveView = voiceWaveView;
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = HEX_COLOR(0xd1d1d1);
    [self.topView insertSubview:lineView1 belowSubview:waveView];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(waveView.mas_bottom);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
    
    self.mWaveFormView = [[JARecordWaveView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH/2.0, waveHeigh)];
   // self.mWaveFormView.maskColor = HEX_COLOR(0x1CD39B); //绘制颜色值
    self.mWaveFormView.maskColor = HEX_COLOR(0x4A90E2);
    self.mWaveFormView.sliderIV.drawColor = HEX_COLOR(0x44444);
    //    self.mWaveFormView.sliderIV.hidden = YES;
    self.mWaveFormView.sliderIV.stickWidth = 1;
    self.mWaveFormView.sliderIV.diameter = 5;
    self.mWaveFormView.sliderIV.height = waveHeigh+16;
    self.mWaveFormView.sliderIV.y = -11;
    //    self.mWaveFormView.backgroundColor = [UIColor redColor];
    [waveView addSubview:self.mWaveFormView];
    
}


// 底部按钮
- (void)setupBottomView {
    __weak __typeof(self) weakSelf = self;
    self.centerLabel = [UILabel new];
    self.centerLabel.font = MOL_REGULAR_FONT(12);
    self.centerLabel.textColor = HEX_COLOR(0xC6C6C6);
    self.centerLabel.text =@"点击录音";
    [self.backgroundView addSubview:self.centerLabel];
    [self.centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backgroundView.mas_centerX);
        if (iPhone4) {
            make.bottom.offset(-5);
        } else {
            make.bottom.offset(-MOL_SCREEN_ADAPTER(80));
        }
    }];
    //    self.centerLabel.backgroundColor = [UIColor redColor];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"点击录音"] forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"点击录音"] forState:UIControlStateHighlighted];
    [self.recordButton setImage:[UIImage imageNamed:@"结束录音"] forState:UIControlStateSelected];
    [self.recordButton setImage:[UIImage imageNamed:@"结束录音"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.recordButton addTarget:self action:@selector(recordButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.recordButton];
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerLabel.mas_centerX);
        make.bottom.equalTo(self.centerLabel.mas_top);
        if (iPhone4) {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        } else {
            make.size.mas_equalTo(CGSizeMake(86, 86));
        }
    }];
   // [self.recordButton setBackgroundColor: [UIColor redColor]];
    
    
    self.listenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.listenButton setImage:[UIImage imageNamed:@"试听"] forState:UIControlStateNormal];
    [self.listenButton setImage:[UIImage imageNamed:@"试听"] forState:UIControlStateHighlighted];
    [self.listenButton setImage:[UIImage imageNamed:@"试听暂停"] forState:UIControlStateSelected];
    [self.listenButton setImage:[UIImage imageNamed:@"试听暂停"] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.listenButton setImage:[UIImage imageNamed:@"试听置灰"] forState:UIControlStateDisabled];
    [self.listenButton addTarget:self action:@selector(showListenView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.listenButton];
    [self.listenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recordButton.mas_right).offset(MOL_SCREEN_ADAPTER(44));
        make.centerY.equalTo(weakSelf.recordButton.mas_centerY);
        // make.bottom.equalTo(self.recordButton.mas_bottom);
        
        if (iPhone4) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
        } else {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }
    }];
   // [self.listenButton setBackgroundColor: [UIColor redColor]];
    self.rerecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rerecordButton setImage:[UIImage imageNamed:@"重录"] forState:UIControlStateNormal];
    [self.rerecordButton setImage:[UIImage imageNamed:@"重录"] forState:UIControlStateHighlighted];
    [self.rerecordButton setImage:[UIImage imageNamed:@"重录置灰"] forState:UIControlStateDisabled];
    [self.rerecordButton addTarget:self action:@selector(reRecordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:self.rerecordButton];
    [self.rerecordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.recordButton.mas_left).offset(-MOL_SCREEN_ADAPTER(44));
        //make.bottom.equalTo(self.recordButton.mas_bottom);
        make.centerY.equalTo(weakSelf.recordButton.mas_centerY);
        if (iPhone4) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
        } else {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }
        
    }];
   // [self.rerecordButton setBackgroundColor: [UIColor redColor]];
    self.leftLabel = [UILabel new];
    self.leftLabel.font = MOL_REGULAR_FONT(12);
    self.leftLabel.textColor = HEX_COLOR(0xC6C6C6);
    [self.leftLabel setText: @"重录"];
    [self.backgroundView addSubview:self.leftLabel];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.rerecordButton.mas_centerX);
        //        make.centerY.equalTo(self.centerLabel.mas_centerY);
        make.top.equalTo(self.centerLabel.mas_top);
        
    }];
    //    self.leftLabel.backgroundColor = [UIColor greenColor];
    
    self.rightLabel = [UILabel new];
    self.rightLabel.font = MOL_REGULAR_FONT(12);
    self.rightLabel.textColor = HEX_COLOR(0xC6C6C6);
    [self.rightLabel setText:@"试听"];
    [self.backgroundView addSubview:self.rightLabel];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.listenButton.mas_centerX);
        //        make.centerY.equalTo(self.centerLabel.mas_centerY);
        make.top.equalTo(self.centerLabel.mas_top);
    }];
    //    self.rightLabel.backgroundColor = [UIColor redColor];
    
    // 录音时间
    self.recordTimeLabel = [UILabel new];
    self.recordTimeLabel.textColor = HEX_COLOR(0x091F38);
    self.recordTimeLabel.font = MOL_LIGHT_FONT(36);
    [self.backgroundView addSubview:self.recordTimeLabel];
    [self.recordTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).offset(120);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
    }];
    [self.recordTimeLabel setText:[NSString stringWithFormat:@"00:00/%02d:%02d",(int)kMaxRecordTime/60,(int)kMaxRecordTime%60]];
    self.recordTimeLabel.hidden = YES;
    
}

#pragma mark - 定时器
- (void)startUpdatingMeter {
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    self.meterUpdateDisplayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
    //    self.meterUpdateDisplayLink.preferredFramesPerSecond = 10;// 模拟器iPhone6崩溃
    [self.meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.meterUpdateDisplayLink.paused = YES;
}

- (void)updateMeters {
    /************** 试听 **************/
    if (self.listenButton.selected) {
        NSInteger index = (NSInteger)(self.ezPlayer.currentTime * 10);
        CGFloat percent = (index * 4) / (MOL_SCREEN_WIDTH);
        if (percent>=0.5) {
            percent = 0.5;
            index = index+_allCount/2; // 跳过半个波形的宽度
            if (index < self.displayPeakLevelQueue.count) {
                [self.currentPeakLevelQueue enqueue:self.displayPeakLevelQueue[index] maxCount:_allCount];
            }
            CGFloat stride = index*4-MOL_SCREEN_WIDTH/2.0;
            [self.timelineView.collectionView setContentOffset:CGPointMake(stride, 0) animated:NO];
        }
        // 移动滑动杆
        [self.voiceWaveView setSliderOffsetX:percent];
        [self.voiceWaveView setPeakLevelQueue:self.currentPeakLevelQueue];
        return;
    }
}


#pragma mark
#pragma mark - action event
- (void)closeControllerEvent:(UIButton *)sender{
    [self closeControllerEvent];
}

- (void)closeControllerEvent{
    if (self.hasRecordData) {
        // 暂停录音
        [self pausePlay];
        [self pauseRecordButtonAction];
        
        __weak __typeof(self) weakSelf = self;
            [self showAlertViewWithTitle:@"确定放弃当前录音？" subTitle:@"" completion:^(BOOL complete) {
                if (complete) {
                    [weakSelf stopUpdatingMeter];
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                }
            }];
    } else {
        // 暂停录音
        [self pausePlay];
        [self pauseRecordButtonAction];
        [self stopUpdatingMeter];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)rightButttonEvent:(UIButton *)sender{
    [sender setEnabled:NO];
    if (!self.hasRecordData) {
        [sender setEnabled:YES];
        return;
    }
    [self pausePlay];
    [self pauseRecordButtonAction];
    
    if (self.duration < 5){
        // [self.view :[NSString stringWithFormat:@"录音时长不能小于%zds",minSeconds]];
        [sender setEnabled:YES];
        return;
    }
    
    if (self.hasRecordData) {
        
        [self stopUpdatingMeter];
        __weak __typeof(self) weakSelf = self;
        if (self.nrFilePath) {
            [[MOLALiyunManager shareALiyunManager] aLiyun_uploadVoiceFile:self.nrFilePath fileType:@"mp3" complete:^(NSString *filePath) {
                
                if(filePath){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.MRecordVoiceViewControllerVoiceBlock(weakSelf.duration?weakSelf.duration:0,filePath?filePath:@"");
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    });
                }
                
                //NSLog(@"filePath:%@",filePath);
                
            }];
             [sender setEnabled:YES];
        }
        else{
            [sender setEnabled:YES];
        }
        
    }else{
        [sender setSelected:YES];
    }
    NSLog(@"完成事件触发");
}



///设置完成权限
- (void)setRightButtonEnable:(BOOL)enable {
    if (enable) {
        [_rightButton setTitleColor:HEX_COLOR_ALPHA(0x091F38,1) forState:UIControlStateNormal];
        [_rightButton setEnabled:YES];
    } else {
        [_rightButton setTitleColor:HEX_COLOR_ALPHA(0x091F38,0.3) forState:UIControlStateNormal];
        [_rightButton setEnabled:NO];
    }
}

///设置重录、试听权限
- (void)setButtonDisableStatus {
    self.listenButton.enabled = NO;
    self.rerecordButton.enabled = NO;
}

- (void)setButtonEnableStatus {
    self.listenButton.enabled = YES;
    self.rerecordButton.enabled = YES;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

// 录音
- (void)recordButtonAction {
    
    __weak __typeof(self) weakSelf = self;

    if (TARGET_IPHONE_SIMULATOR) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.recordButton.selected =!weakSelf.recordButton.isSelected;
            if (weakSelf.recordButton.isSelected) {//yes表示录音 no表示暂停
                [weakSelf recordEvent];
            }else{
                [weakSelf pauseRecordButtonAction];
            }
        });
    }else{
        if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.recordButton.selected =!weakSelf.recordButton.isSelected;
                if (weakSelf.recordButton.isSelected) {//yes表示录音 no表示暂停
                    [weakSelf recordEvent];
                }else{
                    [weakSelf pauseRecordButtonAction];
                }
            });
        }else{
            [JAPermissionHelper systemPermissionsWithVoice_getSuccess:nil getFailure:nil];
        }
    }
    
//#if 1
//    if ([JAPermissionHelper systemPermissionsWithVoice] == BBEPermissionsStatusAuthorize) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.recordButton.selected =!weakSelf.recordButton.isSelected;
//            if (weakSelf.recordButton.isSelected) {//yes表示录音 no表示暂停
//                [weakSelf recordEvent];
//            }else{
//                [weakSelf pauseRecordButtonAction];
//            }
//        });
////        return;
//    }else{
//        [JAPermissionHelper systemPermissionsWithVoice_getSuccess:nil getFailure:nil];
//
////        return;
//    }
//#else
//    //录音授权
//
//    // 检查是否允许访问相机
//    __block AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    switch (authStatus) {
//        case AVAuthorizationStatusNotDetermined:
//        case AVAuthorizationStatusRestricted:
//        case AVAuthorizationStatusDenied:
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在手机系统“设置-隐私-麦克风”选项中，允许访问您的麦克风。" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
//
//            [alert show];
//        }
//            break;
//        case AVAuthorizationStatusAuthorized:
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.recordButton.selected =!weakSelf.recordButton.isSelected;
//                if (weakSelf.recordButton.isSelected) {//yes表示录音 no表示暂停
//                    [weakSelf recordEvent];
//                }else{
//                    [weakSelf pauseRecordButtonAction];
//                }
//            });
//            break;
//        }
//    }
//#endif
}

- (void)recordEvent{
    [self noticeAction];
    
    [self pausePlay];
    
    self.hasRecordData = YES;
    self.isMicOn = YES;
    
    
    [self changeViewWithStyle:JARecordStyleRecord];
    
    // 延时0.1秒开始录制 如果0.1秒内点了暂停，则取消该操作
    [self performSelector:@selector(startRec) withObject:nil afterDelay:0.2];
    
    if (self.originalOffset.x) {
        
        [self.timelineView.collectionView setContentOffset:self.originalOffset animated:NO];
    }

}

- (void)changeViewWithStyle:(JARecordStyle)style {
    self.currentRecordStyle = style;
    switch (style) {
        case JARecordStyleRecord:
        {
            if (self.recordButton.selected) {
                //[self.recordButton setSelected:YES];
                self.centerLabel.text = @"结束";
            } else {
                //[self.recordButton setSelected:NO];
                self.centerLabel.text = @"点击录音";
            }
            
            
            if (self.hasRecordData) {
                [self setButtonEnableStatus];
            } else {
                [self setButtonDisableStatus];
            }

        }
            break;
        default:
            break;
    }
}

- (void)startRec
{
    [self.ezPlayer pause];
    _ezPlayer = nil;
    [self.conver openFileWithFilePath:self.nrFilePath];
    [self.ezMic startFetchingAudio];
}

- (EZMicrophone*)ezMic
{
    if (!_ezMic) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
        AudioStreamBasicDescription audioStreamDes = [self GetRecFileABSD];
        __weak id weakSelf = self;
        _ezMic = [EZMicrophone microphoneWithDelegate:weakSelf withAudioStreamBasicDescription:audioStreamDes];
    }
    return _ezMic;
}

- (void)pausePlay {
    self.mWaveFormView.hidden = NO;
    self.voiceWaveView.hidden = YES;
    
    self.isContinueReplay = NO;
    self.listenButton.selected = NO;
    
    //先暂停绘制语音图形 释放
    [self.ezPlayer pause];
    self.ezPlayer = nil;
    [self pauseUpdatingMeter];
}

- (void)pauseUpdatingMeter {
    self.meterUpdateDisplayLink.paused = YES;
}

- (void)noticeAction {
    self.recordTimeLabel.hidden = NO;
}

// 暂停录音
- (void)pauseRecordButtonAction {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startRec) object:nil];
    self.isMicOn = NO;
    [self.ezMic stopFetchingAudio];
    _ezMic = nil;
    [self.conver closeFile];
    [self changeViewWithStyle:JARecordStyleRecord];
    [self pauseUpdatingMeter];
    self.originalOffset = self.timelineView.collectionView.contentOffset;

}

// 试听页面跳转事件
- (void)showListenView:(UIButton *)sender {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod:) object:sender];
    [self performSelector:@selector(myDelayedMethod:) withObject:sender afterDelay:0.3];

}

- (void)myDelayedMethod:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        if (self.recordButton.selected) {
            self.recordButton.selected =!self.recordButton.isSelected;
        }
        
        if (self.isContinueReplay) {
            [self.ezPlayer play];
        } else {
            [self pauseRecordButtonAction];
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioSession setActive:YES error:nil];
            
            if (self.ezPlayer.isPlaying) {
                [self.ezPlayer pause];
                _ezPlayer = nil;
            }
            
            __weak id weakSelf = self;
            self.ezPlayer = [EZAudioPlayer audioPlayerWithURL:[NSURL fileURLWithPath:self.nrFilePath] delegate:weakSelf];
            [self.ezPlayer play];
            
            self.mWaveFormView.hidden = YES;
            self.voiceWaveView.hidden = NO;
            
            [self.displayPeakLevelQueue removeAllObjects];
            [self.currentPeakLevelQueue removeAllObjects];
            
            self.displayPeakLevelQueue = [NSMutableArray arrayWithArray:self.allPeakLevelQueue];
            
            _allCount = (int)(MOL_SCREEN_WIDTH/4.0);
            if (_allCount%2 != 0) {
                _allCount -= 1;
            }
            int halfCount = _allCount/2;
            int diff = 0;
            if (self.displayPeakLevelQueue.count > _allCount) {
                diff = halfCount;
            } else if (self.displayPeakLevelQueue.count < _allCount &&
                       self.displayPeakLevelQueue.count > halfCount) {
                diff = (int)(_allCount - self.displayPeakLevelQueue.count)+halfCount;
            } else {
                diff = (int)(_allCount - self.displayPeakLevelQueue.count);
            }
            // 补充空点
            for (int i=0; i<diff; i++) {
                [self.displayPeakLevelQueue addObject:@(-1.0)];
            }
            // 获取一屏幕的样本点
            for (int i=0; i<_allCount; i++) {
                [self.currentPeakLevelQueue addObject:self.displayPeakLevelQueue[i]];
            }
            [self.voiceWaveView setPeakLevelQueue:self.currentPeakLevelQueue];
            
            [self.timelineView resetTimeProgress];
        }
        [self continueUpdatingMeter];
    } else {
        self.isContinueReplay = YES;
        [self.ezPlayer pause];
        
        [self pauseUpdatingMeter];
    }
}

- (void)continueUpdatingMeter {
    self.meterUpdateDisplayLink.paused = NO;
}

- (void)stopUpdatingMeter {
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = nil;
}

- (void)reRecordAction {
    if (!self.hasRecordData) {
        return;
    }
    [self.recordButton setSelected:NO];
    [self pausePlay];
    [self pauseRecordButtonAction];
    
    [self showAlertViewWithTitle:@"提示" subTitle:@"确定要重录吗？" completion:^(BOOL complete) {
        if (complete) {
            [self confirmRerecord];
        }
    }];

}

#pragma mark - RMAudioProcess
- (RMAudioProcess)createAudioProcessFromConfig
{
    int nNREnable = 1;
    int nNRMode = 1; // 0轻微1中度2强力
    
    int nAgcEnable = 1;
    // nLevel 是值越大，表示增益后的音量越大
    int nLevel = 20; //nLevel 0-30 db  default 9db
    // nTargetDB 是值越小，表示最后效果的音量越大
    int nTargetDB = 6; // 取值1-30（6-15比较合适）
    
    int nSample = [self GetRecFileABSD].mSampleRate;
    int nChannel =  [self GetRecFileABSD].mChannelsPerFrame;
    RMAudioProcess process = createRMAudioProcess(nSample, nChannel, nNREnable, nAgcEnable);
    setRMAGCLevel(process, nLevel, nTargetDB);
    setRMNoiseReduceMode(process, nNRMode);
    
    return process;
}

#pragma mark - lazy load
- (NSMutableArray *)peakLevelQueue {
    if (!_peakLevelQueue) {
        _peakLevelQueue = [NSMutableArray new];
    }
    return _peakLevelQueue;
}

- (NSMutableArray *)currentPeakLevelQueue {
    if (!_currentPeakLevelQueue) {
        _currentPeakLevelQueue = [NSMutableArray new];
    }
    return _currentPeakLevelQueue;
}

- (NSMutableArray *)allPeakLevelQueue {
    if (!_allPeakLevelQueue) {
        _allPeakLevelQueue = [NSMutableArray new];
    }
    return _allPeakLevelQueue;
}

- (NSMutableArray *)displayPeakLevelQueue {
    if (!_displayPeakLevelQueue) {
        _displayPeakLevelQueue = [NSMutableArray new];
    }
    return _displayPeakLevelQueue;
}

- (AudioStreamBasicDescription) GetRecFileABSD
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(short);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    //asbd.mFormatFlags      = kAudioFormatFlagsCanonical|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = 32000;
    asbd.mReserved         = 0;
    return asbd;
}

- (AudioStreamBasicDescription) NrFileABSD
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(short);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    //asbd.mFormatFlags      = kAudioFormatFlagsCanonical|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = nrSampleRate;
    asbd.mReserved         = 0;
    return asbd;
}

- (AudioBufferList*) nrBufferList
{
    if(!_nrBufferList)
    {
        _nrBufferList = [EZAudioUtilities audioBufferListWithNumberOfFrames:4096 numberOfChannels:[self NrFileABSD].mChannelsPerFrame interleaved:YES];
    }
    return _nrBufferList;
}

#pragma mark - EZMicrophoneDelegate
- (void)microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {
    
    if (!self.isMicOn) {
        return;
    }
    //    NSLog(@"%@",[NSThread currentThread]);
    self.totalFrames += bufferSize;
    //    [self.conver convertPcmToMp3:bufferList->mBuffers[0] toPath:self.nrFilePath];
    
    int nOut = KBUFFERSIZE - _nrBufferUsedSize;
    int wavOut = KBUFFERSIZE - _wavUsedSize;
    
    int MinBuffer = 0;
    int MinWavBuffer = 0;
    
    getProcessSafeBufferSize(self.audioProcess, bufferList->mBuffers[0].mDataByteSize, &MinBuffer, &MinWavBuffer);
    
    assert(MinBuffer <= nOut );
    assert(MinWavBuffer <= wavOut );
    
    processRMAudio(self.audioProcess, (char*)bufferList->mBuffers[0].mData, bufferList->mBuffers[0].mDataByteSize, _pNRBuffer+_nrBufferUsedSize, &nOut, _wavForm + _wavUsedSize, &wavOut);
    
    if (wavOut > 0) {
        // 真正产生一个有效的样本点
        if (numberOfChannels == 1) {
            char *momentForm = _wavForm+_wavUsedSize;
            short *shortForm = (short *)momentForm;
            CGFloat volume = ABS(shortForm[0])/32767.0;
            [self.allPeakLevelQueue addObject:[NSString stringWithFormat:@"%.2f",volume]];
            [self.peakLevelQueue enqueue:[NSString stringWithFormat:@"%.2f",volume] maxCount:self.maxCount];
        }
        
        
        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            /************** 录音 **************/
            NSTimeInterval curDuration = weakSelf.duration;
            if (curDuration > 5.0) {
                if (!weakSelf.hasRecord5sData) {
                   weakSelf.hasRecord5sData = YES;
                   [self setRightButtonEnable:YES];
                }
            }
            
            [weakSelf.recordTimeLabel setText:[NSString stringWithFormat:@"%02d:%02d/%02d:%02d",(int)curDuration/60,(int)curDuration%60,(int)kMaxRecordTime/60,(int)kMaxRecordTime%60]];
            
            if ((curDuration - kMaxRecordTime) >= 0.f) {
                // 超过最大时长处理，暂停录音
                [weakSelf.recordButton setSelected:NO];
                [weakSelf pauseRecordButtonAction];
                return;
            }
            
            [weakSelf.mWaveFormView setPeakLevelQueue:weakSelf.peakLevelQueue];
            
            // 移动滑动杆
            CGFloat percent = (weakSelf.allPeakLevelQueue.count * 4) / weakSelf.mWaveFormView.width;
            if (percent>=1.0) {
                percent = 1.0;
                [weakSelf.timelineView updateTimeProgress];
            }
            [weakSelf.mWaveFormView setSliderOffsetX:percent];
            
            // 前Ns是否能解析出文字
            if (!weakSelf.hasChecked && (int)curDuration == 5) {
                weakSelf.hasChecked = YES;
                //        [self cancelButtonPressed];
                //        [self recordButtonAction];
                
                float allVoiceLevel = 0.0;
                for (int i=0; i<self.allPeakLevelQueue.count; i++) {
                    float value = [self.allPeakLevelQueue[i] floatValue];
                    allVoiceLevel += value;
                }
                if (allVoiceLevel/self.allPeakLevelQueue.count <= 0.15) {
                    // 声音过小
                    weakSelf.lowVoice = YES;
                }
                //        if (!self.audio2Text.length || self.lowVoice) {
                
                if (weakSelf.lowVoice) {
                    [weakSelf.recordButton setSelected:NO];
                    [weakSelf pausePlay];
                    [weakSelf pauseRecordButtonAction];
                    [weakSelf showAlertViewWithTitle:@"声音太小，是否重录"
                                        subTitle:@"系统检测到您当前录音音量太小，发布后可能会影响您的信用评分"
                                 leftButtonTitle:@"取消"
                                rightButtonTitle:@"重录"
                                      completion:^(BOOL complete) {
                                          if (complete) {
                                              [self confirmRerecord];
                                          }
                                         
                                      }];
                }
            }
        });
    }
    
    _nrBufferUsedSize += nOut;
    _wavUsedSize += wavOut;
    
    int blockSize = [self NrFileABSD].mChannelsPerFrame * sizeof(short);
    int nFrameSize = blockSize *1024;
    while (_nrBufferUsedSize >= nFrameSize) {
        memcpy(self.nrBufferList->mBuffers[0].mData, _pNRBuffer, nFrameSize);
        _nrBufferList->mBuffers[0].mDataByteSize = nFrameSize;
        //        [self.nrRecorder appendDataFromBufferList:_nrBufferList withBufferSize:nFrameSize/blockSize];
        [self.conver convertPcmToMp3:_nrBufferList->mBuffers[0] toPath:self.nrFilePath];
        memmove(_pNRBuffer, _pNRBuffer +nFrameSize, _nrBufferUsedSize - nFrameSize);
        _nrBufferUsedSize -= nFrameSize;
    }
    
    if (_wavUsedSize>=KBUFFERSIZE/2) {
        _wavUsedSize = 0;
    }
}

#pragma mark - EZAudioPlayerDelegate
//- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
//    updatedPosition:(SInt64)framePosition
//        inAudioFile:(EZAudioFile *)audioFile {
//    __weak typeof (self) weakSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (weakSelf.listenButton.selected) {
//            NSInteger index = (NSInteger)(self.ezPlayer.currentTime * 10);
//            CGFloat percent = (index * 4) / (MOL_SCREEN_WIDTH);
//            if (percent>=0.5) {
//                percent = 0.5;
//                index = index+weakSelf.allCount/2; // 跳过半个波形的宽度
//                if (index < weakSelf.displayPeakLevelQueue.count) {
//                    [weakSelf.currentPeakLevelQueue enqueue:weakSelf.displayPeakLevelQueue[index] maxCount:weakSelf.allCount];
//                }
//                CGFloat stride = index*4-MOL_SCREEN_WIDTH/2.0;
//                [weakSelf.timelineView.collectionView setContentOffset:CGPointMake(stride, 0) animated:NO];
//            }
//            // 移动滑动杆
//            [weakSelf.voiceWaveView setSliderOffsetX:percent];
//            [weakSelf.voiceWaveView setPeakLevelQueue:weakSelf.currentPeakLevelQueue];
//        }
//    });
//}


- (void)audioPlayer:(EZAudioPlayer *)audioPlayer reachedEndOfAudioFile:(EZAudioFile *)audioFile {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recordButton setSelected:NO];
        [weakSelf pausePlay];
    });
}



- (void)confirmRerecord {
    self.hasRecordData = NO;
    self.hasRecord5sData = NO;
    [self setRightButtonEnable:NO];
    [self setButtonDisableStatus];
    [self.recordTimeLabel setText:[NSString stringWithFormat:@"00:00/%02d:%02d",(int)kMaxRecordTime/60,(int)kMaxRecordTime%60]];
    
    [self.currentPeakLevelQueue removeAllObjects];
    [self.displayPeakLevelQueue removeAllObjects];
    [self.peakLevelQueue removeAllObjects];
    [self.allPeakLevelQueue removeAllObjects];
    
    [self.mWaveFormView setPeakLevelQueue:self.peakLevelQueue];
    self.mWaveFormView.sliderIV.x = 0;
    [self.timelineView resetTimeProgress];
    
    self.originalOffset = CGPointMake(0, 0);
    
    // 重置
    self.hasChecked = NO;
    self.lowVoice = NO;
    
    self.totalFrames = 0;
    memset(_wavForm, 0, KBUFFERSIZE);
    memset(_pNRBuffer, 0, KBUFFERSIZE);
    _wavUsedSize = 0;
    _nrBufferUsedSize = 0;
    
    // 删除本地音频文件
    [NSString ja_removeFilePath:self.nrFilePath];
}

- (NSTimeInterval)duration
{
    return (NSTimeInterval) self.totalFrames / nrSampleRate;
}

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
               leftButtonTitle:(NSString *)leftTitle
              rightButtonTitle:(NSString *)rightTitle
                    completion:(void (^)(BOOL complete))completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:subTitle preferredStyle:UIAlertControllerStyleAlert];
    
    if (leftTitle.length) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion(NO);
            }
        }];
        [alertController addAction:cancel];
    }
    if (rightTitle.length) {
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (completion) {
                completion(YES);
            }
        }];
        [alertController addAction:ok];
    }
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)showAlertViewWithTitle:(NSString *)title
                      subTitle:(NSString *)subTitle
                    completion:(void (^)(BOOL complete))completion {
    [self showAlertViewWithTitle:title subTitle:subTitle leftButtonTitle:@"取消" rightButtonTitle:@"确定" completion:completion];
}

- (void)dealloc {
    if (_wavForm) {
        free(_wavForm);
        _wavForm = NULL;
    }
    
    if (_pNRBuffer) {
        free(_pNRBuffer);
        _pNRBuffer = NULL;
    }
    
    if (_audioProcess) {
        [self deleteAudioProcess:_audioProcess];
        _audioProcess = NULL;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [JAVoicePlayerManager shareInstance].isInRecord = NO;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)deleteAudioProcess:(RMAudioProcess)process
{
    deleteRMAudioProcess(process);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
