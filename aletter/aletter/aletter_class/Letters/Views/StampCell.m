//
//  StampCell.m
//  aletter
//
//  Created by xiaolong li on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "StampCell.h"
#import "StampModel.h"
#import "MOLHead.h"
#import <UIImageView+WebCache.h>

@interface StampCell ()
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) UIImageView *stampIcon;
@property (nonatomic, strong) UILabel *stampTitle;
@property (nonatomic, strong) UIImageView *markImg;
@property (nonatomic, strong) StampModel *stampDto;
@property (nonatomic, strong) UILabel *tipLable;


@end

@implementation StampCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor: [UIColor whiteColor]];
        self.stampDto =[StampModel new];
        [self layoutUI];
    }
    return self;
}

- (void)layoutUI{
    self.contentBgView =[UIView new];
    [self.contentBgView setBackgroundColor: self.stampDto.isSelectStatus?HEX_COLOR_ALPHA(0xF8F8F8,1):HEX_COLOR_ALPHA(0xF8F8F8,0.5)];
    [self.contentBgView setUserInteractionEnabled:self.isAuthority?YES:NO];
    
    self.stampIcon =[UIImageView new];
    [self.stampIcon setImage: [UIImage imageNamed:@"卡通邮票默认"]];
    
    self.stampTitle =[UILabel new];
    [self.stampTitle setTextColor:HEX_COLOR(0x091F38)];
    [self.stampTitle setFont: MOL_MEDIUM_FONT(12)];
    [self.stampTitle setTextAlignment:NSTextAlignmentCenter];
    [self.stampTitle setText:@"有封信"];
    
    self.tipLable =[UILabel new];
    [self.tipLable setTextColor:HEX_COLOR(0x091F38)];
    [self.tipLable setFont: MOL_LIGHT_FONT(11)];
    [self.tipLable setTextAlignment:NSTextAlignmentCenter];
    [self.tipLable setText:@"成功邀请0个用户"];
    
    self.markImg =[UIImageView new];
    [self.markImg setImage:[UIImage imageNamed:@"选择邮票"]];
    [self.markImg setAlpha:0];
    
    [self addSubview:self.contentBgView];
    [self.contentBgView addSubview:self.markImg];
    [self.contentBgView addSubview:self.stampIcon];
    [self.contentBgView addSubview:self.stampTitle];
    [self.contentBgView addSubview:self.tipLable];
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.contentBgView setFrame:CGRectMake(0, 20, 100, 120)];
    [self.stampIcon setFrame:CGRectMake(30, 15, 40, 51)];
    [self.stampTitle setFrame:CGRectMake(0, self.stampIcon.origin.y+self.stampIcon.height+5,self.contentBgView.width, 17)];
    
    [self.markImg setFrame:CGRectMake(self.contentBgView.width-14, 0, 14, 14)];
    //self.stampIcon.y = (self.contentBgView.height-self.stampIcon.height-self.stampTitle.height)/2.0;
    //self.stampTitle.y =self.stampIcon.origin.y+self.stampIcon.height+5;
    [self.tipLable setFrame:CGRectMake(0,self.stampTitle.bottom+5,self.stampTitle.width, 16)];
    
}

- (void)stampCellContent:(StampModel *)stampDto{
    self.stampDto =stampDto;
    self.isAuthority=stampDto.isAuthority;
    self.isSelectStatus =stampDto.isSelectStatus;
    [self.contentBgView setBackgroundColor: self.stampDto.isSelectStatus?HEX_COLOR_ALPHA(0xF8F8F8,1):HEX_COLOR_ALPHA(0xF8F8F8,0.5)];
    [self.contentBgView setUserInteractionEnabled:self.isAuthority?YES:NO];
    
    NSURL *url;
    if (self.isAuthority && self.isAuthority.integerValue==1) { //表示高亮图
        url =[NSURL URLWithString:self.stampDto.lightImage?self.stampDto.lightImage:@""];
    }else{
        url =[NSURL URLWithString:self.stampDto.darkImage?self.stampDto.darkImage:@""];
    }
    
    [self.stampIcon sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"卡通邮票默认"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            NSLog(@"下载失败%@",error);
            
        }
    }];
    
    [self.stampTitle setText:[NSString stringWithFormat:@"%@",self.stampDto.name?self.stampDto.name:@"有封信"]];
    
    [self.markImg setAlpha:self.isSelectStatus?YES:NO];
    
    [self.tipLable setText:[NSString stringWithFormat:@"成功邀请%ld个用户",self.stampDto.inviteCount.integerValue?self.stampDto.inviteCount.integerValue:0]];
    
    if (self.isAuthority && self.isAuthority.integerValue==1) { //表示高亮图
        [self.tipLable setTextColor:HEX_COLOR(0x091F38)];
        [self.stampTitle setTextColor:HEX_COLOR(0x091F38)];
    }else{
        [self.tipLable setTextColor:HEX_COLOR_ALPHA(0x091F38, 0.5)];
        [self.stampTitle setTextColor:HEX_COLOR_ALPHA(0x091F38, 0.5)];
    }
    
}

- (void)setIsSelectStatus:(BOOL)isSelectStatus
{
    _isSelectStatus =isSelectStatus;
    [self.markImg setAlpha:_isSelectStatus?YES:NO];
}



@end
