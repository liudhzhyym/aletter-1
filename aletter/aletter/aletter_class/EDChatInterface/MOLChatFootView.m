//
//  MOLChatFootView.m
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChatFootView.h"
#import "MOLHead.h"

@interface MOLChatFootView ()
@property (nonatomic, weak) UIImageView *leftImageView;
@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UIButton *leftButton;  // 重新开启对话(同意？)

@property (nonatomic, weak) UIImageView *rightImageView;
@property (nonatomic, weak) UILabel *rightLabel;
@property (nonatomic, weak) UIButton *rightButton;  // 重新开启对话
@end

@implementation MOLChatFootView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChatFootViewUI];
    }
    return self;
}

- (void)setFootType:(MOLChatFootViewType)footType
{
    _footType = footType;
    if (footType == MOLChatFootViewType_requesting) {
        self.height = 60;
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.leftButton.hidden = YES;
        self.rightImageView.hidden = NO;
        self.rightLabel.hidden = NO;
        self.rightButton.hidden = YES;
        
        self.rightLabel.text = @"已向对方发送重新对话的请求";
        
    }else if (footType == MOLChatFootViewType_report){
        self.height = 60;
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.leftButton.hidden = YES;
        self.rightImageView.hidden = NO;
        self.rightLabel.hidden = NO;
        self.rightButton.hidden = YES;
        
        self.rightLabel.text = @"有封信将审核这次举报，对话自动关闭";
    }else if (footType == MOLChatFootViewType_againChat){
        self.height = 110;
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.leftButton.hidden = YES;
        self.rightImageView.hidden = NO;
        self.rightLabel.hidden = NO;
        self.rightButton.hidden = NO;
        
        self.rightLabel.text = @"对话已关闭";
    }else if (footType == MOLChatFootViewType_chatRequest){
        self.height = 110;
        self.leftImageView.hidden = NO;
        self.leftLabel.hidden = NO;
        self.leftButton.hidden = NO;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightButton.hidden = YES;
        
        self.leftLabel.text = @"对方向你请求开启对话";
    }else{
        self.height = 0.01;
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.leftButton.hidden = YES;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightButton.hidden = YES;
    }
}

#pragma mark - 按钮的点击
- (void)button_clickLeftButton:(UIButton *)button
{
    if (self.actionFootBlock) {
        self.actionFootBlock(MOLChatFootViewType_chatRequest);
    }
}

- (void)button_clickRightButton:(UIButton *)button
{
    if (self.actionFootBlock) {
        self.actionFootBlock(MOLChatFootViewType_againChat);
    }
}

#pragma mark - UI
- (void)setupChatFootViewUI
{
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_leftBubble_high"]];  // toast_red
    _leftImageView = leftImageView;
    [self addSubview:leftImageView];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    _leftLabel = leftLabel;
    leftLabel.text = @" ";
    leftLabel.textColor = HEX_COLOR(0xffffff);
    leftLabel.font = MOL_MEDIUM_FONT(14);
    [self addSubview:leftLabel];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton = leftButton;
    [leftButton setTitle:@"重新开启对话" forState:UIControlStateNormal];
    [leftButton setTitleColor:HEX_COLOR(0x07360D) forState:UIControlStateNormal];
    leftButton.titleLabel.font = MOL_MEDIUM_FONT(14);
    [leftButton addTarget:self action:@selector(button_clickLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.backgroundColor = HEX_COLOR(0x6BD379);
    [self addSubview:leftButton];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_red"]];
    _rightImageView = rightImageView;
    [self addSubview:rightImageView];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    _rightLabel = rightLabel;
    rightLabel.text = @" ";
    rightLabel.textColor = HEX_COLOR(0xffffff);
    rightLabel.font = MOL_MEDIUM_FONT(14);
    rightLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:rightLabel];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
    [rightButton setTitle:@"重新开启对话" forState:UIControlStateNormal];
    [rightButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    rightButton.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    rightButton.titleLabel.font = MOL_MEDIUM_FONT(14);
    [rightButton addTarget:self action:@selector(button_clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:rightButton];
    
}

- (void)calculatorChatFootViewFrame
{
    self.leftImageView.width = 14;
    self.leftImageView.height = 14;
    self.leftImageView.x = 20;
    self.leftImageView.y = 20;
    
    self.leftLabel.width = self.width - 80;
    self.leftLabel.height = 20;
    self.leftLabel.x = self.leftImageView.right + 5;
    self.leftLabel.centerY = self.leftImageView.centerY;
    
    self.leftButton.width = 200;
    self.leftButton.height = 40;
    self.leftButton.x = self.leftImageView.x;
    self.leftButton.y = self.leftLabel.bottom + 10;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.leftButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.leftButton.bounds;
    maskLayer.path = maskPath.CGPath;
    self.leftButton.backgroundColor = HEX_COLOR(0x6BD379);
    self.leftButton.layer.mask = maskLayer;
    
    self.rightImageView.width = 14;
    self.rightImageView.height = 14;
    self.rightImageView.right = self.width - 20;
    self.rightImageView.y = 20;
    
    self.rightLabel.width = self.width - 80;
    self.rightLabel.height = 20;
    self.rightLabel.right = self.rightImageView.x - 5;
    self.rightLabel.centerY = self.rightImageView.centerY;
    
    self.rightButton.width = 200;
    self.rightButton.height = 40;
    self.rightButton.right = self.rightImageView.right;
    self.rightButton.y = self.rightLabel.bottom + 10;
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.rightButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = self.rightButton.bounds;
    maskLayer1.path = maskPath1.CGPath;
    self.rightButton.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    self.rightButton.layer.mask = maskLayer1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorChatFootViewFrame];
}

@end
