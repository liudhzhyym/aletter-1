//
//  ChatTextCell.m
//  aletter
//
//  Created by xiaolong li on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "ChatTextCell.h"
#import "MOLHead.h"
#import "CIMUserMsg.h"


@interface ChatTextCell()
@property (nonatomic, strong)UIImageView *statusImg;
@property (nonatomic ,strong)UIImageView *backgroud;
@property (nonatomic ,strong)UILabel *content;
@property (nonatomic ,strong)UIButton *retry;

@end

@implementation ChatTextCell

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
    
   
        self.backgroud =[UIImageView new];
        //[self.backgroud setImage: [UIImage imageNamed:@"气泡2"]];
        [self.backgroud setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.backgroud];
    
    self.content = [UILabel new];
    [self.content setTextColor:HEX_COLOR(0xffffff)];
    [self.content setFont:MOL_LIGHT_FONT(14)];
    [self.content setBackgroundColor:[UIColor clearColor]];
    [self.content setTextAlignment:NSTextAlignmentRight];
    [self.backgroud addSubview:self.content];
    
}



-(void)chatTextCell:(CIMUserMsg *)content{
    
    if (content) {
        CIMUserMsg *model =[CIMUserMsg new];
        model =(CIMUserMsg *)content;
        CGSize w = [model.content boundingRectWithSize:CGSizeMake(MOL_SCREEN_WIDTH-40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)} context:nil].size;
        [_content setText: content.content];
        
        UIImage *img =nil;
        if ([MOLUserManagerInstance user_getUserInfo].userId.integerValue==model.userId.integerValue) {//表示自己发送的
            UIEdgeInsets insets = UIEdgeInsetsMake(5, 5, 5, 5);
            // 指定为拉伸模式，伸缩后重新赋值
            img =[UIImage imageNamed:@"气泡2"];
            [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
            [self.backgroud setImage:img];
            [self.backgroud setFrame:CGRectMake(MOL_SCREEN_WIDTH-20-18-w.width-18,0, w.width+18+18,17+w.height+11)];
            [self.content setFrame:CGRectMake(18, 17,w.width, w.height)];
            
        }else{//表示别人发的
            
            UIEdgeInsets insets = UIEdgeInsetsMake(5, 5, 5, 5);
            // 指定为拉伸模式，伸缩后重新赋值
            img =[UIImage imageNamed:@"气泡1"];
            [img resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
            [self.backgroud setImage:img];
            [self.backgroud setFrame:CGRectMake(20,0, w.width+18+18,17+w.height+11)];
            [self.content setFrame:CGRectMake(18, 17,w.width, w.height)];
            
        }
        
        
        
    }
    
}

- (UIImageView *)statusImg{
    if (!_statusImg) {
        _statusImg =[UIImageView new];
        [_statusImg setImage: [UIImage imageNamed:@""]];
        [_statusImg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_statusImg];
    }
    return _statusImg;
}



// 重新发送按钮
- (UIButton *)retry {
    if (!_retry) {
        _retry = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retry setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        //        _retry.frame = CGRectMake(0, 0, 32, 32);
        [_retry sizeToFit];
        _retry.hidden = NO;
        [_retry addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_retry];
    }
    
    return _retry;
}

#pragma mark-
#pragma mark
-(void)retryButtonPressed:(UIButton *)sender{
    NSLog(@"重新发送事件触发");
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
