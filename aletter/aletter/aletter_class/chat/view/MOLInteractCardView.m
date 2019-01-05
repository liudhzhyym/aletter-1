//
//  MOLInteractCardView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInteractCardView.h"
#import "MOLHead.h"

@interface MOLInteractCardView ()
@property (nonatomic, weak) UIImageView *mailBackImageView;  // 邮票背景图片
@property (nonatomic, weak) UILabel *channelNameLabel;  // 频道名
@property (nonatomic, weak) UILabel *contentLabel;  // 帖子内容
@property (nonatomic, weak) UILabel *introduceLabel;   // 评论/喜欢label
@end

@implementation MOLInteractCardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInteractCardViewUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setNotiModel:(MOLNotificationModel *)notiModel
{
    _notiModel = notiModel;
    
    self.channelNameLabel.text = notiModel.storyVO.channelVO.channelName;
    self.contentLabel.text = notiModel.storyVO.content;
    self.introduceLabel.text = [NSString stringWithFormat:@"%@%@丨%@评论",notiModel.storyVO.likeCount,(notiModel.storyVO.channelVO.agreeContent.length ? notiModel.storyVO.channelVO.agreeContent:@"喜欢"),notiModel.storyVO.commentCount];
}

#pragma mark - UI
- (void)setupInteractCardViewUI
{
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
    
    // 帖子内容
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(0xffffff);
    contentLabel.font = MOL_LIGHT_FONT(14);
    contentLabel.numberOfLines = 2;
    [self addSubview:contentLabel];
    
    // 时间
    UILabel *introduceLabel = [[UILabel alloc] init];
    _introduceLabel = introduceLabel;
    introduceLabel.text = @" ";
    introduceLabel.textColor = HEX_COLOR(0xffffff);
    introduceLabel.font = MOL_LIGHT_FONT(12);
    [self addSubview:introduceLabel];
    
}

- (void)calculatorInteractCardViewFrame
{
    self.mailBackImageView.width = 50;
    self.mailBackImageView.height = 60;
    self.mailBackImageView.centerY = self.height * 0.5;
    self.mailBackImageView.x = 20;
    
    self.channelNameLabel.width = 24;
    [self.channelNameLabel sizeToFit];
    self.channelNameLabel.width = 24;
    self.channelNameLabel.centerX = self.mailBackImageView.width * 0.5;
    self.channelNameLabel.centerY = self.mailBackImageView.height * 0.5;
    
    self.contentLabel.x = self.mailBackImageView.right + 15;
    self.contentLabel.width = self.width - self.contentLabel.x - 10;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.width - self.contentLabel.x - 10;
    self.contentLabel.y = self.mailBackImageView.y;
    
    self.introduceLabel.x = self.contentLabel.x;
    self.introduceLabel.width = self.contentLabel.width;
    self.introduceLabel.height = 17;
    self.introduceLabel.bottom = self.mailBackImageView.bottom;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorInteractCardViewFrame];
}
@end
