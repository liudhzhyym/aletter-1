//
//  MOLPhoneInputViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPhoneInputViewController.h"
#import "MOLHead.h"

#import "MOLPhoneInputView.h"
#import "MOLPhoneInputViewModel.h"

#import "MOLLoginViewController.h"
#import "MOLRegistViewController.h"
#import "MOLBindingCodeViewController.h"

@interface MOLPhoneInputViewController ()
@property (nonatomic, weak) MOLPhoneInputView *phoneInputView;
@property (nonatomic, strong) MOLPhoneInputViewModel *phoneInputViewModel;

@end

@implementation MOLPhoneInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 绑定viewModel
    self.phoneInputViewModel = [[MOLPhoneInputViewModel alloc] init];
    [self setupPhoneInputViewControllerUI];
    [self bindingphoneInputViewModel];
}

#pragma mark - 按钮点击
- (void)loginGoOn
{
    BOOL sameNum = [self.phoneInputView.frontPhoneNum isEqualToString:self.phoneInputView.phoneTextField.text];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"phone"] = [self.phoneInputView.phoneTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    para[@"functionType"] = self.type == 0 ? @"0" : @"2";
    dic[@"same"] = @(sameNum);
    dic[@"para"] = para;
    [self.phoneInputViewModel.continueCommand execute:dic];
    self.phoneInputView.frontPhoneNum = self.phoneInputView.phoneTextField.text;
}

#pragma mark - viewModel
- (void)bindingphoneInputViewModel
{
    @weakify(self);
    RAC(self.phoneInputViewModel,phoneNumber) = self.phoneInputView.phoneTextField.rac_textSignal;
    RAC(self.navigationItem.rightBarButtonItem,enabled) = self.phoneInputViewModel.canContinueSignal;
    [self.phoneInputViewModel.continueCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        // 登录成功与否
        @strongify(self);
        if (self.type == 0) {
            if ([x integerValue] == MOL_SUCCESS_REQUEST) {
                MOLRegistViewController *vc = [[MOLRegistViewController alloc] init];
                vc.registType = 0;
                vc.phoneNumber = self.phoneInputViewModel.phoneNumber;
                [self.navigationController pushViewController:vc animated:YES];
            }else if([x integerValue] == 20007){
                MOLLoginViewController *vc = [[MOLLoginViewController alloc] init];
                vc.phoneString = self.phoneInputViewModel.phoneNumber;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([x integerValue] == 20025){
                // 设置密码
                MOLRegistViewController *vc = [[MOLRegistViewController alloc] init];
                vc.phoneNumber = self.phoneInputViewModel.phoneNumber;
                vc.registType = 1;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            if ([x integerValue] == MOL_SUCCESS_REQUEST) {
                // 绑定验证码界面
                MOLBindingCodeViewController *vc = [[MOLBindingCodeViewController alloc] init];
                vc.phoneString = self.phoneInputViewModel.phoneNumber;
                vc.bindingType = self.type;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        
    }];
}

#pragma mark - UI
- (void)setupPhoneInputViewControllerUI
{
    MOLPhoneInputView *phoneInputView = [[MOLPhoneInputView alloc] init];
    _phoneInputView = phoneInputView;
    phoneInputView.type = self.type;
    [self.view addSubview:phoneInputView];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"继续" targat:self action:@selector(loginGoOn)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)calculatorPhoneInputViewControllerFrame
{
    self.phoneInputView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorPhoneInputViewControllerFrame];
}
@end
