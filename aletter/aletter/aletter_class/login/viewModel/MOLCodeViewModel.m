//
//  MOLCodeViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLCodeViewModel.h"
#import "MOLLoginRequest.h"

@implementation MOLCodeViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupCodeViewModel];
    }
    return self;
}
- (void)setupCodeViewModel
{
    @weakify(self);
    RACSignal *showTimeSignal = [RACObserve([MOLCodeTimerManager shareCodeTimerManager], showTime) map:^id(id value) {
        return @([value integerValue] == MOL_CODETIME);
    }];
    
    // 是否可以发送验证码的信号
    self.canSendCodeSignal = [RACSignal combineLatest:@[showTimeSignal] reduce:^id(NSNumber *num){
        return @(num.integerValue);
    }];
    
    RACSignal *codeSignal = [RACObserve(self, codeString) map:^id(id value) {
        
        return @([value length] >= 4);
    }];
    
    // 是否可以点击继续的信号
    self.continueSignal = [RACSignal combineLatest:@[codeSignal] reduce:^id(NSNumber *code){
        return @(code.integerValue);
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
        NSDictionary *dic = (NSDictionary *)input;
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            [MBProgressHUD showMessage:nil];
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
    
    // 绑定手机
    self.continue_GoBindingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        if (!self.codeString.length) {
            [MOLToast toast_showWithWarning:YES title:@"验证码不能为空"];
            return [RACSignal empty];
        }
        NSDictionary *dic = (NSDictionary *)input;
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            @strongify(self);
            [MBProgressHUD showMessage:nil];
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
