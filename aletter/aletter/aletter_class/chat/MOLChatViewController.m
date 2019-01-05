//
//  MOLChatViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChatViewController.h"
#import "ChatTimeCell.h"
#import "ChatTextCell.h"
#import "ChatImageCell.h"
#import "ChatVoiceCell.h"
#import "HPGrowingTextView.h"
#import "MOLHead.h"
#import "TZImagePickerController.h"
#import "CustomButton.h"
#import "SpectrumView.h"
//#import "AudioPlayer.h"
//#import "VoiceRecorderBaseVC.h"
#import "MOLMessageRequest.h"


#import "MOLChatModel.h"
#import "MOLStoryModel.h"


#import "CIMSUCModel.h"
#import "CIMUserMsg.h"
#import "ChatDetailModel.h"
#import "MOLLightUserModel.h"
#import "MOLUserModel.h"
#import "MOLMsgOtherModel.h"
#import "ChatStoryTipCell.h"
#import "ChatSrotyCardCell.h"
#import "ToolsHelper.h"
#import "CIMUserMsg.h"
#import "ChatTextCell.h"
#import "ChatImageCell.h"
#import "ChatVoiceCell.h"




static const NSInteger  kKeyboardHeight =216;
static const CGFloat    kTabBarHeight   =49;
static const CGFloat    kNavBatHeigh    =64;
static const NSInteger  KSec            =60;
static const NSInteger  KPageSize       =20;

@interface MOLChatViewController ()<HPGrowingTextViewDelegate,TZImagePickerControllerDelegate,CustomButtonDelegate,/*AudioPlayerDelegate,*/UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)UIView *inputTextContainerView;
@property (nonatomic ,strong)HPGrowingTextView *inputTextView;
@property (nonatomic ,strong)UIButton *voiceButton;
@property (nonatomic ,strong)UIButton *albumButton;
// 相册相关属性
@property (nonatomic,assign) NSInteger maxCountTF;  ///< 照片最大可选张数，设置为1即为单选模式
@property (nonatomic,assign) NSInteger columnNumberTF; ///<照片每行显示多少张
@property (nonatomic,strong) NSMutableArray *selectedPhotos;  ///< 表示选中图片资源
@property (nonatomic,strong) NSMutableArray *selectedAssets; ///<表示图片相关资源
@property (nonatomic,assign) BOOL isSelectOriginalPhoto;  ///< yes 表示是原图
//语音布局
@property (nonatomic,strong) UIView *audioView; //录音UI
@property (nonatomic,strong) UILabel *tipLable; //提示
@property (nonatomic,strong) UILabel *timeLable; //录音时间show
@property (nonatomic,strong) CustomButton *playButotn; // 播放按钮
@property (nonatomic,strong) SpectrumView *spectrumView;  // 音波动画
@property (nonatomic,assign) BOOL isPlayStatus; //yes表示正在录音 默认No

///////////////////////////
@property (nonatomic,assign) NSInteger pageNum;
@property (nonatomic,assign) NSInteger pageSize;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@property (nonatomic,strong) ChatDetailModel *chatDetailDto;
@property (nonatomic,strong) UIBarButtonItem *rightItem;
@property (nonatomic,strong) MOLUserModel *user;
@property (nonatomic,strong) MOLStoryModel *msgStoryDto;
@property (nonatomic,strong) MOLMsgOtherModel *msgOtherDto;

@property (nonatomic,strong) UITableView    *tableV;

@end

@implementation MOLChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*****************导航条设置****************/
    [self layoutNavigationUI];
    
    /*****************通知监听****************/
    [self akeybordController];
    
    /*****************数据初始化****************/
    [self initData];
    
    /******************UI布局*****************/
    [self layoutUI];
    [self layoutVoiceUI];
    
    /***************网络请求事件***************/
    if (self.chatId && self.chatId.length>0) { //表示存在会话
        [self getMessageListNetworkData];
        [self getChatDetailsNetworkData];
    }
    
}
#pragma
#pragma 网络请求

