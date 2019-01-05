//
//  MOLMailDetailVoiceCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailDetailVoiceCell.h"
#import "MOLHead.h"
#import "MOLAnimateVoiceView.h"
#import "MOLActionViewModel.h"
#import "MOLStatisticsRequest.h"

@interface MOLMailDetailVoiceCell ()
@property (nonatomic, weak) UIView *backContentView;  // 内容view
@property (nonatomic, weak) UILabel *nameLabel;        // 姓名
@property (nonatomic, weak) UIImageView *sexImageView; // 性别
@property (nonatomic, weak) UILabel *schoolLabel; // 学校
@property (nonatomic, weak) UIImageView *envelopeImageView;  // 信封
@property (nonatomic, weak) MOLAnimateVoiceView *voiceView;  // 声音的view
@property (nonatomic, weak) YYLabel *contentLabel;   // 正文
@property (nonatomic, weak) UIButton *allTextButton; // 查看全文
@property (nonatomic, weak) UILabel *actionLabel;   // 3分钟前 · 2 同感 · 4评论
@property (nonatomic, weak) UIButton *likeButton;  // 喜欢

@property (nonatomic, strong) MOLActionViewModel *actionViewModel;
@end

@implementation MOLMailDetailVoiceCell
- (void)dealloc
{
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.actionViewModel = [[MOLActionViewModel alloc] init];
        [self stupMailDetailVoiceCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self bindingViewModel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatus_changeStatus:) name:@"MOL_LIKE_STATUS" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    return self;
}

#pragma mark -  NSNotificationCenter
- (void)playStatusChange_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.storyModel.storyId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.storyModel.audioUrl]) {
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
        self.voiceView.showTime = self.storyModel.time;
    }
}

- (void)playProcess_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.storyModel.storyId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.storyModel.audioUrl]) {
        [self.voiceView animateVoiceView_start];
        NSInteger time = (NSInteger)[MOLPlayVoiceManager sharePlayVoiceManager].totalDuration - [MOLPlayVoiceManager sharePlayVoiceManager].currentDuration;
        self.voiceView.showTime = [NSString stringWithFormat:@"%ld",time];
    }else{
        [self.voiceView animateVoiceView_stop];
        self.voiceView.showTime = self.storyModel.time;
    }
}

- (void)playFinish_refreshUI
{
    [self.voiceView animateVoiceView_stop];
    self.voiceView.showTime = self.storyModel.time;
}

- (void)likeStatus_changeStatus:(NSNotification*)note
{
    MOLStoryModel *model = [note object];
    if ([model.storyId isEqualToString:self.storyModel.storyId]) {
        self.storyModel.isAgree = model.isAgree;
        self.likeButton.selected = self.storyModel.isAgree;
        
        if (self.likeButton.selected) {
            self.storyModel.likeCount = [NSString stringWithFormat:@"%ld",self.storyModel.likeCount.integerValue + 1];
        }else{
            NSInteger count = self.storyModel.likeCount.integerValue - 1 > 0 ? self.storyModel.likeCount.integerValue - 1 : 0;
            self.storyModel.likeCount = [NSString stringWithFormat:@"%ld",count];
        }
        
        [self setActionLabelWithModel:self.storyModel];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)setActionLabelWithModel:(MOLStoryModel *)model
{
    NSString *bottomSting = nil;
    NSString *showTime = [NSString moli_timeGetMessageTimeWithTimestamp:model.createTime];
    if ([MOLSwitchManager shareSwitchManager].normalStatus) {
        if (model.likeCount.integerValue == 0 && model.commentCount.integerValue == 0) {
            bottomSting = showTime;
        }else if (model.likeCount.integerValue == 0){
            bottomSting = [NSString stringWithFormat:@"%@ · %@评论",showTime,model.commentCount];
        }else if (model.commentCount.integerValue == 0){
            bottomSting = [NSString stringWithFormat:@"%@ · %@%@",showTime,model.likeCount,(model.channelVO.agreeContent.length ? model.channelVO.agreeContent:@"喜欢")];
        }else{
            bottomSting = [NSString stringWithFormat:@"%@ · %@%@ · %@评论",showTime,model.likeCount,(model.channelVO.agreeContent.length ? model.channelVO.agreeContent:@"喜欢"),model.commentCount];
        }
    }else{
        bottomSting = showTime;
    }
    
    self.actionLabel.text = bottomSting;
}
#pragma mark - viewModel
- (void)bindingViewModel
{
    // 点赞
    @weakify(self);
    [self.actionViewModel.likeStoryCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        self.likeButton.userInteractionEnabled = YES;
        NSInteger code = [x integerValue];
        if (code == MOL_SUCCESS_REQUEST) {
            
            self.likeButton.selected = self.storyModel.isAgree;
        }
    }];
}

