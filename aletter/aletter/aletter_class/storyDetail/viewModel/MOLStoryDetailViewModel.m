//
//  MOLStoryDetailViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailViewModel.h"
#import "MOLStoryListRequest.h"
#import "MOLActionRequest.h"
#import "MOLMessageRequest.h"

@implementation MOLStoryDetailViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupStoryDetailViewModel];
    }
    return self;
}

- (void)setupStoryDetailViewModel
{
    // 帖子详情
    self.storyInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *paraId = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            MOLStoryListRequest *r = [[MOLStoryListRequest alloc] initRequest_storyDetailWithParameter:nil parameterId:paraId];

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
    
    // 评论列表
    self.commentListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dict = (NSDictionary *)input;
        NSDictionary *para = [dict mol_jsonDict:@"para"];
        NSString *paraId = [dict mol_jsonString:@"paraId"];
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            MOLStoryListRequest *r = [[MOLStoryListRequest alloc] initRequest_storyCommentListWithParameter:para parameterId:paraId];
            
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
    
    // 发布评论
    self.publishCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *para = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            MOLStoryListRequest *r = [[MOLStoryListRequest alloc] initRequest_publishCommentListWithParameter:para];
            
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
    
    // 发布私密帖子
    self.publishStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *paraId = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"name"] = [MOLUserManagerInstance user_getUserLastName];
            
            MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_publsihPrivateStoryWithParameter:dic parameterId:paraId];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                [subscriber sendNext:@(code)];
                [subscriber sendCompleted];
                if (code == MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:NO title:@"信件投递成功"];
                }else{
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
    
    // 是否有私聊
    self.messageNameCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *para = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_checkChatWithParameter:para];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                NSDictionary *dic = request.responseObject[@"resBody"];
                NSInteger chatId = [dic mol_jsonInteger:@"chatId"];
                [subscriber sendNext:@(chatId)];
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
