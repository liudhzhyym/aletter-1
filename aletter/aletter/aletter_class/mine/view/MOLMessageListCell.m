//
//  MOLMessageListCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
/*
    消息列表cell
 */

#import "MOLMessageListCell.h"
#import "MOLHead.h"

@interface MOLMessageListCell ()
@property (nonatomic, weak) UIButton *imageButton;  // 左边图片
@property (nonatomic, weak) UILabel *title_Label;  // 名字
@property (nonatomic, weak) UIImageView *sexImageView;  // 性别
@property (nonatomic, weak) UILabel *subTitle_Label;  // 子名字
@property (nonatomic, weak) UILabel *timeLabel;  // 时间
@property (nonatomic, weak) UIButton *countButton;  // 未读个数
@end

@implementation MOLMessageListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupMessageListCellUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - 赋值
- (void)setChatModel:(MOLChatModel *)chatModel
{
    _chatModel = chatModel;
    [self.imageButton setImage:nil forState:UIControlStateNormal];
    [self.imageButton setTitle:chatModel.channelVO.channelName forState:UIControlStateNormal];
    
    self.title_Label.text = chatModel.toUser.userName;
    [self.title_Label sizeToFit];
    
    self.sexImageView.hidden = NO;
    if (chatModel.toUser.sex == 1) {
        self.sexImageView.image = [UIImage imageNamed:@"detail_man"];
    }else{
        self.sexImageView.image = [UIImage imageNamed:@"detail_woman"];
    }
    
    if (chatModel.isClose) {
        self.subTitle_Label.text = @"[对话已关闭]";
    }else{
        if (chatModel.chatLogVO.chatType.integerValue == 1) {
            self.subTitle_Label.text = @"[图片]";
        }else if (chatModel.chatLogVO.chatType.integerValue == 2){
            self.subTitle_Label.text = @"[语音]";
        }else{
            self.subTitle_Label.text = chatModel.chatLogVO.content;
        }
    }
    
    [self.subTitle_Label sizeToFit];
    
    if (chatModel.unReadNum.integerValue > 0) {
        self.countButton.hidden = NO;
        [self.countButton setTitle:[NSString stringWithFormat:@"%@",chatModel.unReadNum] forState:UIControlStateNormal];
        [self.countButton sizeToFit];
    }else{
        self.countButton.hidden = YES;
    }
    
    self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:chatModel.createTime];
    [self.timeLabel sizeToFit];
}

- (void)setSystemModel:(MOLSystemModel *)systemModel
{
    _systemModel = systemModel;
    if (systemModel.msgType.integerValue == 1) {  // 系统通知
        [self.imageButton setImage:[UIImage imageNamed:@"mine_msg_sys"] forState:UIControlStateNormal];
        [self.imageButton setTitle:nil forState:UIControlStateNormal];
        self.title_Label.text = @"系统通知";
    }else{
        [self.imageButton setImage:[UIImage imageNamed:@"mine_msg_hudong"] forState:UIControlStateNormal];
        [self.imageButton setTitle:nil forState:UIControlStateNormal];
        self.title_Label.text = @"互动通知";
    }
    [self.title_Label sizeToFit];
    
    self.sexImageView.hidden = YES;
    
    self.subTitle_Label.text = systemModel.content;
    [self.title_Label sizeToFit];
    
    if (systemModel.unReadNum.integerValue > 0) {
        self.countButton.hidden = NO;
        [self.countButton setTitle:[NSString stringWithFormat:@"%@",systemModel.unReadNum] forState:UIControlStateNormal];
        [self.countButton sizeToFit];
    }else{
        self.countButton.hidden = YES;
    }
    
    self.timeLabel.text = [NSString moli_timeGetMessageTimeWithTimestamp:systemModel.createTime];
    [self.timeLabel sizeToFit];
}

#pragma mark - UI
- (void)setupMessageListCellUI
{
    UIButton *imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _imageButton = imageButton;
    [imageButton setBackgroundImage:[UIImage imageNamed:@"mine_msg_mail"] forState:UIControlStateNormal];
    [imageButton setImage:[UIImage imageNamed:@"mine_msg_sys"] forState:UIControlStateNormal];
    [imageButton setTitle:nil forState:UIControlStateNormal];
    [imageButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    imageButton.titleLabel.font = MOL_REGULAR_FONT(12);
    imageButton.userInteractionEnabled = NO;
    [self.contentView addSubview:imageButton];
    
    UILabel *title_Label = [[UILabel alloc] init];
    _title_Label = title_Label;
    title_Label.text = @" ";
    title_Label.textColor = HEX_COLOR(0xffffff);
    title_Label.font = MOL_MEDIUM_FONT(14);
    [self.contentView addSubview:title_Label];
    
    UIImageView *sexImageView = [[UIImageView alloc] init];
    _sexImageView = sexImageView;
    sexImageView.image = [UIImage imageNamed:@"detail_man"];
    [self.contentView addSubview:sexImageView];
    
    UILabel *subTitle_Label = [[UILabel alloc] init];
    _subTitle_Label = subTitle_Label;
    subTitle_Label.text = @" ";
    subTitle_Label.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    subTitle_Label.font = MOL_LIGHT_FONT(14);
    [self.contentView addSubview:subTitle_Label];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @" ";
    timeLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    timeLabel.font = MOL_LIGHT_FONT(12);
    [self.contentView addSubview:timeLabel];
    
    UIButton *countButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _countButton = countButton;
    [countButton setBackgroundImage:[UIImage imageNamed:@"mine_msg_read"] forState:UIControlStateNormal];
    [countButton setTitle:@" " forState:UIControlStateNormal];
    [countButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    countButton.titleLabel.font = MOL_REGULAR_FONT(10);
    [self.contentView addSubview:countButton];
}

- (void)calculatorMessageListCellFrame
{
    self.imageButton.width = 50;
    self.imageButton.height = 60;
    self.imageButton.x = 20;
    self.imageButton.y = 30;
    
    [self.title_Label sizeToFit];
    self.title_Label.height = 20;
    self.title_Label.y = self.imageButton.y;
    self.title_Label.x = self.imageButton.right + 10;
    
    self.sexImageView.width = 12;
    self.sexImageView.height = 12;
    self.sexImageView.centerY = self.title_Label.centerY;
    self.sexImageView.x = self.title_Label.right + 5;
    
    [self.subTitle_Label sizeToFit];
    self.subTitle_Label.height = 20;
    self.subTitle_Label.y = self.title_Label.bottom + 3;
    self.subTitle_Label.x = self.title_Label.x;
    self.subTitle_Label.width = self.contentView.width - self.subTitle_Label.x - 20;
    
    [self.timeLabel sizeToFit];
    self.timeLabel.height = 17;
    self.timeLabel.x = self.title_Label.x;
    self.timeLabel.y = self.subTitle_Label.bottom + 3;
    
    [self.countButton sizeToFit];
    self.countButton.width += 6;
    self.countButton.height = 16;
    self.countButton.centerY = self.title_Label.centerY;
    self.countButton.right = self.contentView.width - 20;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMessageListCellFrame];
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
