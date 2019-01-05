//
//  MOLRegistViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLRegistViewController.h"
#import "MOLRegistView.h"
#import "MOLPhoneRegistViewModel.h"
#import "MOLHead.h"
#import "MOLInfoCheckViewController.h"

@interface MOLRegistViewController ()<YYTextKeyboardObserver>
@property (nonatomic, weak) MOLRegistView *phoneRegistView;
@property (nonatomic, strong) MOLPhoneRegistViewModel *phoneRegistViewModel;
@end

@implementation MOLRegistViewController
- (void)dealloc
{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneRegistViewModel = [[MOLPhoneRegistViewModel alloc] init];
    self.phoneRegistViewModel.phoneNumber = self.phoneNumber;
    [self setupRegistViewControllerUI];
    [self bindingPhoneRegistViewModel];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"button"] = self.phoneRegistView.sendCodeButton;
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"phone"] = [self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    para[@"functionType"] = @(0);
    dic[@"para"] = para;
    [self.phoneRegistViewModel.codeCommand execute:dic];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition
{
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        ///用此方法获取键盘的rect
        CGRect kbFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        ///从新计算view的位置并赋值
        if (kbFrame.origin.y < self.view.height) {
            self.phoneRegistView.y = 300 + MOL_StatusBarAndNavigationBarHeight - kbFrame.origin.y > 0 ? -(300 + MOL_StatusBarAndNavigationBarHeight - kbFrame.origin.y) : 0;
        }else{
            self.phoneRegistView.y = 0;
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 按钮的点击
- (void)registGoOn
{
    if (self.registType == 0) {
        [self.phoneRegistViewModel.continueCommand execute:nil];
    }else{
        [self.phoneRegistViewModel.continue_GoBindingCommand execute:nil];
    }
}

#pragma mark - viewModel
- (void)bindingPhoneRegistViewModel
{
    @weakify(self);
    RAC(self.phoneRegistViewModel,codeString) = self.phoneRegistView.codeTextField.rac_textSignal;
    RAC(self.phoneRegistViewModel,pwdString) = self.phoneRegistView.pwdTextField.rac_textSignal;
    RAC(self.phoneRegistViewModel,againPwdString) = self.phoneRegistView.againPwdTextField.rac_textSignal;
    RAC(self.navigationItem.rightBarButtonItem,enabled) = self.phoneRegistViewModel.continueSignal;
    RAC(self.phoneRegistView.sendCodeButton,enabled) = self.phoneRegistViewModel.canSendCodeSignal;
    
    // 发送验证码的执行
    [[self.phoneRegistView.sendCodeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"button"] = self.phoneRegistView.sendCodeButton;
        NSMutableDictionary *para = [NSMutableDictionary dictionary];
        para[@"phone"] = [self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
        para[@"functionType"] = @(0);
        dic[@"para"] = para;
        
        [self.phoneRegistViewModel.codeCommand execute:dic];
    }];
    
    // 点击继续后的信号监听
    [self.phoneRegistViewModel.continueCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);

        MOLUserModel *user = (MOLUserModel *)x;
        if (user.code == MOL_SUCCESS_REQUEST) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:NO];
            });
            
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
            [[MOLUserManager shareUserManager] user_saveLoginWithStatus:YES];
        }
    }];
    
    // 点击继续后设置密码的信号监听
    [self.phoneRegistViewModel.continue_GoBindingCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        
        MOLUserModel *user = (MOLUserModel *)x;
        if (user.code == MOL_SUCCESS_REQUEST) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
//                [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:NO];
            });
            
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
            [[MOLUserManager shareUserManager] user_saveLoginWithStatus:YES];
        }
    }];
}

#pragma mark - UI
- (void)setupRegistViewControllerUI
{
    MOLRegistView *phoneRegistView = [[MOLRegistView alloc] init];
    _phoneRegistView = phoneRegistView;
//    phoneRegistView.registType = self.registType;
    phoneRegistView.phoneNum = self.phoneNumber;
    [self.view addSubview:phoneRegistView];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"完成" targat:self action:@selector(registGoOn)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self calculatorRegistViewControllerFrame];
}

- (void)calculatorRegistViewControllerFrame
{
    self.phoneRegistView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    [self calculatorRegistViewControllerFrame];
}
@end
