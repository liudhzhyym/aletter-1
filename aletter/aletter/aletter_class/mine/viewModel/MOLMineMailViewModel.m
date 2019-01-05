//
//  MOLMineMailViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailViewModel.h"
#import "MOLMineReuqest.h"

@implementation MOLMineMailViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupMineLikeViewModel];
    }
    return self;
}

- (void)setupMineLikeViewModel
{
    // 我的帖子列表
    @weakify(self);
    self.myStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        NSDictionary *dic = (NSDictionary *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            
            MOLMineReuqest *r = [[MOLMineReuqest alloc] initRequest_myStoryListWithParameter:dic];
            
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