#pragma mark - 按钮点击
- (void)button_clickLikeButton:(UIButton *)button
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        // 跳出性别选择
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    
    button.userInteractionEnabled = NO;
    [self.actionViewModel.likeStoryCommand execute:self.storyModel];
}

- (void)button_clickVoiceView
{
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_playVoiceWithFileUrlString:self.storyModel.audioUrl modelId:self.storyModel.storyId playType:MOLPlayVoiceManagerType_stream];
    if (self.storyModel.privateSign == 2) {
        MOLStatisticsRequest *r = [[MOLStatisticsRequest alloc] initRequest_statisticsPlayStoryWithParameter:nil parameterId:self.storyModel.storyId];
        [r baseNetwork_startRequestWithcompletion:nil failure:nil];
    }
}

#pragma mark - 赋值
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    self.nameLabel.text = storyModel.user.userName;
    self.schoolLabel.text = storyModel.user.school;
    self.sexImageView.image = storyModel.user.sex == 1 ? [UIImage imageNamed:@"detail_man"] : [UIImage imageNamed:@"detail_woman"];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:storyModel.content];
    text.yy_color = HEX_COLOR(0x074D81);
    text.yy_font = MOL_LIGHT_FONT(14);
    if (storyModel.topicVO.topicName.length) {
        NSRange range = [storyModel.content rangeOfString:storyModel.topicVO.topicName];
        [text yy_setColor:HEX_COLOR(0x4A90E2) range:range];
        [text yy_setFont:MOL_MEDIUM_FONT(14) range:range];
        @weakify(self);
        [text yy_setTextHighlightRange:range color:HEX_COLOR(0x4A90E2) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            @strongify(self);
            if (self.clickHighText) {
                self.clickHighText(storyModel);
            }
        }];
    }
    if (storyModel.sort > 0) {
        self.envelopeImageView.image = [UIImage imageNamed:@"detail_hot"];
    }else{
        self.envelopeImageView.image = [UIImage imageNamed:@"detail_envelope"];
    }
    self.voiceView.showTime = storyModel.time;
    self.contentLabel.attributedText = text;
    
    self.allTextButton.hidden = !storyModel.showAllButton;
    
    [self setActionLabelWithModel:storyModel];
    
    self.likeButton.selected = storyModel.isAgree;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UI
