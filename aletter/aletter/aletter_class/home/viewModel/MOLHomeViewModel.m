//
//  MOLHomeViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLHomeViewModel.h"
#import "MOLMailModel.h"
#import "MOLHomeMailRequest.h"

@implementation MOLHomeViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupHomeViewModel];
    }
    return self;
}

- (void)setupHomeViewModel
{
    @weakify(self);
    self.homeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
       
        NSString *channel = [NSString stringWithFormat:@"%@",input];
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            // 获取数据
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"styleId"] = channel;
            MOLHomeMailRequest *r = [[MOLHomeMailRequest alloc] initRequest_channelListWithParameter:dic];
            
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                
                MOLMailGroupModel *groupModel = (MOLMailGroupModel *)responseModel;

                [subscriber sendNext:groupModel];
                [subscriber sendCompleted];
                
            } failure:^(__kindof MOLBaseNetRequest *request) {
                [subscriber sendError:nil];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
        return signal;
    }];
}
@end
