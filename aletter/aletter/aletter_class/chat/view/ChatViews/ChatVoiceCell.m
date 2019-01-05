//
//  ChatVoiceCell.m
//  aletter
//
//  Created by xujin on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "ChatVoiceCell.h"
#import "MOLHead.h"
#import "CIMUserMsg.h"

@interface ChatVoiceCell()
@property (nonatomic, strong)UIImageView *statusImg;
@property (nonatomic ,strong)UIImageView *contentImg;
@property (nonatomic ,strong)UIButton *retry;
@end

@implementation ChatVoiceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    NSLog(@"reuseIdentifier");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

-(void)chatVoiceCell:(CIMUserMsg *)content{
    
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

- (UIImageView *)contentImg{
    if (!_contentImg) {
        _contentImg =[UIImageView new];
        [_contentImg setImage: [UIImage imageNamed:@""]];
        [_contentImg setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_contentImg];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectContentImage:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_contentImg addGestureRecognizer:tap];
    }
    return _contentImg;
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

-(void)selectContentImage:(UIGestureRecognizer *)tap{
    NSLog(@"图像点击事件触发");
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
