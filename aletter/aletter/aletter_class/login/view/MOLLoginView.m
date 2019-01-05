//
//  MOLLoginView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLLoginView.h"

@interface MOLLoginView ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;

@property (nonatomic, weak) UIView *lineView;
@end

@implementation MOLLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPhoneInputViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupPhoneInputViewUI
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"输入密码";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_MEDIUM_FONT(26);
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel = subTitleLabel;
//    subTitleLabel.text = @"未经注册过的手机号将自动创建有封信账号";
    subTitleLabel.text = @" ";
    subTitleLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    subTitleLabel.font = MOL_REGULAR_FONT(14);
    [self addSubview:subTitleLabel];
    
    UITextField *pwdTextField = [[UITextField alloc] init];
    _pwdTextField = pwdTextField;
    pwdTextField.font = MOL_REGULAR_FONT(14);
    pwdTextField.textColor = HEX_COLOR(0xffffff);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:
                                      @{NSForegroundColorAttributeName:HEX_COLOR_ALPHA(0xffffff, 0.6),NSFontAttributeName:pwdTextField.font}];
    pwdTextField.attributedPlaceholder = attrString;
    [pwdTextField becomeFirstResponder];
    pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [[pwdTextField valueForKey:@"_clearButton"] setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
    pwdTextField.secureTextEntry = YES;
    [self addSubview:pwdTextField];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    [self addSubview:lineView];
}

- (void)calculatorPhoneInputViewFrame
{
    [self.titleLabel sizeToFit];
    self.titleLabel.x = 20;
    self.titleLabel.y = 32;// + MOL_StatusBarAndNavigationBarHeight;
    
    [self.subTitleLabel sizeToFit];
    self.subTitleLabel.x = self.titleLabel.x;
    self.subTitleLabel.y = self.titleLabel.bottom + 10;
    
    self.pwdTextField.width = self.width - 40;
    self.pwdTextField.height = 30;
    self.pwdTextField.x = self.titleLabel.x;
    self.pwdTextField.y = self.subTitleLabel.bottom + 40;
    
    self.lineView.width = self.pwdTextField.width;
    self.lineView.height = 1;
    self.lineView.x = self.pwdTextField.x;
    self.lineView.y = self.pwdTextField.bottom + 10;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorPhoneInputViewFrame];
}
@end