- (void)getChatDetailsNetworkData{
    //获取话题详情
    NSMutableDictionary *dic =[NSMutableDictionary new];
    [dic setObject:self.chatId?self.chatId:@"" forKey:@"chatId"];
    __weak __typeof(self) weakSelf = self;
    [[[MOLMessageRequest alloc] initRequest_chatStoryInfoWithParameter:dic parameterId:self.chatId] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code ==MOL_SUCCESS_REQUEST) {
            ChatDetailModel *model =(ChatDetailModel *)responseModel;
            if (model) {
                weakSelf.chatDetailDto =model;
                
                MOLUserModel *user =[MOLUserModel new];
                if ([MOLUserManagerInstance user_getUserInfo]) {
                    
                    user =[MOLUserManagerInstance user_getUserInfo];
                    
                    if (![model.ownUser.userId isEqualToString:user.userId]) {
                        weakSelf.chatDetailDto.ownUser =model.toUser;
                        weakSelf.chatDetailDto.toUser =model.ownUser;
                    }
                }
                
                if (weakSelf.chatDetailDto.ownUser.canClose==1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.rightItem =[UIBarButtonItem mol_barButtonItemWithImageName:@"三个点" highlightImageName:@"三个点" targat:self action:@selector(reportStory:)];
                        self.navigationItem.rightBarButtonItem = self.rightItem;
                    });
                }
                
                if (weakSelf.chatDetailDto.isClose==0) { //未关闭
                    [self.inputTextContainerView setHidden:NO];
                }
                
                
            }
        }else{
            
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}
- (void)getMessageListNetworkData{
    //获取历史会话列表
    NSMutableDictionary *dic =[NSMutableDictionary new];
    [dic setObject:[NSString stringWithFormat:@"%ld",self.pageNum] forKey:@"pageNum"];
    [dic setObject:[NSString stringWithFormat:@"%ld",self.pageSize] forKey:@"pageSize"];
    [dic setObject:self.chatId?self.chatId:@"" forKey:@"chatId"];
    [dic setObject:@"" forKey:@"chatLogId"];
    
   
    [[[MOLMessageRequest alloc] initRequest_messageContentWithParameter:dic] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code ==MOL_SUCCESS_REQUEST) {
            CIMSUCModel *sucModel =(CIMSUCModel *)responseModel;
            if (sucModel.resBody.count<KPageSize) {
                //表示没有历史数据了,加载显示帖子类型
                
                
            }
         //   [weakSelf.dataSourceArr addObjectsFromArray: sucModel.resBody];
        }else{
            
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

- (void)getCatDetailsNetworkData{
    
}

-(void)layoutNavigationUI{
    
    [self basevc_setCenterTitle:self.userModel.userName?self.userModel.userName:@"" titleColor:HEX_COLOR(0xffffff)];
    
//    UITapGestureRecognizer  *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
//    [self.view addGestureRecognizer:tapRecognizer];
}
-(void)akeybordController{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopOverRecorder) name:@"stopOverRecorder" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];
    
}
- (void)initData{
    
    
    NSLog(@"%@---%@---%@",self.chatId,self.storyModel,self.userModel);
    
    self.selectedPhotos =[NSMutableArray new];
    self.selectedAssets =[NSMutableArray new];
    self.maxCountTF =1;
    self.columnNumberTF =4;
    self.pageNum =0;
    self.pageSize =20;
    self.dataSourceArr =[NSMutableArray new];
    self.chatDetailDto =[ChatDetailModel new];
    self.user =[MOLUserModel new];
    self.msgOtherDto =[MOLMsgOtherModel new];
    if ([MOLUserManagerInstance user_getUserInfo]) {
        self.user =[MOLUserManagerInstance user_getUserInfo];
    }
    self.msgStoryDto =[MOLStoryModel new];
   
    
    if (!(self.chatId && self.chatId.length>0)) { //表示不存在会话
        
        MOLMsgOtherModel *msgOther =[MOLMsgOtherModel new];
        msgOther.msgType =EIMMSGOTHER_StoryText;
        msgOther.stamp =[NSDate date];
        msgOther.msg =@"从这个罐头开启一段对话";
        
        MOLMsgOtherModel *timeDto =[MOLMsgOtherModel new];
        timeDto.msgType =EIMMSGOTHER_TIME;
        timeDto.stamp =msgOther.stamp;
        [self.dataSourceArr addObject: timeDto];
        [self.dataSourceArr addObject: msgOther];
        
        MOLMsgOtherModel *msgOtherCard =[MOLMsgOtherModel new];
        msgOtherCard.msgType =EIMMSGOTHER_StorCard;
        msgOtherCard.storyDto =self.storyModel;
        [self.dataSourceArr addObject: msgOtherCard];

    }
}
- (void)loadView{
    [super loadView];
    NSLog(@"loadView");
}
- (void)layoutUI{
    //[AudioPlayer sharedAudioPlayer].delegate=self;
    
    [self.view addSubview:self.tableV];
    
    [self.view addSubview:self.inputTextContainerView];
    [self.inputTextContainerView addSubview:self.inputTextView];
    [self.inputTextContainerView addSubview:self.albumButton];
    [self.inputTextContainerView addSubview:self.voiceButton];
    
    [self.inputTextContainerView setFrame:CGRectMake(0,MOL_SCREEN_HEIGHT-kNavBatHeigh-kTabBarHeight, MOL_SCREEN_WIDTH, kTabBarHeight)];
    [self.albumButton setFrame:CGRectMake(MOL_SCREEN_WIDTH-6.0-44,self.inputTextContainerView.height-kTabBarHeight, 44, kTabBarHeight)];
    [self.voiceButton setFrame:CGRectMake(MOL_SCREEN_WIDTH-6.0-44-6.0-44,self.albumButton.origin.y, 44, kTabBarHeight)];
    [self.inputTextView setFrame:CGRectMake(20,(kTabBarHeight-36)/2.0,MOL_SCREEN_WIDTH-20-100, 36)];
    [self.inputTextView.internalTextView becomeFirstResponder];
}

