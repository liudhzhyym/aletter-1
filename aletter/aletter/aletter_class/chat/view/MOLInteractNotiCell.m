//
//  MOLInteractNotiCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
/*
    互动通知cell
 */

#import "MOLInteractNotiCell.h"
#import "MOLInteractCardView.h"
#import "MOLHead.h"

@interface MOLInteractNotiCell ()
@property (nonatomic, weak) UIImageView *bubbleImageView;  // 气泡
@property (nonatomic, weak) UILabel *title_Label;  // 某人 【喜欢/评论】 了你 【评论/信件】
@property (nonatomic, weak) UILabel *contentLabel;  // 内容
@property (nonatomic, weak) UIButton *unreadButton;  // 未读数button
@property (nonatomic, weak) MOLInteractCardView *cardView; // 卡片
@end
@implementation MOLInteractNotiCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupInteractNotiCellUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - 赋值
- (void)setNotiModel:(MOLNotificationModel *)notiModel
{
    _notiModel = notiModel;
    
    // title
    NSString *time = [NSString moli_interactTimeGetMessageTimeWithTimestamp:notiModel.createTime];
    self.title_Label.text = [NSString stringWithFormat:@"%@%@",time,notiModel.content];
    
    // 评论内容
    if (notiModel.commentVO) {
        self.contentLabel.hidden = NO;
        self.contentLabel.text = notiModel.commentVO.content;
    }else{
        self.contentLabel.hidden = YES;
    }

    // 未读数按钮
    if (notiModel.unReadNum.integerValue > 0 && notiModel.msgType.integerValue == 2) {
        self.unreadButton.hidden = NO;
        NSString *str = [NSString stringWithFormat:@"%@条评论未读",notiModel.unReadNum];
        [self.unreadButton setTitle:str forState:UIControlStateNormal];
    }else{
        self.unreadButton.hidden = YES;
    }

    // 卡片
    self.cardView.notiModel = notiModel;
}

#pragma mark - UI
- (void)setupInteractNotiCellUI
{
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:INTITLE_LEFT_Highlight]];
    _bubbleImageView = bubbleImageView;
    [self.contentView addSubview:bubbleImageView];
    
    UILabel *title_Label = [[UILabel alloc] init];
    _title_Label = title_Label;
    title_Label.text = @" ";
    title_Label.textColor = HEX_COLOR(0xffffff);
    title_Label.font = MOL_LIGHT_FONT(14);
    [self.contentView addSubview:title_Label];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.text = @" ";
    contentLabel.textColor = HEX_COLOR(0xffffff);
    contentLabel.font = MOL_LIGHT_FONT(14);
    contentLabel.numberOfLines = 0;
    [self.contentView addSubview:contentLabel];
    
    UIButton *unreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _unreadButton = unreadButton;
    unreadButton.userInteractionEnabled = NO;
    [unreadButton setTitle:@"0条评论未读" forState:UIControlStateNormal];
    [unreadButton setImage:[UIImage imageNamed:@"mine_msg_jump"] forState:UIControlStateNormal];
    [unreadButton setTitleColor:HEX_COLOR(0x74BDF5) forState:UIControlStateNormal];
    unreadButton.titleLabel.font = MOL_REGULAR_FONT(14);
    [self.contentView addSubview:unreadButton];
    
    MOLInteractCardView *cardView = [[MOLInteractCardView alloc] init];
    _cardView = cardView;
    [self.contentView addSubview:cardView];
}

- (void)calculatorInteractNotiCellFrame
{
    self.bubbleImageView.width = 14;
    self.bubbleImageView.height = 14;
    self.bubbleImageView.x = 20;
    self.bubbleImageView.y = 28;
    
    self.title_Label.x = self.bubbleImageView.right + 5;
    self.title_Label.width = self.contentView.width - self.contentLabel.x - 20;
    [self.title_Label sizeToFit];
    self.title_Label.width = self.contentView.width - self.contentLabel.x - 20;
    self.title_Label.y = 25;
    
    self.contentLabel.x = self.bubbleImageView.right + 5;
    self.contentLabel.width = self.contentView.width - self.contentLabel.x - 20;
    [self.contentLabel sizeToFit];
    self.contentLabel.width = self.contentView.width - self.contentLabel.x - 20;
    self.contentLabel.y = self.title_Label.bottom + 5;
    
    [self.unreadButton sizeToFit];
    self.unreadButton.x = self.contentLabel.x;
    if (self.contentLabel.hidden) {
        self.unreadButton.y = self.title_Label.bottom + 15;
    }else{
        self.unreadButton.y = self.contentLabel.bottom + 15;
    }
    [self.unreadButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
    
    self.cardView.width = self.contentView.width - 40;
    self.cardView.height = 80;
    self.cardView.x = 20;
    if (self.unreadButton.hidden && self.contentLabel.hidden) {
        self.cardView.y = self.title_Label.bottom + 15;
    }else if (self.unreadButton.hidden){
        self.cardView.y = self.contentLabel.bottom + 15;
    }else{
        self.cardView.y = self.unreadButton.bottom + 15;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorInteractNotiCellFrame];
}
@end
