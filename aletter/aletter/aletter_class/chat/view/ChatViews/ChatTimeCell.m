//
//  ChatTimeCell.m
//  aletter
//
//  Created by xiaolong li on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "ChatTimeCell.h"
#import "MOLHead.h"
#import "MOLMsgOtherModel.h"
#import "NSDateUtils.h"

@interface ChatTimeCell()
@property (nonatomic, retain)UILabel *timeLabel;

@end

@implementation ChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"reuseIdentifier");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor: [UIColor clearColor]];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI{
    
    self.timeLabel = [UILabel new];
    [self.timeLabel setTextColor:HEX_COLOR(0xffffff)];
    [self.timeLabel setFont:MOL_LIGHT_FONT(12)];
    [self.timeLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:_timeLabel];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    __weak __typeof(self) weakSelf = self;
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
    }];
    NSLog(@"layoutSubviews");
}

-(void)chatTimeCell:(MOLMsgOtherModel*)model{
    if (model) {
        if (model.msgType == EIMMSGOTHER_TIME) {
            [self.timeLabel setText:[model.stamp dateWithString]];
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    NSLog(@"awakeFromNib");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