- (void)layoutVoiceUI{
    [self.view addSubview:self.audioView];
    [self.audioView addSubview:self.timeLable];
    [self.audioView addSubview:self.spectrumView];
    
    [self.audioView addSubview:self.playButotn];
    [self.audioView addSubview:self.tipLable];
    [self.audioView setFrame:CGRectMake(0, MOL_SCREEN_HEIGHT-kNavBatHeigh-kKeyboardHeight, MOL_SCREEN_HEIGHT, kKeyboardHeight)];

    [self.timeLable setFrame:CGRectMake((MOL_SCREEN_WIDTH-95)/2.0, 30, 95, 22)];
    
    [self.playButotn setFrame:CGRectMake((MOL_SCREEN_WIDTH-80)/2.0,self.timeLable.bottom+30, 80, 80)];
    
    [self.tipLable setFrame:CGRectMake(0,self.playButotn.bottom+20, MOL_SCREEN_WIDTH,20)];
    [self.timeLable setText:@"60‘’"];
    
    self.spectrumView.width = 200;
    self.spectrumView.height = 40;
    self.spectrumView.middleInterval = 100;
    [self.spectrumView setCenter: self.timeLable.center];
   
}

#pragma mark -
#pragma mark 懒加载 输入组件
-(UITableView *)tableV{
    if (!_tableV) {
        _tableV =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH,MOL_SCREEN_HEIGHT) style:UITableViewStylePlain];
        [_tableV setBackgroundColor: [UIColor clearColor]];
        [_tableV setShowsVerticalScrollIndicator:NO];
        [_tableV setDataSource:self];
        [_tableV setDelegate:self];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
        [_tableV addGestureRecognizer:tapRecognizer];
        _tableV.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _tableV;
}

- (UIView *)inputTextContainerView{
    if (!_inputTextContainerView) {
        _inputTextContainerView =[UIView new];
        [_inputTextContainerView setBackgroundColor:HEX_COLOR(0xffffff)];
        [_inputTextContainerView setHidden:NO];
    }
    return _inputTextContainerView;
}

- (HPGrowingTextView *)inputTextView{
    if (!_inputTextView) {
        _inputTextView = [HPGrowingTextView new];
        [_inputTextView setFont:MOL_LIGHT_FONT(14)];
        _inputTextView.placeholderColor=HEX_COLOR(0x091F38);
        [_inputTextView setTextColor:HEX_COLOR(0x091F38)];
        _inputTextView.placeholder=@"回复楼主";
        [_inputTextView setIsScrollable:YES];
        [_inputTextView setMinNumberOfLines:1];
        [_inputTextView setMaxNumberOfLines:5];
        [_inputTextView setReturnKeyType:UIReturnKeySend];
        [_inputTextView setDelegate:self];
        [_inputTextView setHidden:NO];
       
    }
    return _inputTextView;
}

- (UIButton *)voiceButton{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceButton addTarget:self action:@selector(voiceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceButton setBackgroundColor:[UIColor clearColor]];
        [_voiceButton setImage:[UIImage imageNamed:@"麦克风"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"键盘"] forState:UIControlStateSelected];
       
    }
    return _voiceButton;
}

- (UIButton *)albumButton{
    if (!_voiceButton) {
        _albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_albumButton addTarget:self action:@selector(albumButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_albumButton setBackgroundColor:[UIColor clearColor]];
        [_albumButton setImage:[UIImage imageNamed:@"遇见"] forState:UIControlStateNormal];
       
    }
    return _albumButton;
}

#pragma mark -
#pragma mark 懒加载 音频布局
- (UIView *)audioView{
    if (!_audioView) {
        _audioView =[UIView new];
        [_audioView setBackgroundColor: HEX_COLOR(0xffffff)];
        [_audioView setHidden:YES];
        
    }
    return _audioView;
}

- (SpectrumView *)spectrumView{
    if (!_spectrumView) {
        _spectrumView = [[SpectrumView alloc] init];
        [_spectrumView setBackgroundColor: [UIColor clearColor]];
        _spectrumView.hidden = YES;
    }
    return _spectrumView;
}

- (UILabel *)timeLable{
    if (!_timeLable) {
        _timeLable =[UILabel new];
        _timeLable.textColor = HEX_COLOR(0x999EAD);
        _timeLable.font = MOL_REGULAR_FONT(16);
        _timeLable.textAlignment = NSTextAlignmentCenter;
        _timeLable.text = @"00:00/01:00";
        _timeLable.hidden = YES;
        
    }
    return _timeLable;
}

