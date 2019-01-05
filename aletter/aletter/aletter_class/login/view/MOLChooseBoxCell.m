//
//  MOLChooseBoxCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChooseBoxCell.h"
#import "MOLHead.h"
#import "MOLMailCardView.h"
#import <UIImageView+WebCache.h>

@interface MOLChooseBoxCell ()<UITextFieldDelegate>
@property (nonatomic, weak) UIImageView *leftImageView;
@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UILabel *levelLabel;

@property (nonatomic, weak) UIView *blackView;
@property (nonatomic, weak) UIImageView *middleBackImageView;
//@property (nonatomic, weak) UIImageView *middleImageView;
@property (nonatomic, weak) UILabel *middleLabel;

@property (nonatomic, weak) UIImageView *rightImageView;
@property (nonatomic, weak) UILabel *rightLabel;

@property (nonatomic, weak) UITextField *rightTextView;

@property (nonatomic, weak) UIButton *rightChooseButton;

@property (nonatomic, weak) MOLMailCardView *cardView;  // 卡片 （自定义控件）
@end

@implementation MOLChooseBoxCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChooseBoxCellUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (!name.length) {
        [MOLToast toast_showWithWarning:YES title:@"不能输入空格"];
        return YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(chooseBoxCell_shouldReturnWithName:)]) {
        [self.delegate chooseBoxCell_shouldReturnWithName:name];
    }
    return YES;
}

#pragma mark - publish
- (void)chooseBoxCell_keyBoardShow:(BOOL)show
{
    if (self.rightTextView.hidden == YES) {
        return;
    }
    if (show) {
       [self.rightTextView becomeFirstResponder];
    }else{
        [self.rightTextView resignFirstResponder];
    }
}

#pragma mark - 按钮点击
- (void)textField_valueChange:(UITextField *)textF
{
    self.rightLabel.text = textF.text;
    self.boxModel.rightTitle = textF.text;
}

#pragma mark - 赋值
- (void)setBoxModel:(MOLChooseBoxModel *)boxModel
{
    _boxModel = boxModel;
    
    if (boxModel.modelType == MOLChooseBoxModelType_leftText) {
        
        self.leftImageView.hidden = NO;
        self.leftLabel.hidden = NO;
//        self.middleImageView.hidden = YES;
        self.middleBackImageView.hidden = YES;
        self.middleLabel.hidden = YES;
        self.blackView.hidden = YES;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = YES;
        self.leftLabel.text = boxModel.leftTitle;
        if (boxModel.leftHighLight) {
            self.leftLabel.textColor = HEX_COLOR(0xffffff);
        }else{
            self.leftLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
        }
        self.leftImageView.image = [UIImage imageNamed:boxModel.leftImageString];
        
        if (boxModel.leftLevelTitle.length) {
            self.levelLabel.text = boxModel.leftLevelTitle;
            self.levelLabel.hidden = NO;
        }else{
            self.levelLabel.hidden = YES;
        }
        self.levelLabel.x = self.leftLabel.x + [boxModel.leftTitle sizeWithAttributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)}].width + 5;
        
    }else if (boxModel.modelType == MOLChooseBoxModelType_middleImage){
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
        self.middleBackImageView.hidden = NO;
        self.middleLabel.hidden = NO;
        self.blackView.hidden = NO;
//        self.middleImageView.hidden = NO;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = YES;
        
        [self.middleBackImageView sd_setImageWithURL:[NSURL URLWithString:boxModel.middleImageString]];
        self.middleLabel.text = boxModel.middleTitle;
        
    }else if (boxModel.modelType == MOLChooseBoxModelType_middleEnvelopeImage)
    {
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
        self.middleBackImageView.hidden = NO;
        self.middleLabel.hidden = NO;
        self.blackView.hidden = NO;
        //        self.middleImageView.hidden = NO;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = YES;
        
        [self.middleBackImageView setImage:[UIImage imageNamed:boxModel.middleImageString]];
        self.middleLabel.text = boxModel.middleTitle;
        
        if (boxModel.middleEnvelopeImageHighLight) {
            self.blackView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0);
        }else{
            self.blackView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.2);
        }
    }
    else if (boxModel.modelType == MOLChooseBoxModelType_rightText){
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
//        self.middleImageView.hidden = YES;
        self.middleBackImageView.hidden = YES;
        self.middleLabel.hidden = YES;
        self.blackView.hidden = YES;
        self.rightImageView.hidden = NO;
        self.rightLabel.hidden = NO;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = YES;
        
        self.rightLabel.text = boxModel.rightTitle;
        self.rightImageView.image = [UIImage imageNamed:boxModel.rightImageString];
        if (boxModel.rightHighLight) {
            self.rightLabel.textColor = HEX_COLOR(0xffffff);
        }else{
            self.rightLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
        }
        
    }else if (boxModel.modelType == MOLChooseBoxModelType_rightTextView){
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
//        self.middleImageView.hidden = YES;
        self.middleBackImageView.hidden = YES;
        self.middleLabel.hidden = YES;
        self.blackView.hidden = YES;
        self.rightImageView.hidden = NO;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = NO;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = YES;

        self.rightImageView.image = [UIImage imageNamed:boxModel.rightImageString];
        
        self.rightTextView.text = boxModel.rightTitle;
        
    }else if (boxModel.modelType == MOLChooseBoxModelType_rightChooseButton){
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
//        self.middleImageView.hidden = YES;
        self.middleBackImageView.hidden = YES;
        self.middleLabel.hidden = YES;
        self.blackView.hidden = YES;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = NO;
        self.cardView.hidden = YES;
        
        [self.rightChooseButton setTitle:boxModel.buttonTitle forState:UIControlStateNormal];
        
    }else if (boxModel.modelType == MOLChooseBoxModelType_card){
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
//        self.middleImageView.hidden = YES;
        self.middleBackImageView.hidden = YES;
        self.middleLabel.hidden = YES;
        self.blackView.hidden = YES;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = NO;
        
        self.cardView.cardModel = boxModel.cardModel;
        
        CGSize maxS = CGSizeMake(MOL_SCREEN_WIDTH - 40 - 34 - 20, MAXFLOAT);
        CGFloat h = [self.boxModel.cardModel.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)} context:nil].size.height;
        self.cardView.height = self.boxModel.cardModel.cardType == 2 ? (h+55) : (120);
        
    }else{
        self.leftImageView.hidden = YES;
        self.leftLabel.hidden = YES;
        self.levelLabel.hidden = YES;
        self.middleBackImageView.hidden = YES;
        self.middleLabel.hidden = YES;
        self.blackView.hidden = YES;
//        self.middleImageView.hidden = YES;
        self.rightImageView.hidden = YES;
        self.rightLabel.hidden = YES;
        self.rightTextView.hidden = YES;
        self.rightChooseButton.hidden = YES;
        self.cardView.hidden = YES;
    }
}

