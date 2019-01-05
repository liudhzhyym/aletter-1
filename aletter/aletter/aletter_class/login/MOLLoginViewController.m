//
//  MOLLoginViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLLoginViewController.h"
#import "MOLLoginView.h"
#import "MOLPhoneLoginViewModel.h"

@interface MOLLoginViewController ()
@property (nonatomic, strong) MOLPhoneLoginViewModel *phoneLoginViewModel;
@property (nonatomic, weak) MOLLoginView *phoneLoginView;
@end

@implementation MOLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneLoginViewModel = [[MOLPhoneLoginViewModel alloc] init];
    [self setupLoginViewControllerUI];
    [self bindingPhoneLoginViewModel];
    
}

#pragma mark - viewModel
- (void)bindingPhoneLoginViewModel
{
    @weakify(self);
    RAC(self.phoneLoginViewModel,pwdString) = self.phoneLoginView.pwdTextField.rac_textSignal;
    RAC(self.navigationItem.rightBarButtonItem,enabled) = self.phoneLoginViewModel.canContinueSignal;

    [self.phoneLoginViewModel.continueCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        MOLUserModel *user = (MOLUserModel *)x;
        
        if (user.code == MOL_SUCCESS_REQUEST || user.code == 20000) {        

            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
            
            [self.phoneLoginViewModel.getLastNameCommand execute:nil];
            // 保存用户信息以及登录状态
            [[MOLUserManager shareUserManager] user_saveUserInfoWithModel:user];
            [[MOLUserManager shareUserManager] user_saveLoginWithStatus:YES];
        }
    }];
}

#pragma mark - 按钮的点击
- (void)loginGoOn
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"phone"] = [self.phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
    dic[@"password"] = [self.phoneLoginView.pwdTextField.text mol_md5WithOrigin];
    dic[@"loginType"] = @"0";
    [self.phoneLoginViewModel.continueCommand execute:dic];
}

#pragma mark - UI
- (void)setupLoginViewControllerUI
{
    MOLLoginView *phoneLoginView = [[MOLLoginView alloc] init];
    _phoneLoginView = phoneLoginView;
    [self.view addSubview:phoneLoginView];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"完成" targat:self action:@selector(loginGoOn)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)calculatorLoginViewControllerFrame
{
    self.phoneLoginView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorLoginViewControllerFrame];
}
@end