- (CustomButton *)playButotn{
    if (!_playButotn) {
        _playButotn =[CustomButton buttonWithType:UIButtonTypeCustom];
        [_playButotn setImage:[UIImage imageNamed:@"按住说"] forState:UIControlStateNormal];
        [_playButotn setDelegate:self];
//        [_playButotn addTarget:self action:@selector(playButotnEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _playButotn;
}

- (UILabel *)tipLable{
    if (!_tipLable) {
        _tipLable =[UILabel new];
        _tipLable.text = @"按住说";
        _tipLable.textColor = HEX_COLOR(0x999EAD);
        _tipLable.font = MOL_MEDIUM_FONT(12);
        _tipLable.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLable;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}
- (void)viewDidLayoutSubviews{
   // [super viewDidLayoutSubviews];
    NSLog(@"viewDidLayoutSubviews");
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"viewWillDisappear");
}

- (void)viewWillLayoutSubviews{
   // [super viewWillLayoutSubviews];
     NSLog(@"viewWillLayoutSubviews");

}

#pragma mark
#pragma mark 事件响应
- (void)playButotnEvent:(UIButton *)sender{
    sender.selected =!sender.isSelected;
    if (sender.selected) {//表示选中
        
    }else{//表示未选中
        
    }
}

- (void)albumButtonAction:(UIButton *)sender{
    [self.audioView setAlpha:0];
    NSLog(@"相册事件响应");
    __weak __typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请在手机系统“设置-隐私-照片”选项中，允许访问您的相册。" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                    
                    [alert show];
                    
                });
                
            }
                break;
                
            case PHAuthorizationStatusAuthorized:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf pushTZImagePickerController];
                });
                
            }
                break;
        }
    }];
}

- (void)voiceButtonAction:(UIButton *)sender{
    NSLog(@"语音事件响应");
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {//表示选中
        [self functionViewWillShow];
        //[self.inputTextView.inter:NO];
        [self.albumButton setEnabled:NO];
    }else{//表示未选中
        [self.inputTextView becomeFirstResponder];
        //[self.inputTextView setEditable:YES];
        [self.albumButton setEnabled:YES];
    }
}

#pragma mark-
#pragma mark  UITapGestureRecognizer method
-(void)tapGestureRecognizerAction:(UITapGestureRecognizer *)tap{
    if (tap) {
        [self keyEventAction];
    }
}

#pragma mark - Function view show and hide
- (void)functionViewWillShow
{
    [self.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.03 animations:^{
        CGRect containerFrame = self.inputTextContainerView.frame;//0 204 320 40
        containerFrame.origin.y = MOL_SCREEN_HEIGHT-kNavBatHeigh- (kKeyboardHeight + containerFrame.size.height); //键盘高度适配
        self.inputTextContainerView.frame = containerFrame;
        //tableV.frame=CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, kScreenHeight-kNavigationViewHeight-ios_adapter_heigh-kKeyboardHeight-kNavigationViewHeight);
//        if ([_noticeDetialDataArray count] > 2) {
//            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:[_noticeDetialDataArray count]-1 inSection:0];
//            if (indexpath.row < [tableV numberOfRowsInSection:0]) {
//                [tableV scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//            }
//        }
        [self.audioView setAlpha:1];
    } completion:^(BOOL finished) {

    }];
}

- (void)functionViewWillHide{
    [self.inputTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.03 animations:^{
        CGRect containerFrame = self.inputTextContainerView.frame;//0 204 320 40
        containerFrame.origin.y = MOL_SCREEN_HEIGHT- kNavBatHeigh - containerFrame.size.height;
        self.inputTextContainerView.frame = containerFrame;
        // [tableV setFrame:CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, kScreenHeight-kNavigationViewHeight-ios_adapter_heigh-kNavigationViewHeight)];
        [self.audioView setAlpha:0];
    } completion:^(BOOL finished) {
        
    }];
}

//键盘操作
-(void) keyEventAction{
    [self functionViewWillHide];
    [self.voiceButton setSelected:NO];
    [self.inputTextView setEditable:YES];
    [self.albumButton setEnabled:YES];
}



#pragma mark-
#pragma mark Keyboard show and hide
- (void)keyboardWillShow:(NSNotification *)note{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect containerFrame = self.inputTextContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.inputTextContainerView.frame=containerFrame;
    //tableV.frame =  CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, kFullScreenSize.height-64-kNavigationViewHeight - keyboardBounds.size.height );
    [UIView commitAnimations];
//    if ([_noticeDetialDataArray count] > 2) {
//        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:[_noticeDetialDataArray count]-1 inSection:0];
//        if (indexpath.row < [tableV numberOfRowsInSection:0]) {
//            [tableV scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
//    }
    //一切还原
//    [expressionBtn setImage:[UIImage imageNamed:@"J_logo (10).png"] forState:UIControlStateNormal];
//    _exepressionOk=NO;
//    [plusButton setImage:[UIImage imageNamed:@"J_logo (6).png"] forState:UIControlStateNormal];
//    plusButton.transform=CGAffineTransformMakeRotation(0);
//    _plusOK=NO;
}

- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect containerFrame = self.inputTextContainerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.inputTextContainerView.frame = containerFrame;
    //tableV.frame = CGRectMake(tableV.frame.origin.x, tableV.frame.origin.y, tableV.frame.size.width, kFullScreenSize.height-kNavigationViewHeight-20-44);
    [UIView commitAnimations];
}

