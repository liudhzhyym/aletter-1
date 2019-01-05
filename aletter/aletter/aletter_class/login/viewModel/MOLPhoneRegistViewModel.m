//
//  MOLPhoneRegistViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPhoneRegistViewModel.h"
#import "MOLLoginRequest.h"
#import "MOLHead.h"

@interface MOLPhoneRegistViewModel ()
@end

@implementation MOLPhoneRegistViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupPhoneRegistViewModel];
    }
    return self;
}

- (void)setupPhoneRegistViewModel
{
    @weakify(self);
    RACSignal *showTimeSignal = [RACObserve([MOLCodeTimerManager shareCodeTimerManager], showTime) map:^id(id value) {
        return @([value integerValue] == MOL_CODETIME);
    }];
    
    // 是否可以发送验证码的信号
    self.canSendCodeSignal = [RACSignal combineLatest:@[showTimeSignal] reduce:^id(NSNumber *num){
        return @(num.integerValue);
    }];
    
    RACSignal *pwdSignal = [RACObserve(self, pwdString) map:^id(id value) {
        
        return @([value length] > 0);
    }];
    
    RACSignal *againPwdSignal = [RACObserve(self, againPwdString) map:^id(id value) {
        
        return @([value length] > 0);
    }];
    
    RACSignal *codeSignal = [RACObserve(self, codeString) map:^id(id value) {
        
        return @([value length] >= 4);
    }];
    
    // 是否可以点击继续的信号
    self.continueSignal = [RACSignal combineLatest:@[codeSignal, pwdSignal, againPwdSignal] reduce:^id(NSNumber *code, NSNumber *pwd, NSNumber *againPwd){
        return @(code.integerValue && pwd.integerValue && againPwd.integerValue);
    }];
    
    // 发送验证码的命令
    self.codeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        NSDictionary *dic = (NSDictionary *)input;
        UIButton *btn = (UIButton *)dic[@"button"];
        NSDictionary *para = dic[@"para"];
        if ([MOLCodeTimerManager shareCodeTimerManager].showTime < MOL_CODETIME) {  // 直接倒计时（按钮不可点击）
            RACSignal *signal = [RACSignal empty];
            btn.enabled = NO;
            
            [[MOLCodeTimerManager shareCodeTimerManager] codeTimer_beginTimer:^(NSInteger sec) {
                if (sec == MOL_CODETIME) {
                    [btn setTitle:@"重新发送" forState:UIControlStateNormal];
                }else{
                    [btn setTitle:[NSString stringWithFormat:@"%lds",sec] forState:UIControlStateNormal];
                }
                [btn sizeToFit];
                btn.width += 32;
            }];
            
            return signal;
            
        }else{  // 按钮可以点击
            RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                [MBProgressHUD showMessage:nil];
                
                MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_getCodeWithParameter:para];
                
                [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                    [MBProgressHUD hideHUD];
                    
                    if (code == MOL_SUCCESS_REQUEST) {
                        
                        NSString *codeStr = [request.responseObject mol_jsonString:@"resBody"];
                        if (codeStr.length) {
                            [MOLToast toast_showWithWarning:NO title:[NSString stringWithFormat:@"短信验证码已发出【%@】",codeStr]];
                        }else{
                            [MOLToast toast_showWithWarning:NO title:@"短信验证码已发出"];
                        }
                        
                        [subscriber sendNext:@(MOL_CODETIME)];
                        [subscriber sendCompleted];
                        
                        // 开启倒计时 发送网络请求
                        [[MOLCodeTimerManager shareCodeTimerManager] codeTimer_beginTimer:^(NSInteger sec) {
                            
                            if (sec == MOL_CODETIME) {
                                [btn setTitle:@"重新发送" forState:UIControlStateNormal];
                            }else{
                                [btn setTitle:[NSString stringWithFormat:@"%lds",sec] forState:UIControlStateNormal];
                            }
                            [btn sizeToFit];
                            btn.width += 32;
                        }];
                    }else{
                        [MOLToast toast_showWithWarning:YES title:message];
                    }
                    
                } failure:^(__kindof MOLBaseNetRequest *request) {
                    [subscriber sendCompleted];
                    [MBProgressHUD hideHUD];
                }];
                return nil;
            }];
            return signal;
        }
    }];
    
    self.continueCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        if (!self.codeString.length) {
            [MOLToast toast_showWithWarning:YES title:@"验证码不能为空"];
            return [RACSignal empty];
        }
        
        if (![self.pwdString isEqualToString:self.againPwdString]) {
            [MOLToast toast_showWithWarning:YES title:@"两次密码不一致"];
            return [RACSignal empty];
        }
        
        if (self.pwdString.length < 6) {
            [MOLToast toast_showWithWarning:YES title:@"密码太短,请输入6-32位密码"];
            return [RACSignal empty];
        }
        
        if (self.pwdString.length > 32) {
            [MOLToast toast_showWithWarning:YES title:@"密码太长,请输入6-32位密码"];
            return [RACSignal empty];
        }
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            [MBProgressHUD showMessage:nil];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"registerType"] = @"0";
            dic[@"phone"] = [self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            dic[@"phoneCode"] = self.codeString;
            dic[@"password"] = [self.pwdString mol_md5WithOrigin];
            dic[@"channel"] = MOL_APPStore;
            MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_registWithParameter:dic];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                [MBProgressHUD hideHUD];
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
                
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
                
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendCompleted];
                [MBProgressHUD hideHUD];
            }];
            return nil;
        }];
        return signal;
    }];
    
    self.continue_GoBindingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        if (!self.codeString.length) {
            [MOLToast toast_showWithWarning:YES title:@"验证码不能为空"];
            return [RACSignal empty];
        }
        
        if (![self.pwdString isEqualToString:self.againPwdString]) {
            [MOLToast toast_showWithWarning:YES title:@"两次密码不一致"];
            return [RACSignal empty];
        }
        
        if (self.pwdString.length < 6) {
            [MOLToast toast_showWithWarning:YES title:@"密码太短,请输入6-32位密码"];
            return [RACSignal empty];
        }
        
        if (self.pwdString.length > 32) {
            [MOLToast toast_showWithWarning:YES title:@"密码太长,请输入6-32位密码"];
            return [RACSignal empty];
        }
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            [MBProgressHUD showMessage:nil];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"phone"] = [self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            dic[@"phoneCode"] = self.codeString;
            dic[@"password"] = [self.pwdString mol_md5WithOrigin];
            dic[@"type"] = @(2);
            
            MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_bindingPhoneWithParameter:dic];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                [MBProgressHUD hideHUD];
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
                
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
                
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendCompleted];
                [MBProgressHUD hideHUD];
            }];
            return nil;
        }];
        return signal;
    }];
}

@end