#pragma mark - UI
- (void)setupChooseBoxCellUI
{
    UIImageView *leftImageView = [[UIImageView alloc] init];
    _leftImageView = leftImageView;
    [self.contentView addSubview:leftImageView];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    _leftLabel = leftLabel;
    leftLabel.text = @" ";
    leftLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    leftLabel.font = MOL_LIGHT_FONT(14);
    leftLabel.numberOfLines = 0;
    [self.contentView addSubview:leftLabel];
    
    UILabel *levelLabel = [[UILabel alloc] init];
    _levelLabel = levelLabel;
    levelLabel.text = @"Lv1";
    levelLabel.textColor = HEX_COLOR(0xFED434);
    levelLabel.font = MOL_LIGHT_FONT(14);
    [self.contentView addSubview:levelLabel];
    
    UIImageView *middleBackImageView = [[UIImageView alloc] init];//WithImage:[UIImage imageNamed:@"home_stamp_1"]];
    _middleBackImageView = middleBackImageView;
    [self.contentView addSubview:middleBackImageView];
    
//    UIImageView *middleImageView = [[UIImageView alloc] init];
//    _middleImageView = middleImageView;
//    [middleBackImageView addSubview:middleImageView];
    
    UILabel *middleLabel = [[UILabel alloc] init];
    _middleLabel = middleLabel;
    middleLabel.text = @" ";
    middleLabel.textColor = HEX_COLOR(0x3A384D);
    middleLabel.font = MOL_LIGHT_FONT(14);
    middleLabel.textAlignment = NSTextAlignmentCenter;
    [middleBackImageView addSubview:middleLabel];
    
    UIView *blackView = [[UIView alloc] init];
    _blackView = blackView;
    blackView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.2);
    [middleBackImageView addSubview:blackView];
    
    UIImageView *rightImageView = [[UIImageView alloc] init];
    _rightImageView = rightImageView;
    [self.contentView addSubview:rightImageView];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    _rightLabel = rightLabel;
    rightLabel.text = @" ";
    rightLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    rightLabel.font = MOL_LIGHT_FONT(14);
    rightLabel.numberOfLines = 0;
    rightLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:rightLabel];
    
    UITextField *rightTextView = [[UITextField alloc] init];
    _rightTextView = rightTextView;
    rightTextView.textAlignment = NSTextAlignmentRight;
    [rightTextView addTarget:self action:@selector(textField_valueChange:) forControlEvents:UIControlEventEditingChanged];
    rightTextView.backgroundColor = [UIColor clearColor];
    rightTextView.returnKeyType = UIReturnKeyDone;
    rightTextView.delegate = self;
    rightTextView.enablesReturnKeyAutomatically = YES;
    rightTextView.textColor = HEX_COLOR(0xffffff);
    rightTextView.font = MOL_LIGHT_FONT(14);
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"起个名字吧" attributes:@{NSForegroundColorAttributeName : HEX_COLOR_ALPHA(0xffffff, 0.6)}];
    [rightTextView setAttributedPlaceholder:att];
    [self.contentView addSubview:rightTextView];
    
    UIButton *rightChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightChooseButton = rightChooseButton;
    [rightChooseButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    rightChooseButton.titleLabel.font = MOL_MEDIUM_FONT(14);
    rightChooseButton.backgroundColor = HEX_COLOR(0x284D6B);
    rightChooseButton.userInteractionEnabled = NO;
    [self.contentView addSubview:rightChooseButton];
    
    MOLMailCardView *cardView = [[MOLMailCardView alloc] initMailCardViewWithType:0];
    _cardView = cardView;
    [self.contentView addSubview:cardView];
}

