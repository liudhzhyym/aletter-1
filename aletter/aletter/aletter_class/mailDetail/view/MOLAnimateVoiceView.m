//
//  MOLAnimateVoiceView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLAnimateVoiceView.h"
#import "MOLHead.h"

@interface MOLAnimateVoiceView ()

@property (nonatomic, weak) UIImageView *voiceImageView;
@property (nonatomic, weak) UIImageView *animateImageView;
@property (nonatomic, weak) UILabel *timeLabel;
@end

@implementation MOLAnimateVoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAnimateVoiceViewUI];
    }
    return self;
}

- (void)setShowTime:(NSString *)showTime
{
    _showTime = showTime;
    self.timeLabel.text = [NSString stringWithFormat:@"%@s",showTime];
}

// 开始动画
- (void)animateVoiceView_start
{
    [self.animateImageView startAnimating];
}
// 停止动画
- (void)animateVoiceView_stop
{
    [self.animateImageView stopAnimating];
}

#pragma mark - UI
- (void)setupAnimateVoiceViewUI
{
    UIView *backViewButton = [[UIView alloc] init];
    _backViewButton = backViewButton;
    backViewButton.backgroundColor = HEX_COLOR(0x4A90E2);
    [self addSubview:backViewButton];
    
    UIImageView *voiceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_microphone"]];
    _voiceImageView = voiceImageView;
    [backViewButton addSubview:voiceImageView];
    
    UIImageView *animateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_microphone_ani_3"]];
    _animateImageView = animateImageView;
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        NSString *str = [NSString stringWithFormat:@"detail_microphone_ani_%ld",i+1];
        UIImage *image = [UIImage imageNamed:str];
        [images addObject:image];
    }
    animateImageView.animationImages = images;
    animateImageView.animationDuration=1;
    animateImageView.animationRepeatCount=1;
    [backViewButton addSubview:animateImageView];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.text = @"0s";
    timeLabel.textColor = HEX_COLOR(0xffffff);
    timeLabel.font = MOL_REGULAR_FONT(12);
    timeLabel.textAlignment = NSTextAlignmentRight;
    [backViewButton addSubview:timeLabel];
}

- (void)calculatorAnimateVoiceViewFrame
{
    self.backViewButton.width = 200;
    self.backViewButton.height = 40;
    self.backViewButton.x = 15;
    self.backViewButton.layer.cornerRadius = 12;
    self.backViewButton.layer.masksToBounds = YES;
    
    self.voiceImageView.x = 15;
    self.voiceImageView.centerY = self.backViewButton.height * 0.5;
    
    self.animateImageView.x = self.voiceImageView.right + 10;
    self.animateImageView.centerY = self.voiceImageView.centerY;
    
    self.timeLabel.width = 60;
    self.timeLabel.height = 17;
    self.timeLabel.centerY = self.voiceImageView.centerY;
    self.timeLabel.right = self.backViewButton.width - 15;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorAnimateVoiceViewFrame];
}
@end
