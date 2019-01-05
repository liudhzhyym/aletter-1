//
//  MOLHomeCollectionViewCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLHomeCollectionViewCell.h"
#import "MOLHead.h"
#import <UIImageView+WebCache.h>

@interface MOLHomeCollectionViewCell ()
@property (nonatomic, weak) UIImageView *backImageView;
@property (nonatomic, weak) UIImageView *tagImageView;
@property (nonatomic, weak) UILabel *tagNameLabel;
@end

@implementation MOLHomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHomeCollectionViewCellUI];
    }
    return self;
}

- (void)setMailModel:(MOLMailModel *)mailModel
{
    _mailModel = mailModel;
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:mailModel.image]];
    self.tagNameLabel.text = mailModel.channelName;
}

#pragma mark - UI
- (void)setupHomeCollectionViewCellUI
{
    UIImageView *backImageView = [[UIImageView alloc] init];
    _backImageView = backImageView;
//    backImageView.image = [UIImage imageNamed:@"home_stamp_1"];
    [self.contentView addSubview:backImageView];
    
//    UIImageView *tagImageView = [[UIImageView alloc] init];
//    _tagImageView = tagImageView;
//    tagImageView.image = [UIImage imageNamed:@"home_lock"];
//    [self.backImageView addSubview:tagImageView];
    
    UILabel *tagNameLabel = [[UILabel alloc] init];
    _tagNameLabel = tagNameLabel;
    tagNameLabel.text = @"标签";
    tagNameLabel.textColor = HEX_COLOR(0x3A384D);
    tagNameLabel.font = MOL_MEDIUM_FONT(14);
    tagNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.backImageView addSubview:tagNameLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorHomeCollectionViewCellFrame];
}

- (void)calculatorHomeCollectionViewCellFrame
{
    self.backImageView.width = self.contentView.width;
    self.backImageView.height = self.contentView.height;
    
//    self.tagImageView.width = MOL_SCREEN_ADAPTER(70);
//    self.tagImageView.height = self.tagImageView.width;
//    self.tagImageView.centerX = self.backImageView.width * 0.5;
//    self.tagImageView.y = MOL_SCREEN_ADAPTER(7);
    
    self.tagNameLabel.width = self.backImageView.width - 6;
    self.tagNameLabel.height = 20;//self.backImageView.height - self.tagImageView.bottom;
    self.tagNameLabel.bottom = self.backImageView.height - 3;
    self.tagNameLabel.x = 3;
}
@end
