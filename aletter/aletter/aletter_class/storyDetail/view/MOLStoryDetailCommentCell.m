//
//  MOLStoryDetailCommentCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailCommentCell.h"
#import "MOLHead.h"
#import "MOLAnimateVoiceView.h"

@interface MOLStoryDetailCommentCell ()
@property (nonatomic, weak) UIImageView *talkImageView; // 对话图标
@property (nonatomic, weak) YYLabel *nameLabel;  // 名字 或者 xxx 回复 xxx
@property (nonatomic, weak) MOLAnimateVoiceView *voiceView;  // 语音
@property (nonatomic, weak) YYLabel *contentLabel; // 正文
@property (nonatomic, weak) UILabel *timeLabel; // 时间
@property (nonatomic, weak) UIButton *replyButton;  // 回复
@property (nonatomic, weak) UIButton *msgButton;  // 私聊

@end

@implementation MOLStoryDetailCommentCell

- (void)dealloc
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.commentModel.commentId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.commentModel.audioUrl]) {
        [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupStoryDetailCommentCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatusChange_refreshUI) name:@"STKAudioPlayerSingle_statusChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayerSingle_process" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayerSingle_finish" object:nil];
    }
    return self;
}

#pragma mark -  NSNotificationCenter
- (void)playStatusChange_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.commentModel.commentId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.commentModel.audioUrl]) {
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
        self.voiceView.showTime = self.commentModel.time;
    }
}

- (void)playProcess_refreshUI
{
    if ([[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicId isEqualToString:self.commentModel.commentId] &&
        [[MOLPlayVoiceManager sharePlayVoiceManager].currentMusicPath isEqualToString:self.commentModel.audioUrl]) {
        [self.voiceView animateVoiceView_start];
        NSInteger time = (NSInteger)[MOLPlayVoiceManager sharePlayVoiceManager].totalDuration - [MOLPlayVoiceManager sharePlayVoiceManager].currentDuration;
        self.voiceView.showTime = [NSString stringWithFormat:@"%ld",time];
    }else{
        [self.voiceView animateVoiceView_stop];
        self.voiceView.showTime = self.commentModel.time;
    }
}

- (void)playFinish_refreshUI
{
    [self.voiceView animateVoiceView_stop];
    self.voiceView.showTime = self.commentModel.time;
}

#pragma mark - 按钮的点击
- (void)button_clickVoiceView
{
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_playVoiceWithFileUrlString:self.commentModel.audioUrl modelId:self.commentModel.commentId playType:MOLPlayVoiceManagerType_stream];
}

#pragma mark - 赋值
- (void)setCommentModel:(MOLCommentModel *)commentModel
{
    _commentModel = commentModel;
    
    if (commentModel.audioUrl.length) {
        self.voiceView.hidden = NO;
    }else{
        self.voiceView.hidden = YES;
    }
    
    if (commentModel.commentUserSex == 1) {
        self.talkImageView.image = [UIImage imageNamed:@"storyDetail_manBubble"];
    }else{
        self.talkImageView.image = [UIImage imageNamed:@"storyDetail_womanBubble"];
    }
    
    NSString *name = commentModel.commentUserName;
    NSString *beName = commentModel.beCommentUserName;
    
    if ([self.storyUserId isEqualToString:commentModel.commentUserId]) {
        name = @"楼主";
    }else{
        name = commentModel.commentUserName;
    }
    
    if ([self.storyUserId isEqualToString:commentModel.beCommentUserId]) {
        beName = @"楼主";
    }else{
        beName = commentModel.beCommentUserName;
    }
    
    if (beName.length) {
        name = [NSString stringWithFormat:@"%@ 回复 %@",name,beName];
    }
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:name];
    text.yy_color = HEX_COLOR(0x074D81);
    text.yy_font = MOL_MEDIUM_FONT(14);
//    NSRange range = [name rangeOfString:commentModel.commentUserName];
//    [text yy_setTextHighlightRange:range color:HEX_COLOR(0x074D81) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
//        NSLog(@"点击了：%@",text.string);
//
//    }];
    self.nameLabel.attributedText = text;
    [self.nameLabel sizeToFit];
    
    // 正文
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc] initWithString:commentModel.content];
    contentText.yy_color = HEX_COLOR(0x074D81);
    contentText.yy_font = MOL_LIGHT_FONT(14);
    self.contentLabel.attributedText = contentText;
    
    if (commentModel.commentUserSchool.length) {
        
        NSString *school = commentModel.commentUserSchool;
        NSInteger count = 9;
        if (iPhone6Plus) {
            count = 13;
        }else if (iPhone6){
            count = 9;
        }else{
            count = 5;
        }
        if (school.length >= count) {
            school = [school substringToIndex:count-1];
            school = [NSString stringWithFormat:@"%@...",school];
        }
        
         NSString *time = [NSString moli_timeGetMessageTimeWithTimestamp:commentModel.createTime];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ · %@",school,time];
    }else{
        self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:commentModel.createTime];
    }
    
    
    self.voiceView.showTime = commentModel.time;
    
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if ([commentModel.commentUserId isEqualToString:user.userId]) {
        self.msgButton.hidden = YES;
    }else{
        self.msgButton.hidden = NO;

    }
}