#pragma mark-
#pragma mark CustomTouchUIView delegate method
//开始录音
-(void)getTouchesBeganPointValue:(CGPoint)point andUIview:(UIView *)view{
    self.isPlayStatus =YES;
   // [[AudioPlayer sharedAudioPlayer] beginRecordAudio];
    NSLog(@"开始录音");
}

//结束录音
-(void)getTouchesEndedPointValue:(CGPoint)point andUIView:(UIView *)view{
    NSLog(@"录音结束");
    self.isPlayStatus =NO;
    [self endRecordAction];
}

#pragma mark -  录制试听管理者 录制的代理回调
- (void)inputRecordWithDuration:(CGFloat)duration volume:(CGFloat)volume drawVolume:(CGFloat)drawVolume
{
    if ((duration - 60) > 0.f) {
        self.isPlayStatus =NO;
        // 完成录音
        [self endRecordAction];
        return;
    }
    
    self.spectrumView.level = drawVolume;
    drawVolume = drawVolume / 20.0;
    // 绘制时间和音量动画
    NSString *time = [NSString stringWithFormat:@"%02d:%02d/%02d:00",(int)duration/60,(int)duration%60,(int)KSec/60];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.timeLable.text = time;
        [weakSelf.timeLable setHidden:NO];
        [weakSelf.spectrumView setHidden:NO];
    }) ;
   // self.voiceDuration = duration;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if (self.isPlayStatus == YES) {//判断是否正在录音中
        [self endRecordAction];
        [self endRecordAudio];
    }
}
//录音满60秒执行的方法
-(void)stopOverRecorder{
    self.isPlayStatus =NO;
    [self endRecordAction];
    [self endRecordAudio];
}

