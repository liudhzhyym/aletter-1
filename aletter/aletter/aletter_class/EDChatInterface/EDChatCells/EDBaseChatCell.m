//
//  EDBaseChatCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDBaseChatCell.h"

@implementation EDBaseChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupBaseChatCellUI];
    }
    return self;
}

- (void)updateCellWithCellModel:(EDBaseMessageModel *)model{
    
    if (model.fromType == MessageFromType_me) {
        
        UIImage *image = [UIImage imageNamed:@"msg_bubble_right"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 30, 20, 30) resizingMode:UIImageResizingModeStretch];
        self.bubbleImageView.image = image;
    }else{
        
        UIImage *image = [UIImage imageNamed:@"msg_bubble_left"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 30, 20, 30) resizingMode:UIImageResizingModeStretch];
        self.bubbleImageView.image = image;
    }
    
}

#pragma mark - UI
- (void)setupBaseChatCellUI
{
    UIImageView *bubbleImageView = [[UIImageView alloc] init];
    self.bubbleImageView = bubbleImageView;
    [self.contentView addSubview:bubbleImageView];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _sendIndicatorView = indicatorView;
    [self.contentView addSubview:indicatorView];
    
}

- (void)calculatorBaseChatCellFrame{}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorBaseChatCellFrame];
}
@end
