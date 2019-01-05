//
//  MOLStoryDetailHeadTopView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailHeadTopView.h"
#import "MOLHead.h"
#import <UIImageView+WebCache.h>
@interface MOLStoryDetailHeadTopView ()
@property (nonatomic, weak) UILabel *dayLabel;   // 几号
@property (nonatomic, weak) UILabel *dataLabel;   // 日期、星期
@property (nonatomic, weak) UILabel *weatherLabel;  // 天气温度
@property (nonatomic, weak) UIImageView *mailImageView;  // 邮票
@property (nonatomic, weak) UIImageView *tagMailImageView; // 邮票标签
@end

@implementation MOLStoryDetailHeadTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupStoryDetailHeadTopViewUI];
    }
    return self;
}

#pragma mark - 赋值
- (void)setModel:(MOLStoryModel *)model
{
    _model = model;
    self.dayLabel.text = [NSString stringWithFormat:@"%@",model.weatherInfo.day];
    [self.dayLabel sizeToFit];
    self.dataLabel.text = [NSString stringWithFormat:@"%@年%@月，%@",model.weatherInfo.year,model.weatherInfo.month,model.weatherInfo.week];
    [self.dataLabel sizeToFit];
    self.weatherLabel.text = model.weatherInfo.weather;
    [self.weatherLabel sizeToFit];
    
    [self.mailImageView sd_setImageWithURL:[NSURL URLWithString:model.stampVO.lightImage] placeholderImage:[UIImage imageNamed:@"storyDetail_mail"]];
}

#pragma mark - UI
- (void)setupStoryDetailHeadTopViewUI
{
    UILabel *dayLabel = [[UILabel alloc] init];
    _dayLabel = dayLabel;
    dayLabel.text = @"1";
    dayLabel.textColor = HEX_COLOR(0x091F38);
    dayLabel.font = MOL_REGULAR_FONT(38);
    [self addSubview:dayLabel];
    
    UILabel *dataLabel = [[UILabel alloc] init];
    _dataLabel = dataLabel;
    dataLabel.text = @"2018年7月,星期二";
    dataLabel.textColor = HEX_COLOR(0x091F38);
    dataLabel.font = MOL_MEDIUM_FONT(12);
    [self addSubview:dataLabel];
    
    UILabel *weatherLabel = [[UILabel alloc] init];
    _weatherLabel = weatherLabel;
    weatherLabel.text = @"雨转晴，24～29°C";
    weatherLabel.textColor = HEX_COLOR(0x091F38);
    weatherLabel.font = MOL_MEDIUM_FONT(12);
    [self addSubview:weatherLabel];
    
    UIImageView *mailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyDetail_mail"]];
    _mailImageView = mailImageView;
    [self addSubview:mailImageView];
    
    UIImageView *tagMailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storyDetail_mail_tag"]];
    _tagMailImageView = tagMailImageView;
    [self addSubview:tagMailImageView];
}

- (void)calculatorStoryDetailHeadTopViewFrame
{
    [self.dayLabel sizeToFit];
    self.dayLabel.height = 38;
    self.dayLabel.x = 15;
    self.dayLabel.y = 25;
    
    [self.dataLabel sizeToFit];
    self.dataLabel.height = 17;
    self.dataLabel.x = self.dayLabel.right + 9;
    self.dataLabel.y = self.dayLabel.y+2;
    
    [self.weatherLabel sizeToFit];
    self.weatherLabel.height = 17;
    self.weatherLabel.x = self.dataLabel.x;
    self.weatherLabel.y = self.dataLabel.bottom;
    
    self.mailImageView.width = 40;
    self.mailImageView.height = 51;
    self.mailImageView.right = self.width - 15;
    self.mailImageView.y = 20;
    
    self.tagMailImageView.width = 51;
    self.tagMailImageView.height = 31;
    self.tagMailImageView.bottom = self.mailImageView.bottom + 12;
    self.tagMailImageView.right = self.mailImageView.x + 7;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailHeadTopViewFrame];
}
@end
