//
//  MOLChatViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChatViewModel.h"
#import "MOLMessageRequest.h"
#import "MOLActionRequest.h"

@implementation MOLChatViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupChatViewModel];
    }
    return self;
}

- (void)setupChatViewModel
{
    @weakify(self);
    // 关闭对话
    self.closeChatCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *paraId = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_closeChatWithParameter:nil parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:@(code)];
                [subscriber sendCompleted];
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    // 重新打开对话
    self.openChatCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *paraId = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_openChatWithParameter:nil parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:@(code)];
                [subscriber sendCompleted];
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    // 同意重新打开对话
    self.agreeChatCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *paraId = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_agreeOpenChatWithParameter:nil parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:@(code)];
                [subscriber sendCompleted];
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    // 举报对话
    self.reportChatCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *para = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_reportActionWithParameter:para];
//            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_closeChatWithParameter:nil parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:@(code)];
                [subscriber sendCompleted];
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
                }
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
}
@end
