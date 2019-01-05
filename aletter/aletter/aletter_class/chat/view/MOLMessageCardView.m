//
//  MOLMessageCardView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.

/*
    消息通知中用到的卡片
 */

#import "MOLMessageCardView.h"
#import "MOLHead.h"

typedef NS_ENUM(NSUInteger, MOLMessageCardViewType) {
//    MOLMessageCardViewType_topic,
    MOLMessageCardViewType_other,
    MOLMessageCardViewType_story,
//    MOLMessageCardViewType_chat,
};

@interface MOLMessageCardView ()
@property (nonatomic, assign) MOLMessageCardViewType messageCardViewType;  // 卡片类型

@property (nonatomic, weak) UIImageView *bubbleImageView;  // 气泡
@property (nonatomic, weak) UILabel *titleLabel;  // 话题_频道名字 / 用户昵称
@property (nonatomic, weak) UILabel *subTitleLabel;  // 话题 / 与xxx对话

@property (nonatomic, weak) UIImageView *mailBackImageView;  // 邮票背景图片
@property (nonatomic, weak) UILabel *channelNameLabel;  // 频道名
@property (nonatomic, weak) UILabel *nameLabel;  // 帖主名
@property (nonatomic, weak) UIImageView *sexImageView;  // 帖主性别
@property (nonatomic, weak) UILabel *contentLabel;  // 帖子内容
@property (nonatomic, weak) UILabel *timeLabel;   // 时间label
@end

@implementation MOLMessageCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMessageCardViewUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setMessageCardViewType:(MOLMessageCardViewType)messageCardViewType
{
    _messageCardViewType = messageCardViewType;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setNotiModel:(MOLNotificationModel *)notiModel
{
    _notiModel = notiModel;
    
    if ([notiModel.pushType isEqualToString:@"story"]) {
        self.channelNameLabel.text = notiModel.storyVO.channelVO.channelName;
        self.nameLabel.text = notiModel.storyVO.user.userName;
        self.contentLabel.text = notiModel.storyVO.content;
        self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:notiModel.createTime];
        self.messageCardViewType = MOLMessageCardViewType_story;
    }else{
        if ([notiModel.pushType isEqualToString:@"topic"]) {
            self.titleLabel.text = notiModel.channelVO.channelName;
            self.subTitleLabel.text = notiModel.topicVO.topicName;
        }else if ([notiModel.pushType isEqualToString:@"channel"]){
            self.titleLabel.text = notiModel.channelVO.channelName;
            self.subTitleLabel.text = notiModel.channelVO.dec;
        }else if ([notiModel.pushType isEqualToString:@"comment"]){
            self.titleLabel.text = notiModel.commentVO.commentUserName;
            self.subTitleLabel.text = notiModel.commentVO.content;
        }else if ([notiModel.pushType isEqualToString:@"chat"]){
            self.titleLabel.text = notiModel.chatVO.ownUser.userName;
            self.subTitleLabel.text = [NSString stringWithFormat:@"与%@的对话",notiModel.chatVO.toUser.userName];
        }else{
            self.titleLabel.text = @"有封信";
            self.subTitleLabel.text = @"有封信";
        }
        self.messageCardViewType = MOLMessageCardViewType_other;
    }
    
}

