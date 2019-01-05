//
//  MOLRegistView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLRegistView.h"

@interface MOLRegistView ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;

@property (nonatomic, weak) UIView *lineView1;
@property (nonatomic, weak) UIView *lineView2;
@property (nonatomic, weak) UIView *lineView3;

@end
@implementation MOLRegistView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRegistViewUI];
    }
    return self;
}

- (void)setRegistType:(NSInteger)registType
{
    _registType = registType;
    if (registType == 0) {
        self.titleLabel.text = @"手机注册";
        self.subTitleLabel.text = @"未经注册过的手机号将自动创建有封信账号";
        [self.subTitleLabel sizeToFit];
    }else{
        self.titleLabel.text = @"设置密码";
        self.subTitleLabel.text = @"系统检测你还未设置密码,完成设置后将自动登录";
        [self.subTitleLabel sizeToFit];
    }
}

- (void)setPhoneNum:(NSString *)phoneNum
{
    _phoneNum = phoneNum;
    self.subTitleLabel.text = [NSString stringWithFormat:@"验证码已发送至%@",phoneNum];
    [self.subTitleLabel sizeToFit];
}

#pragma mark - UI
- (void)setupRegistViewUI
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"设置登录密码";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_MEDIUM_FONT(26);
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel = subTitleLabel;
    subTitleLabel.text = @"未经注册过的手机号将自动创建有封信账号";
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
    
    UITextField *codeTextField = [[UITextField alloc] init];
    _codeTextField = codeTextField;
    codeTextField.font = MOL_REGULAR_FONT(14);
    codeTextField.textColor = HEX_COLOR(0xffffff);
    NSAttributedString *attrString_code = [[NSAttributedString alloc] initWithString:@"验证码" attributes:
                                      @{NSForegroundColorAttributeName:HEX_COLOR_ALPHA(0xffffff, 0.6),NSFontAttributeName:codeTextField.font}];
    codeTextField.attributedPlaceholder = attrString_code;
//    [codeTextField becomeFirstResponder];
    [self addSubview:codeTextField];
    
    UIView *lineView1 = [[UIView alloc] init];
    _lineView1 = lineView1;
    lineView1.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    [self addSubview:lineView1];
    
    UITextField *pwdTextField = [[UITextField alloc] init];
    _pwdTextField = pwdTextField;
    pwdTextField.font = MOL_REGULAR_FONT(14);
    pwdTextField.textColor = HEX_COLOR(0xffffff);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:
                                      @{NSForegroundColorAttributeName:HEX_COLOR_ALPHA(0xffffff, 0.6),NSFontAttributeName:pwdTextField.font}];
    pwdTextField.attributedPlaceholder = attrString;
    
    pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [[pwdTextField valueForKey:@"_clearButton"] setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
    pwdTextField.secureTextEntry = YES;
    [self addSubview:pwdTextField];
    
    UIView *lineView2 = [[UIView alloc] init];
    _lineView2 = lineView2;
    lineView2.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    [self addSubview:lineView2];
    
    UITextField *againPwdTextField = [[UITextField alloc] init];
    _againPwdTextField = againPwdTextField;
    againPwdTextField.font = MOL_REGULAR_FONT(14);
    againPwdTextField.textColor = HEX_COLOR(0xffffff);
    NSAttributedString *attrString_again = [[NSAttributedString alloc] initWithString:@"再次输入密码" attributes:
                                      @{NSForegroundColorAttributeName:HEX_COLOR_ALPHA(0xffffff, 0.6),NSFontAttributeName:againPwdTextField.font}];
    againPwdTextField.attributedPlaceholder = attrString_again;
    againPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [[againPwdTextField valueForKey:@"_clearButton"] setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
    againPwdTextField.secureTextEntry = YES;
    [self addSubview:againPwdTextField];
    
    UIView *lineView3 = [[UIView alloc] init];
    _lineView3 = lineView3;
    lineView3.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    [self addSubview:lineView3];
}

- (void)calculatorRegistViewFrame
{
    [self.titleLabel sizeToFit];
    self.titleLabel.x = 20;
    self.titleLabel.y = 32;// + MOL_StatusBarAndNavigationBarHeight;
    
    [self.subTitleLabel sizeToFit];
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
    
    self.lineView1.width = self.width - 40;
    self.lineView1.height = 1;
    self.lineView1.x = self.codeTextField.x;
    self.lineView1.y = self.codeTextField.bottom + 10;
    
    self.pwdTextField.width = self.width - 40;
    self.pwdTextField.height = self.codeTextField.height;
    self.pwdTextField.x = self.codeTextField.x;
    self.pwdTextField.y = self.lineView1.bottom + 15;
    
    self.lineView2.width = self.pwdTextField.width;
    self.lineView2.height = 1;
    self.lineView2.x = self.pwdTextField.x;
    self.lineView2.y = self.pwdTextField.bottom + 10;
    
    self.againPwdTextField.width = self.pwdTextField.width;
    self.againPwdTextField.height = self.pwdTextField.height;
    self.againPwdTextField.x = self.codeTextField.x;
    self.againPwdTextField.y = self.lineView2.bottom + 15;
    
    self.lineView3.width = self.againPwdTextField.width;
    self.lineView3.height = 1;
    self.lineView3.x = self.againPwdTextField.x;
    self.lineView3.y = self.againPwdTextField.bottom + 10;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorRegistViewFrame];
}
@end
