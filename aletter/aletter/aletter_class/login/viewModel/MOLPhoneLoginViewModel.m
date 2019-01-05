//
//  MOLPhoneLoginViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPhoneLoginViewModel.h"
#import "MOLLoginRequest.h"
#import "MOLActionRequest.h"

@implementation MOLPhoneLoginViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupPhoneLoginViewModel];
    }
    return self;
}

- (void)setupPhoneLoginViewModel
{
    @weakify(self);
    RACSignal *pwdSignal = [RACObserve(self, pwdString) map:^id(id value) {
        
        return @([value length] > 0);
    }];
    
    self.canContinueSignal = [RACSignal combineLatest:@[pwdSignal] reduce:^id(NSNumber *pwd){
        return @(pwd.integerValue);
    }];
    
    self.continueCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        NSDictionary *dic = (NSDictionary *)input;
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [MBProgressHUD showMessage:nil];
            
            MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_loginWithParameter:dic];
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                [MBProgressHUD hideHUD];
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
                // 19999 去绑定手机号（三方已经注册 - 走绑定接口）   20005 去绑定手机号（三方没有注册 - 走注册接口）
                if (code != MOL_SUCCESS_REQUEST && code != 20005 && code != 20000 && code != 19999) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [MBProgressHUD hideHUD];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    self.getLastNameCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_lastCommentNameActionCommentWithParameter:nil parameterId:@"1"];// 获取上次使用昵称-nameType:1发帖/私信昵称 2评论名称
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                if (code == MOL_SUCCESS_REQUEST) {
                    
                    NSString *name = request.responseObject[@"resBody"];
                    [MOLUserManagerInstance user_saveUserLastNameWithName:name];
                    [subscriber sendCompleted];
                }
                
            } failure:^(__kindof MOLBaseNetRequest *request) {
                
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
}
@end