#pragma mark - UI
- (void)setupMessageCardViewUI
{
    // 气泡
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyDetail_replyBubble"]];
    _bubbleImageView = bubbleImageView;
    [self addSubview:bubbleImageView];
    
    // 话题_频道名字 / 用户昵称
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @" ";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_LIGHT_FONT(14);
    [self addSubview:titleLabel];
    
    // 话题 / 与xxx对话
    UILabel *subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel = subTitleLabel;
    subTitleLabel.text = @" ";
    subTitleLabel.textColor = HEX_COLOR(0xffffff);
    subTitleLabel.font = MOL_LIGHT_FONT(14);
    [self addSubview:subTitleLabel];
    
    // 背景邮票
    UIImageView *mailBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_msg_mail"]];
    _mailBackImageView = mailBackImageView;
    [self addSubview:mailBackImageView];
    
    // 频道名
    UILabel *channelNameLabel = [[UILabel alloc] init];
    _channelNameLabel = channelNameLabel;
    channelNameLabel.text = @" ";
    channelNameLabel.textColor = HEX_COLOR(0xffffff);
    channelNameLabel.font = MOL_REGULAR_FONT(12);
    channelNameLabel.numberOfLines = 0;
    channelNameLabel.textAlignment = NSTextAlignmentCenter;
    [mailBackImageView addSubview:channelNameLabel];
    
    // 帖主名
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0xffffff);
    nameLabel.font = MOL_MEDIUM_FONT(14);
    [self addSubview:nameLabel];
    
    // 性别
    UIImageView *sexImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_man"]];
    _sexImageView = sexImageView;
    sexImageView.hidden = YES;
    [self addSubview:sexImageView];
    
    // 帖子内容
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(0xffffff);
    contentLabel.font = MOL_LIGHT_FONT(14);
    [self addSubview:contentLabel];
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR(0xffffff);
    timeLabel.font = MOL_LIGHT_FONT(12);
    [self addSubview:timeLabel];
    
}

- (void)calculatorMessageCardViewFrame
{
    self.bubbleImageView.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? YES : NO;
    self.titleLabel.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? YES : NO;
    self.subTitleLabel.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? YES : NO;
    
    self.mailBackImageView.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? NO : YES;
    self.channelNameLabel.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? NO : YES;
    self.nameLabel.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? NO : YES;
    self.contentLabel.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? NO : YES;
    self.timeLabel.hidden = (self.messageCardViewType == MOLMessageCardViewType_story) ? NO : YES;
    
    self.bubbleImageView.width = 14;
    self.bubbleImageView.height = 14;
    self.bubbleImageView.x = 20;
    self.bubbleImageView.y = 20;
    
    self.titleLabel.x = self.bubbleImageView.right + 10;
    [self.titleLabel sizeToFit];
    if (self.titleLabel.width > self.width - self.titleLabel.x - 10) {
        self.titleLabel.width = self.width - self.titleLabel.x - 10;
    }
    self.titleLabel.height = 20;
    self.titleLabel.centerY = self.bubbleImageView.centerY;
    
    self.subTitleLabel.x = self.titleLabel.x;
    self.subTitleLabel.width = self.width - self.subTitleLabel.x - 10;
    self.subTitleLabel.height = 20;
    self.subTitleLabel.y = self.titleLabel.bottom + 6;
    
    self.mailBackImageView.width = 50;
    self.mailBackImageView.height = 60;
    self.mailBackImageView.centerY = self.height * 0.5;
    self.mailBackImageView.x = 20;
    
    self.channelNameLabel.width = 24;
    [self.channelNameLabel sizeToFit];
    self.channelNameLabel.width = 24;
    self.channelNameLabel.centerX = self.mailBackImageView.width * 0.5;
    self.channelNameLabel.centerY = self.mailBackImageView.height * 0.5;
    
    self.nameLabel.x = self.mailBackImageView.right + 15;
    [self.nameLabel sizeToFit];
    if (self.nameLabel.width > self.width - self.nameLabel.x - 10) {
        self.titleLabel.width = self.width - self.nameLabel.x - 10;
    }
    self.nameLabel.height = 20;
    self.nameLabel.y = self.mailBackImageView.y;
    
    self.contentLabel.x = self.nameLabel.x;
    self.contentLabel.width = self.width - self.contentLabel.x - 10;
    self.contentLabel.height = 20;
    self.contentLabel.centerY = self.mailBackImageView.centerY;
    
    self.timeLabel.x = self.contentLabel.x;
    self.timeLabel.width = self.contentLabel.width;
    self.timeLabel.height = 17;
    self.timeLabel.bottom = self.mailBackImageView.bottom;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMessageCardViewFrame];
}
@end