- (void)calculatorChooseBoxCellFrame
{
    self.leftImageView.width = 14;
    self.leftImageView.height = self.leftImageView.width;
    self.leftImageView.x = 20;
    self.leftImageView.y = 3;
    
    self.leftLabel.x = self.leftImageView.right + 5;
    self.leftLabel.y = self.leftImageView.y - 3;
    self.leftLabel.width = self.contentView.width - self.leftLabel.x - 28;
    [self.leftLabel sizeToFit];
    self.leftLabel.width = self.contentView.width - self.leftLabel.x - 28;
    
    self.levelLabel.width = 40;
    self.levelLabel.height = 20;
    self.levelLabel.x = self.leftLabel.x + [self.boxModel.leftTitle sizeWithAttributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)}].width + 5;
    self.leftLabel.centerY = self.leftLabel.centerY;
    
    self.middleBackImageView.width = 80;
    self.middleBackImageView.height = 105;
    self.middleBackImageView.centerX = self.contentView.width * 0.5;
    self.middleBackImageView.centerY = self.contentView.height * 0.5 - 7;
    
//    self.middleImageView.width = 70;
//    self.middleImageView.height = self.middleImageView.width;
//    self.middleImageView.centerX = self.middleBackImageView.width * 0.5;
//    self.middleImageView.y = 7;
    
    
    self.middleLabel.height = 20;
//    self.middleLabel.y = self.middleImageView.bottom + 3;
    self.middleLabel.bottom = self.middleBackImageView.height - 3;
    
    if (self.boxModel.modelType == MOLChooseBoxModelType_middleEnvelopeImage){//新需求-信封
        self.middleBackImageView.width = 100;
        self.middleBackImageView.height = 70;
        self.middleBackImageView.y = 10;
        self.middleLabel.y =(self.middleBackImageView.height-self.middleLabel.height)/2.0;
//        [self.contentView setBackgroundColor: [UIColor redColor]];
//        NSLog(@"self.contentView.height %lf",self.contentView.height);
    }
    
    self.middleLabel.width = self.middleBackImageView.width;
    
    self.blackView.frame = self.middleBackImageView.bounds;
    
    
    
    self.rightImageView.width = 14;
    self.rightImageView.height = self.leftImageView.width;
    self.rightImageView.x = self.contentView.width - self.rightImageView.width - 20;
    self.rightImageView.y = 3;
    
    self.rightLabel.width = self.contentView.width - 20 - self.rightImageView.width - 28;
    [self.rightLabel sizeToFit];
    self.rightLabel.width = self.contentView.width - 20 - self.rightImageView.width - 28;
    self.rightLabel.right = self.rightImageView.x - 6;
    self.rightLabel.y = self.rightImageView.y - 3;
    
    self.rightTextView.width = self.contentView.width - 20 - self.rightImageView.width - 28;
    self.rightTextView.height = 30;
    self.rightTextView.right = self.rightLabel.right+2;
    self.rightTextView.centerY = self.rightLabel.centerY;
    
    self.rightChooseButton.width = 256;
    self.rightChooseButton.height = 39;
    self.rightChooseButton.x = self.contentView.width - self.rightChooseButton.width - 20;
    self.rightChooseButton.y = 1;
   
    self.cardView.width = MOL_SCREEN_WIDTH - 40;
//    self.cardView.height = 120;
    self.cardView.x = 20;
    self.cardView.layer.cornerRadius = 12;
    self.cardView.clipsToBounds = YES;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorChooseBoxCellFrame];
}


- (void)chooseBoxCell_drawRadius:(NSInteger)radiusCount backgroundColor:(UIColor *)color
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (radiusCount == 0) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.rightChooseButton.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(0, 0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.rightChooseButton.bounds;
        maskLayer.path = maskPath.CGPath;
        self.rightChooseButton.backgroundColor = color ? color : HEX_COLOR(0x284D6B);
        self.rightChooseButton.layer.mask = maskLayer;
    }else if (radiusCount == 1) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.rightChooseButton.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.rightChooseButton.bounds;
        maskLayer.path = maskPath.CGPath;
        self.rightChooseButton.backgroundColor = color ? color : HEX_COLOR(0x284D6B);
        self.rightChooseButton.layer.mask = maskLayer;
    }else{
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.rightChooseButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.rightChooseButton.bounds;
        maskLayer.path = maskPath.CGPath;
        self.rightChooseButton.backgroundColor = color ? color : HEX_COLOR(0x284D6B);
        self.rightChooseButton.layer.mask = maskLayer;
    }
    
}

- (void)dealloc
{
    [self.rightTextView resignFirstResponder];
}
@end
