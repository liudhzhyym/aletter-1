//
//  MOLBindingCodeView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBindingCodeView.h"
#import "MOLHead.h"

@interface MOLBindingCodeView ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;

@property (nonatomic, weak) UIView *lineView;
@end

@implementation MOLBindingCodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBindingCodeViewUI];
    }
    return self;
}

#pragma mark - 赋值
- (void)setPhoneString:(NSString *)phoneString
{
    _phoneString = phoneString;
    self.subTitleLabel.text = [NSString stringWithFormat:@"验证码已发送至%@",phoneString];
    [self.subTitleLabel sizeToFit];
}

#pragma mark - UI
- (void)setupBindingCodeViewUI
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"输入验证码";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_MEDIUM_FONT(26);
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel = subTitleLabel;
    subTitleLabel.text = @" ";
    subTitleLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    subTitleLabel.font = MOL_REGULAR_FONT(14);
    [self addSubview:subTitleLabel];
    
    UIButton *sendCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendCodeButton = sendCodeButton;
    sendCodeButton.enabled = NO;
    [sendCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
    [sendCodeButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    [sendCodeButton setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.6) forState:UIControlStateDisabled];
    sendCodeButton.titleLabel.font = MOL_REGULAR_FONT(16);
    sendCodeButton.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    [self addSubview:sendCodeButton];
    
    UITextField *pwdTextField = [[UITextField alloc] init];
    _codeTextField = pwdTextField;
    pwdTextField.font = MOL_REGULAR_FONT(14);
    pwdTextField.textColor = HEX_COLOR(0xffffff);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:
                                      @{NSForegroundColorAttributeName:HEX_COLOR_ALPHA(0xffffff, 0.6),NSFontAttributeName:pwdTextField.font}];
    pwdTextField.attributedPlaceholder = attrString;
    [pwdTextField becomeFirstResponder];
    [self addSubview:pwdTextField];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    [self addSubview:lineView];
}

- (void)calculatorBindingCodeViewFrame
{
    [self.titleLabel sizeToFit];
    self.titleLabel.x = 20;
    self.titleLabel.y = 32;// + MOL_StatusBarAndNavigationBarHeight;
    
    [self.subTitleLabel sizeToFit];
    self.subTitleLabel.width = self.width - 40;
    self.subTitleLabel.x = self.titleLabel.x;
    self.subTitleLabel.y = self.titleLabel.bottom + 10;
    
    [self.sendCodeButton sizeToFit];
    self.sendCodeButton.width += 32;
    self.sendCodeButton.height = 25;
    self.sendCodeButton.layer.cornerRadius = self.sendCodeButton.height * 0.5;
    self.sendCodeButton.layer.masksToBounds = YES;
    
    self.codeTextField.width = self.width - 40 - self.sendCodeButton.width;
    self.codeTextField.height = 30;
    self.codeTextField.x = self.titleLabel.x;
    self.codeTextField.y = self.subTitleLabel.bottom + 40;
    
    self.sendCodeButton.centerY = self.codeTextField.centerY;
    self.sendCodeButton.x = self.codeTextField.right;
    
    self.lineView.width = self.width - 40;
    self.lineView.height = 1;
    self.lineView.x = self.codeTextField.x;
    self.lineView.y = self.codeTextField.bottom + 10;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorBindingCodeViewFrame];
}
@end
