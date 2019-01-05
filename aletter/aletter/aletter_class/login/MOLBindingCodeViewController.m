//
//  MOLBindingCodeViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBindingCodeViewController.h"
#import "MOLHead.h"
#import "MOLBindingCodeView.h"
#import "MOLCodeViewModel.h"

@interface MOLBindingCodeViewController ()
@property (nonatomic, strong) MOLCodeViewModel *codeViewModel;
@property (nonatomic, weak) MOLBindingCodeView *codeView;
@end

@implementation MOLBindingCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bindingType = self.bindingType == 0 ? 1 : self.bindingType;
    self.codeViewModel = [[MOLCodeViewModel alloc] init];
    [self setupBindingCodeViewControllerUI];
    [self bindingCodeViewModel];
    
    // 发送验证码
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"button"] = self.codeView.sendCodeButton;
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"phone"] = [self.phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
    para[@"functionType"] = @(2);
    dic[@"para"] = para;
    [self.codeViewModel.codeCommand execute:dic];
}

#pragma mark - 按钮的点击
- (void)registGoOn
{
    if (self.bindingType == 1) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"accessToken"] = MOLUserManagerInstance.platToken;
        dic[@"registerUID"] = MOLUserManagerInstance.platUid;
        dic[@"registerType"] = @(MOLUserManagerInstance.platType);
        if (MOLUserManagerInstance.platOpenid.length) {
            dic[@"openid"] = MOLUserManagerInstance.platOpenid;
        }
        dic[@"phone"] = [self.phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        dic[@"phoneCode"] = self.codeViewModel.codeString;
        dic[@"channel"] = MOL_APPStore;
        [self.codeViewModel.continueCommand execute:dic];
    }else if (self.bindingType == 2){
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"phone"] = [self.phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        dic[@"phoneCode"] = self.codeViewModel.codeString;
        dic[@"type"] = @(1);
        dic[@"userId"] = MOLUserManagerInstance.platUserId;
        [self.codeViewModel.continue_GoBindingCommand execute:dic];
    }else{
        [MOLToast toast_showWithWarning:YES title:@"绑定手机异常"];
    }
}

#pragma mark - viewModel
- (void)bindingCodeViewModel
{
    @weakify(self);
    RAC(self.codeViewModel,codeString) = self.codeView.codeTextField.rac_textSignal;
    RAC(self.navigationItem.rightBarButtonItem,enabled) = self.codeViewModel.continueSignal;
    RAC(self.codeView.sendCodeButton,enabled) = self.codeViewModel.canSendCodeSignal;
    
    // 发送验证码的执行
    [[self.codeView.sendCodeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"button"] = self.codeView.sendCodeButton;
        NSMutableDictionary *para = [NSMutableDictionary dictionary];
        para[@"phone"] = [self.phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
        para[@"functionType"] = @(2);
        dic[@"para"] = para;
        [self.codeViewModel.codeCommand execute:dic];
    }];
    
    // 点击继续后的信号监听
    [self.codeViewModel.continueCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        
        MOLUserModel *user = (MOLUserModel *)x;
        if (user.code == MOL_SUCCESS_REQUEST) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                
                // 判断是不是需要弹出信息
                if (user.sex <= 0) {
                    [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:NO];
                }
            });
            
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
            [[MOLUserManager shareUserManager] user_saveLoginWithStatus:YES];
        }
    }];
    
    // 绑定手机
    [self.codeViewModel.continue_GoBindingCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        
        MOLUserModel *user = (MOLUserModel *)x;
        if (user.code == MOL_SUCCESS_REQUEST) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
                
                // 判断是不是需要弹出信息
                if (user.sex <= 0) {
                    [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:NO];
                }
            });
            
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
            [[MOLUserManager shareUserManager] user_saveLoginWithStatus:YES];
        }
    }];
}

#pragma mark - UI
- (void)setupBindingCodeViewControllerUI
{
    MOLBindingCodeView *codeView = [[MOLBindingCodeView alloc] init];
    _codeView = codeView;
    codeView.phoneString = self.phoneString;
    [self.view addSubview:codeView];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"完成" targat:self action:@selector(registGoOn)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)calculatorBindingCodeViewControllerFrame
{
    self.codeView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorBindingCodeViewControllerFrame];
}
@end