-(void) endRecordAction{
//    [[AudioPlayer sharedAudioPlayer] stopRecorder];
//    [[AudioPlayer sharedAudioPlayer] stopTimer];
    [self.timeLable setText:@"00:00/01:00"];
    [self.timeLable setHidden:YES];
    [self.albumButton setEnabled:YES];
    [self.spectrumView setHidden: YES];
    
}
#pragma mark-
#pragma mark 音频文件上传方法
- (void)endRecordAudio{
   
//    [[AudioPlayer sharedAudioPlayer] stopRecorder];
//    [[AudioPlayer sharedAudioPlayer] stopTimer];
    
//    if ([AudioPlayer sharedAudioPlayer].audioTimer < 1.0001) {
//        [VoiceRecorderBaseVC deleteFileAtPath:[AudioPlayer sharedAudioPlayer].recordFilePath];
//        return;
//    }
    
#if 0
    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
    [_dic setObject:receiverDto.receiverID forKey:@"reciever"];
    [_dic setObject:receiverDto.receiverType forKey:@"type"];
    [_dic setObject:userIdStr forKey:@"userId"];
    [_dic setObject:userNameStr forKey:@"userName"];
    [_dic setObject:userPhotoStr forKey:@"userPhoto"];
    //    [_dic setObject:[NSString stringWithFormat:@"%.2f",self._audioTimer] forKey:@"voiceTimes"];
    [_dic setObject:[NSString stringWithFormat:@"%.2f",[AudioPlayer sharedAudioPlayer].audioTimer] forKey:@"voiceTimes"];
    NSString *timer = [ToolHelper getNowTimeWithType:-2];
    
    if ([_noticeDtoArray count]>0) {
        NSString *timersss = timer;
        for (BmsMessageDto *dtosss in _noticeDtoArray) {
            if ([timersss compare:dtosss.crtime] == NSOrderedAscending) {
                timersss = dtosss.crtime;
            }
        }
        if ([timer compare:timersss] == NSOrderedAscending) {
            NSInteger seconds = (NSInteger)[ToolHelper getSecondsFromTimeString:timersss]+1;
            timer = [ToolHelper getStringTimeWithDataTime:[NSDate dateWithTimeIntervalSince1970:seconds]];
        }
    }
    
    BmsMessageDto *_dto = [[BmsMessageDto alloc] init];
    _dto.reciever = receiverDto.receiverID;
    _dto.chatId = receiverDto.chatId;
    if (receiverDto.chatId) {
        [_dic setObject:receiverDto.chatId forKey:@"chatId"];
    }
    if ([receiverDto.receiverType isEqualToString:@"class"]||[receiverDto.receiverType isEqualToString:@"custom"]) {
        _dto.userId = userIdStr;    //不确定  后期优化
        _dto.eventid = receiverDto.receiverID;  //不确定 后期优化
        _dto.eventname = receiverDto.receiverName;
        _dto.eventphoto = receiverDto.receiverPhoto;
    }else if([receiverDto.receiverType isEqualToString:@"chat"]){
        _dto.userName = receiverDto.receiverName;
        _dto.headurl = receiverDto.receiverPhoto;
        _dto.userId = userIdStr;    // 不确定  后期优化
    } // RCK begain 添加heart
    else if ([receiverDto.receiverType isEqualToString:@"heart"]) {
        
        _dto.userName = @"心灵驿站";
        _dto.headurl = receiverDto.receiverPhoto;
        _dto.userId = userIdStr;
    }
    // RCK end
    
    if ([ToolHelper isBlankString:_dto.chatId]) {
        _dto.chatId = receiverDto.receiverID;
    }
    
    _dto.type= receiverDto.receiverType;
    _dto.crtime = timer;
    _dto.islocal = @"-1";
    _dto.msgtype = @"voice";
    _dto.state = @"SENDING";
    _dto.contentsize = NSStringFromCGSize(CGSizeMake(123, 30));
    _dto.readedflag = 0;
    _dto.contentmemo=@"语音消息";
    //    _dto.content = [NSString stringWithFormat:@"%@.wav",self.audioPath];
    _dto.content = [AudioPlayer sharedAudioPlayer].recordFilePath;//存放的是原录音文件，即wav模式
    //    _dto.times = [NSString stringWithFormat:@"%.2f",self._audioTimer];
    _dto.times = [NSString stringWithFormat:@"%.2f",[AudioPlayer sharedAudioPlayer].audioTimer];
    meesageId = [[NSString alloc] initWithFormat:@"%llu", [ToolHelper getCurrentMilliSecondsTime]];
    localChatId = [[NSString alloc] initWithFormat:@"%@",_dto.chatId];
    _dto.msgId = meesageId;
    BmsMessageDto *messageDto=[[BmsMessageDto alloc] init];
    [messageDto copy:_dto];
    //  if (![receiverDto.receiverType isEqualToString:@"class"]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTICE_NOTIFICATION object:messageDto];
    //  }
    
    [_noticeDtoArray addObject:_dto];
    [self tableDataReload];
    
    if ([_noticeDetialDataArray count] > 2) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:[_noticeDetialDataArray count]-1 inSection:0];
        if (indexpath.row < [tableV numberOfRowsInSection:0]) {
            [tableV scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    //音频上传
    //    [chatNetworkAgent voiceRequestNetworkResponseMethod:_dic andVoicePath:[NSString stringWithFormat:@"%@.wav",self.audioPath]];
    
    
    //获取文件路径
    
    NSString *_amrPath = [VoiceRecorderBaseVC getPathByFileName:[AudioPlayer sharedAudioPlayer].recordFileName ofType:@"amr"];
    
    //开始转换格式
    
    // wav转amr
    if ([VoiceConverter ConvertWavToAmr:[AudioPlayer sharedAudioPlayer].recordFilePath amrSavePath:_amrPath]) {
        
        isAmr = NO;
        [chatNetworkAgent voiceRequestNetworkResponseMethod:_dic andVoicePath:_amrPath];
        //        NSLog(@"wav转amr成功");
        
    }else{
        
        isAmr = YES;
        [chatNetworkAgent voiceRequestNetworkResponseMethod:_dic andVoicePath:[AudioPlayer sharedAudioPlayer].recordFilePath];
        //        NSLog(@"wav转amr失败");
        
    }
#endif
    
}



#pragma mark-
#pragma mark HPGrowingTextViewDelegate method
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView{

    return YES;
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView{
    return YES;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendInformationToServer];
        return NO;
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{

}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    float diff = (growingTextView.frame.size.height - height);
    CGRect frame = self.inputTextContainerView.frame;
    frame.size.height -= diff;
    frame.origin.y +=diff;
    [self.inputTextContainerView setFrame:frame];
    [self.voiceButton setFrame:CGRectMake(MOL_SCREEN_WIDTH-6.0-44-6.0-44,self.inputTextContainerView.height-49, 44, 49)];
    [self.albumButton setFrame:CGRectMake(MOL_SCREEN_WIDTH-6.0-44,self.inputTextContainerView.height-49, 44, 49)];
    
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height{
    
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView{
    
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    return YES;
}

- (void)reportStory:(UIButton *)sender{
    NSLog(@"跳转事件");
}

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    if (self.maxCountTF <= 0) {
        return;
    }
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxCountTF columnNumber:self.columnNumberTF delegate:self pushPhotoPickerVc:YES];
    [imagePickerVc setNaviBgColor: [UIColor clearColor]];
    
    
    //[imagePickerVc setAllowTakePicture:NO];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - TZImagePickerControllerDelegate
// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    //处理获取照片数据
    NSLog(@"相册返回事件");
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

#pragma mark-
#pragma mark UITableViewDataSource method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 数据对象数量
    return [self.dataSourceArr count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @try {
        //  处理Cell
        if (self.dataSourceArr.count>0) {
            if (self.dataSourceArr.count>indexPath.row) {
                id object = [self.dataSourceArr objectAtIndex:indexPath.row];
                
                if ([object isKindOfClass:[MOLMsgOtherModel class]]) {
                    MOLMsgOtherModel *msg =[MOLMsgOtherModel new];
                    msg =(MOLMsgOtherModel *)object;
                    
                    switch (msg.msgType) {
                        case EIMMSGOTHER_StoryText:
                        {
                            static NSString *cellId = @"ChatStoryTipCell";
                            ChatStoryTipCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
                            if (!cell) {
                                cell =[[ChatStoryTipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                            }
                            [cell chatStoryTipCell:msg];
                            return cell;
                        }
                            break;
                        case EIMMSGOTHER_StorCard:
                        {
                            static NSString *cellId = @"ChatSrotyCardCell";
                            ChatSrotyCardCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
                            if (!cell) {
                                cell =[[ChatSrotyCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                            }
                            [cell chatSrotyCardCell:msg];
                            return cell;
                        }
                            break;
                        
                        default:
                        {
                            static NSString *cellId = @"ChatTimeCell";
                            ChatTimeCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
                            if (!cell) {
                                cell =[[ChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                            }
                            [cell chatTimeCell:msg];
                            return cell;
                            
                        }
                            break;
                    }
                   
                }
                else{
                    if ([object isKindOfClass:[CIMUserMsg class]]) {
                        CIMUserMsg *msg =[CIMUserMsg new];
                        msg =(CIMUserMsg *)object;
                        switch (msg.chatType.integerValue) {
                            case 0: //文字
                            {
                                static NSString *cellId = @"ChatTextCell";
                                ChatTextCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
                                if (!cell) {
                                    cell =[[ChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                                }
                                [cell chatTextCell:msg];
                                return cell;
                            }
                                
                                break;
                            case 1: //图片
                            {
                                static NSString *cellId = @"ChatImageCell";
                                ChatImageCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
                                if (!cell) {
                                    cell =[[ChatImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                                }
                                [cell chatImageCell:msg];
                                return cell;
                            }
                                
                                break;
                            case 2: //语音
                            {
                                static NSString *cellId = @"ChatVoiceCell";
                                ChatVoiceCell *cell =[tableView dequeueReusableCellWithIdentifier:cellId];
                                if (!cell) {
                                    cell =[[ChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                                }
                                [cell chatVoiceCell:msg];
                                return cell;
                            }
                                
                                break;
                        }
                    }
                }

                }
            }
    }
    @catch (NSException *exception) {
        //        [ToolHelper bmsLog:[NSString stringWithFormat:@"聊天页面,消息展示异常%@: %@", [exception name], [exception reason]]];
    }
    @finally {
        
    }
}
#pragma mark-
#pragma mark UITableViewDelegate method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置指定Cell高度
    CGSize size = CGSizeMake(0, 40);
    if (self.dataSourceArr.count>indexPath.row) {
        id object = [self.dataSourceArr objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MOLMsgOtherModel class]]) {
            MOLMsgOtherModel *_dto =  [self.dataSourceArr objectAtIndex:indexPath.row];
            switch (_dto.msgType) {
                case EIMMSGOTHER_StoryText:
                    size.height =20+20;
                    break;
                case EIMMSGOTHER_StorCard:
                    size.height =120+20;
                    break;
                    
                default:
                    size.height =17+20;
                    break;
            }
        }
        else{
            CIMUserMsg *msgDto =[self.dataSourceArr objectAtIndex:indexPath.row];
            switch (msgDto.chatType.integerValue) {
                case 0: //文字
                {
                    
                    CGFloat h = [msgDto.content boundingRectWithSize:CGSizeMake(MOL_SCREEN_WIDTH-40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)} context:nil].size.height;
                    size.height =17+h+11;
                }
                    
                    break;
                case 1: //图片
                    
                    break;
                case 2: //语音
                    
                    break;
                    
            }
            
        }
    }
    return size.height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark-
#pragma mark 发布消息内容网络请求事件
#pragma mark- 聊天之文本网络请求
-(void)sendInformationToServer{
    //发送数据后，删除文本框里面的数据
    
    if([ToolsHelper isBlankString:self.inputTextView.text]){
        [MOLToast toast_showWithWarning:YES title:@"发送内容不能为空！"];
        
        return;
    }
    
    self.inputTextView.text = [ToolsHelper DelbeforeEnter:self.inputTextView.text];
    self.inputTextView.text = [ToolsHelper DelbehindEnter:self.inputTextView.text];
    if(self.inputTextView.text.length > 1000){
        [MOLToast toast_showWithWarning:YES title:@"发送内容过长，请分条发送"];
        return;
    }
    
    //获取历史会话列表
    NSMutableDictionary *dic =[NSMutableDictionary new];
    [dic setObject:@"0" forKey:@"chatType"];
    [dic setObject:self.inputTextView.text forKey:@"content"];
    [dic setObject:self.storyModel.storyId?self.storyModel.storyId:@"" forKey:@"storyId"];
    [dic setObject:self.userModel.userId forKey:@"toUserId"];
    [dic setObject:self.userModel.userName forKey:@"toUserName"];
    [dic setObject:[MOLUserManagerInstance user_getUserLastName] forKey:@"userName"];
    __weak __typeof(self) weakSelf = self;
    [[[MOLMessageRequest alloc] initRequest_publishMessageWithParameter:dic] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code ==MOL_SUCCESS_REQUEST) {
            weakSelf.inputTextView.text = @"";
            CIMUserMsg *msg =(CIMUserMsg *)responseModel;
            [weakSelf.dataSourceArr addObject:msg];
            [weakSelf.tableV reloadData];
            
        }else{
            
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
    
   
    
    
#if 0
    
    
    NSString * sendStr = [[SensitiveWordTools sharedInstance] filter:inputTextView.text];
    NSMutableDictionary *_dic = [NSMutableDictionary dictionary];
    NSString * uuid = [ToolHelper getDeviceUUID];
    [_dic setObject:receiverDto.receiverID forKey:@"reciever"];
    [_dic setObject:sendStr forKey:@"content"];
    [_dic setObject:receiverDto.receiverType forKey:@"type"];
    [_dic setObject:userIdStr forKey:@"userId"];
    [_dic setObject:userNameStr forKey:@"userName"];
    [_dic setObject:userPhotoStr forKey:@"userPhoto"];
    [_dic setObject:uuid forKey:@"localMsgId"];
    
    NSString *timer = [ToolHelper getNowTimeWithType:-2];
    if ([_noticeDtoArray count]>0) {
        NSString *timersss = timer;
        for (BmsMessageDto *dtosss in _noticeDtoArray) {
            if ([timersss compare:dtosss.crtime] == NSOrderedAscending) {
                timersss = dtosss.crtime;
            }
        }
        if ([timer compare:timersss] == NSOrderedAscending) {
            UInt64 seconds = [ToolHelper getSecondsFromTimeString:timersss]+1;
            timer = [ToolHelper getStringTimeWithDataTime:[NSDate dateWithTimeIntervalSince1970:seconds]];
        }
    }
    
    BmsMessageDto *_dto = [[BmsMessageDto alloc] init];
    if (receiverDto.chatId) {
        [_dic setObject:receiverDto.chatId forKey:@"chatId"];
    }
    if ([receiverDto.receiverType isEqualToString:@"class"] || [receiverDto.receiverType isEqualToString:@"custom"]) {
        _dto.userId = userIdStr;                //不确定 后期优化
        _dto.eventid = receiverDto.receiverID;  //不确定 后期优化
        _dto.eventname = receiverDto.receiverName;
        _dto.eventphoto = receiverDto.receiverPhoto;
        
    }else if([receiverDto.receiverType isEqualToString:@"chat"]){
        _dto.userName = receiverDto.receiverName;
        _dto.headurl = receiverDto.receiverPhoto;
        _dto.userId = userIdStr;                //不确定 后期优化
        
    }
    _dto.chatId = receiverDto.chatId;
    
    if ([ToolHelper isBlankString:_dto.chatId]) {
        _dto.chatId = receiverDto.receiverID;
    }
    _dto.reciever = receiverDto.receiverID;
    _dto.type = receiverDto.receiverType;
    _dto.crtime = timer;
    _dto.islocal = @"0";
    richTextView.text = sendStr;
    if ([ToolHelper getCurrentIOSVersion] >= 7.0) {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:kContentFont, NSFontAttributeName,nil];
        CGSize  contentsize =[richTextView.textAnalyzed_txt_replace_emoji boundingRectWithSize:talkingContentSize options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
        _dto.contentsize = NSStringFromCGSize(contentsize);
        
    } else {
        CGSize  contentsize = [richTextView.textAnalyzed_txt_replace_emoji  sizeWithFont:kContentFont constrainedToSize:talkingContentSize lineBreakMode:NSLineBreakByCharWrapping];
        _dto.contentsize = NSStringFromCGSize(contentsize);
    }
    _dto.msgtype = @"txt";
    _dto.content = sendStr;
    _dto.readedflag =[NSNumber numberWithInt:0];
    meesageId = [[NSString alloc] initWithFormat:@"%llu", [ToolHelper getCurrentMilliSecondsTime]];
    localChatId=[[NSString alloc] initWithFormat:@"%@",_dto.chatId];
    _dto.msgId = meesageId;
    _dto.state = @"SENDING";  //正在发送
    
    //   通知信息树是自己发出的消息
    BmsMessageDto *_postDto=[[BmsMessageDto alloc] init];
    [_postDto copy: _dto];
    // if (![receiverDto.receiverType isEqualToString:@"class"]) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTICE_NOTIFICATION object:_postDto];
    //  }
    [_noticeDtoArray addObject:_dto];
    [self tableDataReload];
    if ([_noticeDetialDataArray count] > 2) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:[_noticeDetialDataArray count]-1 inSection:0];
        if (indexpath.row < [tableV numberOfRowsInSection:0]) {
            [tableV scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    inputTextView.text = @"";
    [chatNetworkAgent wordRequestNetworkResponseMethod:_dic];
#endif
}

@end