#pragma mark - UI
- (void)setupStoryDetailCommentCellUI
{
    // 对话图标
    UIImageView *talkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyDetail_replyBubble"]];
    _talkImageView = talkImageView;
    [self.contentView addSubview:talkImageView];
    
    // xxx 回复 xxx 或者 名字
    YYLabel *nameLabel = [[YYLabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.userInteractionEnabled = YES;
    [self.contentView addSubview:nameLabel];
    
    
    // 语音
    MOLAnimateVoiceView *voiceView = [[MOLAnimateVoiceView alloc] init];
    _voiceView = voiceView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickVoiceView)];
    [voiceView.backViewButton addGestureRecognizer:tap];
    [self.contentView addSubview:voiceView];
    
    // 正文
    YYLabel *contentLabel = [[YYLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    [self.contentView addSubview:contentLabel];
    
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"刚刚";
    timeLabel.textColor = HEX_COLOR(0x074D81);
    timeLabel.font = MOL_LIGHT_FONT(13);
    [self.contentView addSubview:timeLabel];
    
    // 回复按钮
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _replyButton = replyButton;
    [replyButton setTitle:@"回复" forState:UIControlStateNormal];
    [replyButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateNormal];
    replyButton.titleLabel.font = MOL_REGULAR_FONT(13);
    replyButton.userInteractionEnabled = NO;
    [self.contentView addSubview:replyButton];
    
    // 私聊按钮
    UIButton *msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _msgButton = msgButton;
    [msgButton setTitle:@"私聊" forState:UIControlStateNormal];
    [msgButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateNormal];
    msgButton.titleLabel.font = MOL_REGULAR_FONT(13);
    @weakify(self);
    [[msgButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.clickMsgButtonBlock) {
            self.clickMsgButtonBlock();
        }
    }];
    [self.contentView addSubview:msgButton];
}

- (void)calculatorStoryDetailCommentCellFrame
{
    self.talkImageView.width = 14;
    self.talkImageView.height = self.talkImageView.width;
    self.talkImageView.x = 15;
    self.talkImageView.y = 15;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.width = self.contentView.width - 50;
    self.nameLabel.x = self.talkImageView.right + 5;
    self.nameLabel.centerY = self.talkImageView.centerY;
    
    self.voiceView.x = 15;
    self.voiceView.width = self.contentView.width - self.voiceView.x;
    self.voiceView.height = 40;
    self.voiceView.y = self.nameLabel.bottom + 10;
    
    self.contentLabel.x = self.nameLabel.x;
    self.contentLabel.y = self.voiceView.hidden ? self.nameLabel.bottom + 10 : self.voiceView.bottom + 10;
    self.contentLabel.width = self.contentView.width - self.contentLabel.x - 35;
    self.contentLabel.height = [self getMessageHeight];
    
    [self.timeLabel sizeToFit];
    self.timeLabel.x = self.nameLabel.x;
    self.timeLabel.y = self.contentLabel.bottom + 12;
    
    [self.replyButton sizeToFit];
    self.replyButton.centerY = self.timeLabel.centerY;
    self.replyButton.x = self.timeLabel.right + 20;
    
    [self.msgButton sizeToFit];
    self.msgButton.centerY = self.timeLabel.centerY;
    self.msgButton.x = self.replyButton.right + 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailCommentCellFrame];
}

// 获取文本高度
-(CGFloat)getMessageHeight
{
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:self.commentModel.content];
    introText.yy_font = MOL_LIGHT_FONT(14);
    CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-40-34-35, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    CGFloat introHeight = layout.textBoundingSize.height;
    return introHeight;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.layer.transform = CATransform3DMakeScale(1, 1, 1);
    [UIView animateWithDuration:0.3 animations:^{
        // 按照比例scalex=0.001,y=0.001进行缩小
        self.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1);
    } completion:^(BOOL finished) {
        // 0.5秒后将视图移除从父上视图
        [UIView animateWithDuration:0.2 delay:0.7 options:0 animations:^{
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:^(BOOL finished) {
            self.layer.transform = CATransform3DIdentity;
        }];
    }];
    [super touchesBegan:touches withEvent:event];
}
@end
