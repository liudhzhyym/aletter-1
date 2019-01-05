//
//  MOLMeetViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMeetViewModel.h"
#import "MOLStoryListRequest.h"

@implementation MOLMeetViewModel

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
    
    // 遇见帖子列表
    self.meetStoryListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dict = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            MOLStoryListRequest *r = [[MOLStoryListRequest alloc] initRequest_meetStoryListWithParameter:dict];
            
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
