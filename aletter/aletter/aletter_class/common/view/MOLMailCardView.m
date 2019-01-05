//
//  MOLMailCardView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailCardView.h"
#import "MOLHead.h"
#import <UIImageView+WebCache.h>

@interface MOLMailCardView ()
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UILabel *tagNameLabel;
@property (nonatomic, weak) UIImageView *bubbleImageView; //meet_card_bubble 评论相关的气泡图标
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *sexImageView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, assign) NSInteger type;
@end

@implementation MOLMailCardView

- (instancetype)initMailCardViewWithType:(NSInteger)type  // 0 有名字性别  1 没有名字性别
{
    self = [super init];
    if (self) {
        self.type = type;
        [self setupMailCardViewUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    }
    return self;
}

- (void)setCardModel:(MOLCardModel *)cardModel
{
    _cardModel = cardModel;
    
    if (cardModel.name.length) {
        self.nameLabel.text = cardModel.name;
    }
    if (cardModel.sex != 0) {
        self.sexImageView.image = cardModel.sex == 1 ? [UIImage imageNamed:@"detail_man"] : [UIImage imageNamed:@"detail_woman"];
    }else{
        self.sexImageView.image = nil;
    }
    if (cardModel.content.length) {
        self.contentLabel.text = cardModel.content;
    }
    if (cardModel.createTime.length) {
        self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:cardModel.createTime];
    }
    
    if (cardModel.channelImageString.length && ([cardModel.channelImageString containsString:@"http"] || [cardModel.channelImageString containsString:@"https"])) {
        [self.backImageView sd_setImageWithURL:[NSURL URLWithString:cardModel.channelImageString] placeholderImage:[UIImage imageNamed:@"home_lock"]];
        self.backImageView.contentMode = UIViewContentModeScaleToFill;
    }else if (cardModel.channelImageString.length){
        self.backImageView.image = [UIImage imageNamed:cardModel.channelImageString];
        self.backImageView.contentMode = UIViewContentModeCenter;
    }else{
        self.backImageView.image = nil;
    }
    
    if (cardModel.channelName.length) {
        self.tagNameLabel.text = cardModel.channelName;
    }else{
        self.tagNameLabel.text = nil;
    }
    
    self.type = cardModel.cardType;
    if (self.type == 2) {
        self.contentLabel.numberOfLines = 0;
    }else{
        self.contentLabel.numberOfLines = 2;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UI
- (void)setupMailCardViewUI
{
    UIImageView *backImageView = [[UIImageView alloc] init];
    _backImageView = backImageView;
    [self addSubview:backImageView];
    
    UILabel *tagNameLabel = [[UILabel alloc] init];
    _tagNameLabel = tagNameLabel;
    tagNameLabel.text = @" ";
    tagNameLabel.textColor = HEX_COLOR(0x3A384D);
    tagNameLabel.font = MOL_MEDIUM_FONT(14);
    tagNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.backImageView addSubview:tagNameLabel];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] init];
    _bubbleImageView = bubbleImageView;
    bubbleImageView.image = [UIImage imageNamed:@"meet_card_bubble"];
    [self addSubview:bubbleImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"加载中...";
    nameLabel.textColor = HEX_COLOR(0xffffff);
    nameLabel.font = MOL_MEDIUM_FONT(14);
    [self addSubview:nameLabel];
    
    UIImageView *sexImageView = [[UIImageView alloc] init];
    _sexImageView = sexImageView;
    sexImageView.image = [UIImage imageNamed:@"detail_man"];
    [self addSubview:sexImageView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.textColor = HEX_COLOR(0xffffff);
    contentLabel.text = @" ";
    contentLabel.font = MOL_LIGHT_FONT(14);
    contentLabel.numberOfLines = 2;
    [self addSubview:contentLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"0000.00.00";
    timeLabel.textColor = HEX_COLOR(0xffffff);
    timeLabel.font = MOL_LIGHT_FONT(12);
    [self addSubview:timeLabel];
}

- (void)calculatorMailCardViewFrame
{
    if (self.type == 1) {
        self.backImageView.hidden = NO;
        self.tagNameLabel.hidden = NO;
        self.contentLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        self.nameLabel.hidden = YES;
        self.bubbleImageView.hidden = YES;
        self.sexImageView.hidden = YES;
        
        self.backImageView.width = 80;
        self.backImageView.height = 103;
        self.backImageView.x = 15;
        self.backImageView.centerY = self.height * 0.5;
        
        self.tagNameLabel.width = self.backImageView.width - 6;
        self.tagNameLabel.height = 20;
        self.tagNameLabel.bottom = self.backImageView.height - 3;
        self.tagNameLabel.x = 3;
        
        [self.contentLabel sizeToFit];
        self.contentLabel.x = self.backImageView.right + 10;
        self.contentLabel.width = self.width - self.contentLabel.x - 20;
        self.contentLabel.y = 24;
        
        [self.timeLabel sizeToFit];
        self.timeLabel.x = self.nameLabel.x;
        self.timeLabel.bottom = self.backImageView.bottom;
        
    }else if (self.type == 2){
        self.backImageView.hidden = YES;
        self.tagNameLabel.hidden = YES;
        self.contentLabel.hidden = NO;
        self.timeLabel.hidden = YES;
        self.nameLabel.hidden = NO;
        self.bubbleImageView.hidden = NO;
        self.sexImageView.hidden = YES;
        
        self.bubbleImageView.width = 14;
        self.bubbleImageView.height = 14;
        self.bubbleImageView.x = 15;
        self.bubbleImageView.y = 20;
        
        [self.nameLabel sizeToFit];
        self.nameLabel.x = 34;
        self.nameLabel.centerY = self.bubbleImageView.centerY;
        
        
        [self.contentLabel sizeToFit];
        self.contentLabel.x = self.nameLabel.x;
        self.contentLabel.width = self.width - self.contentLabel.x - 20;
        self.contentLabel.y = self.nameLabel.bottom + 5;
        
    }else{
        self.backImageView.hidden = NO;
        self.tagNameLabel.hidden = NO;
        self.contentLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        self.nameLabel.hidden = NO;
        self.bubbleImageView.hidden = YES;
        self.sexImageView.hidden = NO;
        
        self.backImageView.width = 80;
        self.backImageView.height = 103;
        self.backImageView.x = 15;
        self.backImageView.centerY = self.height * 0.5;
        
        self.tagNameLabel.width = self.backImageView.width - 6;
        self.tagNameLabel.height = 20;
        self.tagNameLabel.bottom = self.backImageView.height - 3;
        self.tagNameLabel.x = 3;
        
        [self.nameLabel sizeToFit];
        self.nameLabel.x = self.backImageView.right + 10;
        self.nameLabel.y = self.backImageView.y;
        
        self.sexImageView.width = 12;
        self.sexImageView.height = 12;
        self.sexImageView.x = self.nameLabel.right + 5;
        self.sexImageView.centerY = self.nameLabel.centerY;
        
        [self.contentLabel sizeToFit];
        self.contentLabel.x = self.nameLabel.x;
        self.contentLabel.width = self.width - self.contentLabel.x - 20;
        self.contentLabel.y = self.nameLabel.bottom + 11;
        
        [self.timeLabel sizeToFit];
        self.timeLabel.x = self.nameLabel.x;
        self.timeLabel.bottom = self.backImageView.bottom;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMailCardViewFrame];
}
@end
