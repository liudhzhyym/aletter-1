//
//  MOLMineMailReusableView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailReusableView.h"
#import "MOLHead.h"

@interface MOLMineMailReusableView ()
@property (nonatomic, weak) UILabel *monthLable;
@property (nonatomic, weak) UILabel *countLable;
@end

@implementation MOLMineMailReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMineMailReusableViewUI];
    }
    return self;
}

#pragma mark - 赋值
- (void)setName:(NSString *)name
{
    _name = name;
    self.monthLable.text = name;
}

- (void)setCount:(NSString *)count
{
    _count = count;
    self.countLable.text = count;
}

#pragma mark - UI
- (void)setupMineMailReusableViewUI
{
    UILabel *monthLable = [[UILabel alloc] init];
    _monthLable = monthLable;
    monthLable.text = @" ";
    monthLable.textColor = HEX_COLOR(0xffffff);
    monthLable.font = MOL_MEDIUM_FONT(22);
    monthLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:monthLable];
    
    UILabel *countLable = [[UILabel alloc] init];
    _countLable = countLable;
    countLable.text = @" ";
    countLable.textColor = HEX_COLOR_ALPHA(0xffffff, 0.4);
    countLable.font = MOL_MEDIUM_FONT(14);
    countLable.textAlignment = NSTextAlignmentRight;
    [self addSubview:countLable];
}

- (void)calculatorMineMailReusableViewFrame
{
    self.monthLable.width = 150;
    self.monthLable.height = 22;
    self.monthLable.centerX = self.width * 0.5;
    self.monthLable.centerY = self.height * 0.5;
    
    self.countLable.width = 100;
    self.countLable.height = 20;
    self.countLable.right = self.width - 20;
    self.countLable.bottom = self.monthLable.bottom;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMineMailReusableViewFrame];
}
@end
