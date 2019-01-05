//
//  MOLMineMessageViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMessageViewModel.h"
#import "MOLMessageRequest.h"

@implementation MOLMineMessageViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupMineMessageViewModel];
    }
    return self;
}

- (void)setupMineMessageViewModel
{
    // 最新会话
    @weakify(self);
    self.messageListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dic = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_messageListWithParameter:dic];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    // 通知最新
    self.notiListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_systemNotiWithParameter:nil];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
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
