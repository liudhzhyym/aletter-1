//
//  MOLMailDetailViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailDetailViewModel.h"
#import "MOLStoryListRequest.h"
#import "MOLTopicRequest.h"

@implementation MOLMailDetailViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupMailDetailViewModel];
    }
    return self;
}

- (void)setupMailDetailViewModel
{
    @weakify(self);
    // 热门话题
    self.hotTopicCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *channel = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
             //获取数据
            MOLTopicRequest *r = [[MOLTopicRequest alloc] initRequest_hotTopicListWithParameter:nil parameterId:channel];
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
               
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
            } failure:^(__kindof MOLBaseNetRequest *request) {
                
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    // 邮箱内（频道）帖子列表
    self.mailStoryListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dict = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
           @strongify(self);
            //获取数据
            NSDictionary *para = [dict mol_jsonDict:@"para"];
            NSString *paraId = [dict mol_jsonString:@"paraId"];
            
            MOLStoryListRequest *r = [[MOLStoryListRequest alloc] initRequest_channelStoryListWithParameter:para parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
    // 话题下帖子列表
    self.topicStoryListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dict = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            NSDictionary *para = [dict mol_jsonDict:@"para"];
            NSString *paraId = [dict mol_jsonString:@"paraId"];
            
            MOLTopicRequest *r = [[MOLTopicRequest alloc] initRequest_topicStoryListWithParameter:para parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
}
@end
