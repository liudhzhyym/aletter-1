//
//  ChatSrotyCardCell.m
//  aletter
//
//  Created by xujin on 2018/9/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "ChatSrotyCardCell.h"
#import "MOLMsgOtherModel.h"
#import "MOLHead.h"
#import "MOLStoryModel.h"
#import "MOLMailModel.h"
#import "ToolsHelper.h"
#import "NSDateUtils.h"
#import <UIImageView+WebCache.h>

@interface ChatSrotyCardCell()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *timeLabel;   // 时间label
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *tipLable;
@property (nonatomic, retain) UILabel *content;

@end
@implementation ChatSrotyCardCell

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
    
    self.bgView =[UIView new];
    self.bgView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    self.bgView.clipsToBounds = YES;
    [self.contentView addSubview:self.bgView];
        

    self.imgView =[UIImageView  new];
    [self.imgView setImage: [UIImage imageNamed:@"卡通邮票默认"]];
    [self.imgView setBackgroundColor:[UIColor clearColor]];
    [self.bgView addSubview:self.imgView];
        
    self.tipLable = [UILabel new];
    [self.tipLable setTextColor:HEX_COLOR(0x3A384D)];
    [self.tipLable setFont:MOL_MEDIUM_FONT(14)];
    [self.tipLable setBackgroundColor:[UIColor clearColor]];
    [self.tipLable setTextAlignment:NSTextAlignmentCenter];
    [self.tipLable setText:@"标签"];
    [self.imgView addSubview:self.tipLable];
        
        
    self.content = [UILabel new];
    [self.content setTextColor:HEX_COLOR(0xffffff)];
    [self.content setFont:MOL_LIGHT_FONT(14)];
    [self.content setBackgroundColor:[UIColor clearColor]];
    [self.content setTextAlignment:NSTextAlignmentLeft];
    [self.bgView addSubview:self.content];
        
    self.timeLabel = [UILabel new];
    [self.timeLabel setTextColor:HEX_COLOR(0xffffff)];
    [self.timeLabel setFont:MOL_LIGHT_FONT(12)];
    [self.timeLabel setBackgroundColor:[UIColor clearColor]];
    [self.timeLabel setTextAlignment:NSTextAlignmentLeft];
    [self.bgView addSubview:self.timeLabel];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    __weak __typeof(self) weakSelf = self;
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(MOL_SCREEN_WIDTH-40);
        make.height.mas_equalTo(120);
    }];
    
    self.bgView.layer.cornerRadius = 12;
    
    [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(103);
    }];
    
    [self.tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.imgView.mas_bottom);
        make.left.mas_equalTo(weakSelf.imgView).offset(5);
        make.right.mas_equalTo(weakSelf.imgView).offset(-5);
        make.height.mas_equalTo(26);
    }];
    
    [self.content mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).offset(24);
        make.left.mas_equalTo(weakSelf.imgView.mas_right).offset(10);
        make.right.mas_equalTo(weakSelf.bgView.right).offset(-6);
        make.height.mas_equalTo(40);
    }];
    
    [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.content.mas_bottom).offset(15);
        make.left.mas_equalTo(weakSelf.content.mas_left);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(17);
        
    }];
    
    NSLog(@"layoutSubviews");
}

-(void)chatSrotyCardCell:(MOLMsgOtherModel*)model;{
   
    if (model.msgType ==EIMMSGOTHER_StorCard) {
        
        if (model) {
            MOLStoryModel *mailDto =[MOLStoryModel new];
            mailDto =model.storyDto;
            __weak __typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *url =[NSURL URLWithString:mailDto.channelVO.image?mailDto.channelVO.image:@""];
                [self.imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"卡通邮票默认"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    if (error) {
                        NSLog(@"下载失败%@",error);
                    }
                }];
                
            [weakSelf.tipLable setText: [NSString stringWithFormat:@"%@",mailDto.channelVO.channelName?mailDto.channelVO.channelName:@"标签"]];
            [weakSelf.content setText:mailDto.content_original?mailDto.content_original:@""];
            [weakSelf.timeLabel setText:[NSString moli_timeGetMessageTimeWithTimestamp:mailDto.createTime]];
            [weakSelf setNeedsLayout];
            [weakSelf layoutIfNeeded];
            });
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
