//
//  MOLSystemNotiCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
/*
    系统通知cell
 */

#import "MOLSystemNotiCell.h"
#import "MOLMessageCardView.h"
#import "MOLHead.h"

@interface MOLSystemNotiCell ()
@property (nonatomic, weak) UILabel *timeLabel;   // 时间label
@property (nonatomic, weak) UIImageView *bubbleImageView;  // 气泡
@property (nonatomic, weak) UILabel *contentLabel;  // 内容
@property (nonatomic, weak) UIButton *communityButton;  // 社区礼仪button
@property (nonatomic, weak) MOLMessageCardView *cardView; // 卡片

@end

@implementation MOLSystemNotiCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSystemNotiCellUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - 赋值
- (void)setNotiModel:(MOLNotificationModel *)notiModel
{
    _notiModel = notiModel;
    // 时间
    self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:notiModel.createTime];
    // 正文
    self.contentLabel.text = notiModel.content;
    
    // 社区礼仪按钮
    if (notiModel.systemType.integerValue == 1) {
        self.communityButton.hidden = NO;
        [self.communityButton setTitle:@"查看社区礼仪" forState:UIControlStateNormal];
        [self.communityButton sizeToFit];
    }else if (notiModel.systemType.integerValue == 2){
        self.communityButton.hidden = NO;
        [self.communityButton setTitle:@"查看写信规范" forState:UIControlStateNormal];
        [self.communityButton sizeToFit];
    }else{
        self.communityButton.hidden = YES;
    }
    
    if ([notiModel.pushType isEqualToString:@"h5"] || [notiModel.pushType isEqualToString:@"txt"]) {
        self.cardView.hidden = YES;
    }else{
        self.cardView.hidden = NO;
    }
    
    // 卡片
    self.cardView.notiModel = notiModel;
}

#pragma mark - UI
- (void)setupSystemNotiCellUI
{
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.7);
    timeLabel.font = MOL_LIGHT_FONT(12);
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:timeLabel];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:INTITLE_LEFT_Highlight]];
    _bubbleImageView = bubbleImageView;
    [self.contentView addSubview:bubbleImageView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(0xffffff);
    contentLabel.font = MOL_LIGHT_FONT(14);
    contentLabel.numberOfLines = 0;
    [self.contentView addSubview:contentLabel];
    
    UIButton *communityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _communityButton = communityButton;
    communityButton.userInteractionEnabled = NO;
    [communityButton setTitle:@"查看社区礼仪" forState:UIControlStateNormal];
    [communityButton setImage:[UIImage imageNamed:@"mine_msg_jump"] forState:UIControlStateNormal];
    [communityButton setTitleColor:HEX_COLOR(0x74BDF5) forState:UIControlStateNormal];
    communityButton.titleLabel.font = MOL_REGULAR_FONT(14);
    [self.contentView addSubview:communityButton];
    
    MOLMessageCardView *cardView = [[MOLMessageCardView alloc] init];
    _cardView = cardView;
    [self.contentView addSubview:cardView];
}

- (void)calculatorSystemNotiCellFrame
{
    self.timeLabel.width = self.contentView.width;
    self.timeLabel.height = 17;
    self.timeLabel.y = 15;
    
    self.bubbleImageView.width = 14;
    self.bubbleImageView.height = 14;
    self.bubbleImageView.x = 20;
    self.bubbleImageView.y = self.timeLabel.bottom + 23;
    
    self.contentLabel.x = self.bubbleImageView.right + 5;
    self.contentLabel.width = self.contentView.width - self.contentLabel.x - 20;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.contentView.width - self.contentLabel.x - 20;
    self.contentLabel.y = self.timeLabel.bottom + 20;
    
    [self.communityButton sizeToFit];
    self.communityButton.x = self.contentLabel.x;
    self.communityButton.y = self.contentLabel.bottom + 15;
    [self.communityButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
    
    self.cardView.width = self.contentView.width - 40;
    self.cardView.height = 80;
    self.cardView.x = 20;
    self.cardView.y = self.communityButton.hidden ? self.contentLabel.bottom + 15 : self.communityButton.bottom + 15;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorSystemNotiCellFrame];
}
@end
