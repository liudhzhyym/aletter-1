//
//  MOLTopicListViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLTopicListViewModel.h"
#import "MOLTopicRequest.h"

@implementation MOLTopicListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupTopicListViewModel];
    }
    return self;
}

- (void)setupTopicListViewModel
{
    @weakify(self);
    self.topicListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSString *channel = (NSString *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            MOLTopicRequest *r = [[MOLTopicRequest alloc] initRequest_topicListWithParameter:nil parameterId:channel];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                [subscriber sendNext:responseModel];
                [subscriber sendCompleted];
                if (code != MOL_SUCCESS_REQUEST) {
                    [MOLToast toast_showWithWarning:YES title:message];
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
