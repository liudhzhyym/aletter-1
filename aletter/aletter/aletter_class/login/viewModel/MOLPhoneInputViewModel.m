//
//  MOLPhoneInputViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPhoneInputViewModel.h"
#import "MOLLoginRequest.h"
#import "MOLHead.h"

@interface MOLPhoneInputViewModel ()
@end

@implementation MOLPhoneInputViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupPhoneInputViewModel];
    }
    return self;
}

- (void)setupPhoneInputViewModel
{
    @weakify(self);
    RACSignal *phoneSignal = [RACObserve(self, phoneNumber) map:^id(id value) {
        @strongify(self);
        return @([self isPhoneNum:value]);
    }];
    
    self.canContinueSignal = [RACSignal combineLatest:@[phoneSignal] reduce:^id(NSNumber *phone){
        return @(phone.integerValue);
    }];
    
    self.continueCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        
        NSDictionary *dic = (NSDictionary *)input;
        BOOL difNum = ![dic mol_jsonBool:@"same"];
        NSDictionary *para = dic[@"para"];
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            if (difNum || [MOLCodeTimerManager shareCodeTimerManager].showTime == MOL_CODETIME) {
                NSLog(@"重新发送验证码");
                [[MOLCodeTimerManager shareCodeTimerManager] codeTimer_stopTimer];
                [MBProgressHUD showMessage:nil];
                
                MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_getCodeWithParameter:para];
                
                [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                    if (code == MOL_SUCCESS_REQUEST || code == 20025) {   // 20025 绑定密码  20007 已经注册
                        
                        NSString *codeStr = [request.responseObject mol_jsonString:@"resBody"];
                        if (codeStr.length) {
                            [MOLToast toast_showWithWarning:NO title:[NSString stringWithFormat:@"短信验证码已发出【%@】",codeStr]];
                        }else{
                            [MOLToast toast_showWithWarning:NO title:@"短信验证码已发出"];
                        }
                        
                        // 开启倒计时 发送网络请求
                        [MOLCodeTimerManager shareCodeTimerManager].showTime -= 1;
                        [[MOLCodeTimerManager shareCodeTimerManager] codeTimer_beginTimer:nil];
                    }else if (code == 20007){/*跳登录界面*/}else{
                        [MOLToast toast_showWithWarning:YES title:message];
                    }
                    
                    [MBProgressHUD hideHUD];
                    [subscriber sendNext:@(code)];
                    [subscriber sendCompleted];
                    
                } failure:^(__kindof MOLBaseNetRequest *request) {
                    [subscriber sendCompleted];
                    [MBProgressHUD hideHUD];
                }];
                
            }else{
                [subscriber sendNext:@(MOL_SUCCESS_REQUEST)];
                [subscriber sendCompleted];
                
            }
            return nil;
        }];
        
        return signal;
    }];
    
}

- (BOOL)isPhoneNum:(NSString *)number
{
    if ([MOLRegular mol_RegularMobileNumber:[number stringByReplacingOccurrencesOfString:@" " withString:@""]]) {
        return number.length == 13;
    }
    return NO;
}
@end
