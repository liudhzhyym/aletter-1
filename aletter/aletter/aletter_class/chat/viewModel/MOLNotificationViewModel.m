//
//  MOLNotificationViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNotificationViewModel.h"
#import "MOLMessageRequest.h"

@implementation MOLNotificationViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupNotificationViewModel];
    }
    return self;
}

- (void)setupNotificationViewModel
{
    // 系统通知
    @weakify(self);
    self.notiCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dic = (NSDictionary *)input;
        NSDictionary *para = [dic mol_jsonDict:@"para"];
        NSString *paraId = [dic mol_jsonString:@"paraId"];
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_notifacationCotiContentWithParameter:para parameterId:paraId];
            
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
    
    self.readInteractCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *paraId = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_readInteractWithParameter:nil parameterId:paraId];
            
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