- (void)stupMailDetailVoiceCellUI
{
    UIView *backContentView = [[UIView alloc] init];
    _backContentView = backContentView;
    backContentView.backgroundColor = HEX_COLOR(0xffffff);
    [self.contentView addSubview:backContentView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"加载中...";
    nameLabel.textColor = HEX_COLOR(0x004476);
    nameLabel.font = MOL_MEDIUM_FONT(14);
    [backContentView addSubview:nameLabel];
    
    UIImageView *sexImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_man"]];
    _sexImageView = sexImageView;
    [backContentView addSubview:sexImageView];
    
    UILabel *schoolLabel = [[UILabel alloc] init];
    _schoolLabel = schoolLabel;
    schoolLabel.text = @" ";
    schoolLabel.textColor = HEX_COLOR(0x809FC2);
    schoolLabel.font = MOL_MEDIUM_FONT(11);
//    schoolLabel.backgroundColor = HEX_COLOR_ALPHA(0xF4F4F4, 1);
    schoolLabel.textAlignment = NSTextAlignmentCenter;
    [backContentView addSubview:schoolLabel];
    
    UIImageView *envelopeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_envelope"]];
    _envelopeImageView = envelopeImageView;
    [backContentView addSubview:envelopeImageView];
    
    MOLAnimateVoiceView *voiceView = [[MOLAnimateVoiceView alloc] init];
    _voiceView = voiceView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickVoiceView)];
    [voiceView.backViewButton addGestureRecognizer:tap];
    [backContentView addSubview:voiceView];
    
    YYLabel *contentLabel = [[YYLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    [backContentView addSubview:contentLabel];
    
    UIButton *allTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allTextButton = allTextButton;
    [allTextButton setTitle:@"查看全文" forState:UIControlStateNormal];
    [allTextButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateNormal];
    [allTextButton setImage:[UIImage imageNamed:@"detail_allText"] forState:UIControlStateNormal];
    allTextButton.titleLabel.font = MOL_MEDIUM_FONT(14);
    [backContentView addSubview:allTextButton];
    
    UILabel *actionLabel = [[UILabel alloc] init];
    _actionLabel = actionLabel;
    actionLabel.text = @"刚刚 · 0 同感 · 0评论";
    actionLabel.textColor = HEX_COLOR(0x074D81);
    actionLabel.font = MOL_LIGHT_FONT(12);
    [backContentView addSubview:actionLabel];
    
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    [likeButton setImage:[UIImage imageNamed:@"detail_agree"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"detail_agreed"] forState:UIControlStateSelected];
    [likeButton addTarget:self action:@selector(button_clickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    [backContentView addSubview:likeButton];
}

- (void)calculatorMailDetailVoiceCellFrame
{
    self.backContentView.width = self.contentView.width - 40;
    self.backContentView.height = self.contentView.height - 5;
    self.backContentView.x = 20;
    self.backContentView.layer.cornerRadius = 12;
    self.backContentView.layer.masksToBounds = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 20;
    if (self.nameLabel.width > self.backContentView.width * 0.5) {
        self.nameLabel.width = self.backContentView.width * 0.5;
    }
    self.nameLabel.x = 15;
    self.nameLabel.y = 20;
    
    self.sexImageView.width = 12;
    self.sexImageView.height = self.sexImageView.width;
    self.sexImageView.x = self.nameLabel.right + 5;
    self.sexImageView.centerY = self.nameLabel.centerY;
    
    [self.schoolLabel sizeToFit];
    self.schoolLabel.width += 14;
    if (self.schoolLabel.width > (self.backContentView.width - 17) - (self.sexImageView.right + 10)) {
        self.schoolLabel.width = (self.backContentView.width - 17) - (self.sexImageView.right + 10);
    }
    self.schoolLabel.height = 16;
    self.schoolLabel.centerY = self.nameLabel.centerY;
    self.schoolLabel.right = self.backContentView.width - 17;
    self.schoolLabel.layer.cornerRadius = self.schoolLabel.height * 0.5;
    self.schoolLabel.clipsToBounds = YES;
    
    self.envelopeImageView.width = 50;
    self.envelopeImageView.height = 30;
    self.envelopeImageView.right = self.backContentView.width;
    
    self.voiceView.width = self.backContentView.width;
    self.voiceView.height = 40;
    self.voiceView.y = self.nameLabel.bottom + 10;
    
    self.contentLabel.width = self.backContentView.width - 30;
    self.contentLabel.height = [self getMessageHeight];
    self.contentLabel.x = 15;
    self.contentLabel.y = self.voiceView.bottom + 10;
    
    [self.allTextButton sizeToFit];
    self.allTextButton.x = self.contentLabel.x;
    self.allTextButton.y = self.contentLabel.bottom + 5;
    [self.allTextButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
    
    [self.actionLabel sizeToFit];
    self.actionLabel.x = self.contentLabel.x;
   
    if (self.allTextButton.hidden == NO){
        self.actionLabel.y = self.allTextButton.bottom + 15;
    }else{
        self.actionLabel.y = self.contentLabel.bottom + 10;
    }
    
    self.likeButton.width = 24;
    self.likeButton.height = 24;
    self.likeButton.right = self.backContentView.width - 20;
    self.likeButton.centerY = self.actionLabel.centerY;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMailDetailVoiceCellFrame];
}

// 获取文本高度
-(CGFloat)getMessageHeight
{
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:self.storyModel.content];
    introText.yy_font = MOL_LIGHT_FONT(14);
    CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-40-30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    CGFloat introHeight = layout.textBoundingSize.height;
    if (introHeight > MOL_TextMaxHeight) {
        introHeight = MOL_TextMaxHeight;
    }
    return introHeight;
}
@end
