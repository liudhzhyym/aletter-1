//
//  ChatStoryTipCell.m
//  aletter
//
//  Created by xujin on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "ChatStoryTipCell.h"
#import "MOLHead.h"
#import "MOLMsgOtherModel.h"
@interface ChatStoryTipCell()
@property (nonatomic, retain)UIButton *iconImg;
@property (nonatomic, retain)UILabel *content;

@end
@implementation ChatStoryTipCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"reuseIdentifier");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI{
    
    for (id views in self.content.subviews) {
        if (views) {
            [views removeFromSuperview];
        }
    }
    [self setBackgroundColor: [UIColor clearColor]];

    self.iconImg =[UIButton buttonWithType:UIButtonTypeCustom];
    [self.iconImg setImage:[UIImage imageNamed:@"common_leftBubble_high"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.iconImg];
    
    self.content = [UILabel new];
    [self.content setTextColor:HEX_COLOR(0xffffff)];
    [self.content setFont:MOL_LIGHT_FONT(14)];
    [self.content setBackgroundColor:[UIColor clearColor]];
    [self.content setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.content];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    __weak __typeof(self) weakSelf = self;
    [self.iconImg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset((20-14)/2.0);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(14);
        
    }];
    [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.iconImg.mas_right).offset(5);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(180);
    }];
    NSLog(@"layoutSubviews");
}

-(void)chatStoryTipCell:(MOLMsgOtherModel*)model{
    if (model.msgType ==EIMMSGOTHER_StoryText) {
        if (model.msg && model.msg.length>0) {
            [self.content setText:model.msg];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
