//
//  MOLChatHeadView.m
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChatHeadView.h"
#import "MOLHead.h"
#import "EDBaseMessageModel.h"
#import <UIImageView+WebCache.h>

@interface MOLChatHeadView ()
@property (nonatomic, weak) UILabel *chatTimeLabel;
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIView *backView;        // 卡片背景
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *channelImageView; // 频道图片
@property (nonatomic, weak) UILabel *channelNameLabel;   // 频道名
@property (nonatomic, weak) YYLabel *contentLabel;      // 内容
@property (nonatomic, weak) UILabel *timeLabel;         // 时间

@property (nonatomic, weak) UILabel *deleteLabel;   // 信件删除label
@property (nonatomic, strong)EDBaseMessageModel *msgDto;

@end

@implementation MOLChatHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChatHeadViewUI];
    }
    return self;
}

- (void)setModel:(EDBaseMessageModel *)model
{
    _model = model;
    self.msgDto =_model;
    if (model.storyVO) {
        self.contentView.hidden = NO;
        self.deleteLabel.hidden = YES;
        if (model.createTime.length) {
            self.chatTimeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:model.createTime];
        }else{
            self.chatTimeLabel.text = @"刚刚";
        }
        
        [self.channelImageView sd_setImageWithURL:[NSURL URLWithString:model.storyVO.channelVO.image]];
        self.channelNameLabel.text = model.storyVO.channelVO.channelName;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.storyVO.content];
        text.yy_color = HEX_COLOR(0xffffff);
        text.yy_font = MOL_LIGHT_FONT(14);
        if (model.storyVO.topicVO.topicName.length) {
            NSRange range = [model.storyVO.content rangeOfString:model.storyVO.topicVO.topicName];
            [text yy_setColor:HEX_COLOR(0x4A90E2) range:range];
            [text yy_setFont:MOL_MEDIUM_FONT(14) range:range];
        }
        self.contentLabel.attributedText = text;
        
        self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:model.storyVO.createTime];
        [self.timeLabel sizeToFit];
    }else{
        self.contentView.hidden = YES;
        self.deleteLabel.hidden = NO;
    }
    
    
}

#pragma mark - UI
- (void)setupChatHeadViewUI
{
    
    UILabel *chatTimeLabel = [[UILabel alloc] init];
    _chatTimeLabel = chatTimeLabel;
    chatTimeLabel.text = @" ";
    chatTimeLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.7);
    chatTimeLabel.font = MOL_LIGHT_FONT(12);
    chatTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:chatTimeLabel];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_leftBubble_high"]];
    _iconImageView = iconImageView;
    [self addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"从这封信开启一段对话";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_LIGHT_FONT(14);
    [self addSubview:titleLabel];
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.layer.cornerRadius = 12;
    backView.clipsToBounds = YES;
    backView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    [self addSubview:backView];
    
    UILabel *deleteLabel = [[UILabel alloc] init];
    _deleteLabel = deleteLabel;
    deleteLabel.text = @"该信件已删除";
    deleteLabel.textColor = HEX_COLOR(0xffffff);
    deleteLabel.font = MOL_MEDIUM_FONT(24);
    deleteLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:deleteLabel];
    
    UIView *contentView = [[UIView alloc] init];
    _contentView = contentView;
    contentView.layer.cornerRadius = 12;
    contentView.clipsToBounds = YES;
    contentView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    [_contentView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mOLChatHeadViewTap:)];
    [contentView addGestureRecognizer:tap];
    [backView addSubview:contentView];
    
    
    
    UIImageView *channelImageView = [[UIImageView alloc] init];
    _channelImageView = channelImageView;
    [contentView addSubview:channelImageView];
    
    UILabel *channelNameLabel = [[UILabel alloc] init];
    _channelNameLabel = channelNameLabel;
    channelNameLabel.textColor = HEX_COLOR(0x3A384D);
    channelNameLabel.text = @" ";
    channelNameLabel.font = MOL_MEDIUM_FONT(14);
    channelNameLabel.textAlignment = NSTextAlignmentCenter;
    [channelImageView addSubview:channelNameLabel];
    
    YYLabel *contentLabel = [[YYLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.numberOfLines = 2;
    [contentView addSubview:contentLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR(0xffffff);
    timeLabel.font = MOL_LIGHT_FONT(12);
    [contentView addSubview:timeLabel];
}

- (void)calculatorChatHeadViewFrame
{
    self.chatTimeLabel.width = self.width;
    self.chatTimeLabel.height = 17;
    self.chatTimeLabel.y = 8;
    
    self.iconImageView.width = 14;
    self.iconImageView.height = 14;
    self.iconImageView.x = 20;
    self.iconImageView.y = self.chatTimeLabel.bottom + 13;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.height = 20;
    self.titleLabel.x = self.iconImageView.right + 5;
    self.titleLabel.centerY = self.iconImageView.centerY;
    
    self.backView.width = self.width - 40;
    self.backView.height = 120;
    self.backView.x = 20;
    self.backView.y = self.titleLabel.bottom + 20;
    
    self.deleteLabel.frame = self.backView.bounds;
    self.contentView.frame = self.backView.bounds;
    
    self.channelImageView.width = 80;
    self.channelImageView.height = 103;
    self.channelImageView.x = 15;
    self.channelImageView.centerY = self.contentView.height * 0.5;
    
    self.channelNameLabel.width = self.channelImageView.width;
    self.channelNameLabel.height = 20;
    self.channelNameLabel.bottom = self.channelImageView.height - 3;
    
    self.contentLabel.x = self.channelImageView.right + 10;
    self.contentLabel.y = 24;
    self.contentLabel.width = self.contentView.width - self.contentLabel.x - 10;
    self.contentLabel.height = [self getMessageHeight];
    
    [self.timeLabel sizeToFit];
    self.timeLabel.x = self.contentLabel.x;
    self.timeLabel.bottom = self.contentView.height - 24;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorChatHeadViewFrame];
}

// 获取文本高度
-(CGFloat)getMessageHeight
{
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:self.model.storyVO.content?self.model.storyVO.content:@""];
    introText.yy_font = MOL_LIGHT_FONT(14);
    CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-115-40, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    CGFloat introHeight = layout.textBoundingSize.height;
    if (introHeight > 40) {
        introHeight = 40;
    }
    return introHeight;
}

- (void)mOLChatHeadViewTap:(UITapGestureRecognizer *)tap{
    if (self.msgDto.storyVO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MOLChatHeadViewTap" object:self.msgDto];
    }
}
@end
