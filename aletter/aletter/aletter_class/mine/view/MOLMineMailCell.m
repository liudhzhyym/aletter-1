//
//  MOLMineMailCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailCell.h"
#import "MOLHead.h"

@interface MOLMineMailCell ()

@property (nonatomic, weak) UIImageView *mailImageView;
@property (nonatomic, weak) UILabel *mailNameLabel;
@property (nonatomic, weak) UIImageView *lockImageView;
@property (nonatomic, weak) UIButton *likeButton;
@property (nonatomic, weak) UILabel *dateLabel;
@end

@implementation MOLMineMailCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMineMailCellUI];
    }
    return self;
}

#pragma mark - 赋值
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    self.mailNameLabel.text = storyModel.channelVO.channelName;
    self.dateLabel.text = [NSString stringWithFormat:@"%@日,%@",storyModel.weatherInfo.day,storyModel.weatherInfo.week];
    if (storyModel.privateSign == 2) {
        self.lockImageView.hidden = YES;
    }else{
        self.lockImageView.hidden = NO;
    }
    
    if (storyModel.likeCount.integerValue > 0 && storyModel.privateSign == 2) {
        self.likeButton.hidden = NO;
        [self.likeButton setTitle:[NSString stringWithFormat:@"%@",storyModel.likeCount] forState:UIControlStateNormal];
    }else{
        self.likeButton.hidden = YES;
    }
}

#pragma mark - UI
- (void)setupMineMailCellUI
{
    UIImageView *mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_mail"]];
    _mailImageView = mailImageView;
    [self.contentView addSubview:mailImageView];
    
    UILabel *mailNameLabel = [[UILabel alloc] init];
    _mailNameLabel = mailNameLabel;
    mailNameLabel.text = @"恋爱";
    mailNameLabel.textColor = HEX_COLOR(0x074D81);
    mailNameLabel.font = MOL_MEDIUM_FONT(14);
    mailNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:mailNameLabel];
    
    UIImageView *lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_lock"]];
    _lockImageView = lockImageView;
    [self.contentView addSubview:lockImageView];
    
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    [likeButton setImage:[UIImage imageNamed:@"mine_mail_like"] forState:UIControlStateNormal];
    [likeButton setTitle:@"0" forState:UIControlStateNormal];
    [likeButton setTitleColor:HEX_COLOR_ALPHA(0x537A99,0.3) forState:UIControlStateNormal];
    likeButton.titleLabel.font = MOL_MEDIUM_FONT(10);
    [self.contentView addSubview:likeButton];
    
    UILabel *dateLabel = [[UILabel alloc] init];
    _dateLabel = dateLabel;
    dateLabel.text = @"1日，星期三";
    dateLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.3);
    dateLabel.font = MOL_MEDIUM_FONT(12);
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:dateLabel];
}

- (void)calculatorMineMailCellFrame
{
    self.mailImageView.width = self.contentView.width;
    self.mailImageView.height = self.contentView.height - 30;
    
    self.mailNameLabel.width = self.contentView.width;
    self.mailNameLabel.height = 20;
    self.mailNameLabel.centerY = self.mailImageView.centerY;
    
    [self.likeButton sizeToFit];
    self.likeButton.centerX = self.contentView.width * 0.5;
    self.likeButton.y = self.mailNameLabel.bottom + MOL_SCREEN_ADAPTER(3);
    
    self.lockImageView.width = MOL_SCREEN_ADAPTER(11);
    self.lockImageView.height = MOL_SCREEN_ADAPTER(16);
    self.lockImageView.centerX = self.contentView.width * 0.5;
    self.lockImageView.y = self.mailNameLabel.bottom + MOL_SCREEN_ADAPTER(3);
    
    self.dateLabel.width = self.contentView.width;
    self.dateLabel.height = 20;
    self.dateLabel.y = self.mailImageView.bottom + 10;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMineMailCellFrame];
}
@end
