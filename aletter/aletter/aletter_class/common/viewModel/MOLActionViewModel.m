//
//  MOLActionViewModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLActionViewModel.h"
#import "MOLActionRequest.h"
#import "MOLStoryModel.h"
#import "MOLCommentModel.h"

@implementation MOLActionViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupActionViewModel];
    }
    return self;
}

- (void)setupActionViewModel
{
    @weakify(self);
    // 点赞帖子
    self.likeStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        MOLStoryModel *model = (MOLStoryModel *)input;
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            //获取数据
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"type"] = model.isAgree ? @"2" : @"1";
            dic[@"typeId"] = model.storyId;
            MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_likeActionStoryWithParameter:dic];
            [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
                if (code == MOL_SUCCESS_REQUEST) {
                    model.isAgree = !model.isAgree;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"MOL_LIKE_STATUS" object:model];
                }
                [subscriber sendNext:@(code)];
                [subscriber sendCompleted];
                
            } failure:^(__kindof MOLBaseNetRequest *request) {
                
                [subscriber sendCompleted];
            }];
            
            return nil;
        }];
        
        return signal;
    }];
    
//    // 收藏帖子
//    self.collectStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        
//        NSString *channel = (NSString *)input;
//        
//        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            @strongify(self);
//            //获取数据
//            
//            return nil;
//        }];
//        
//        return signal;
//    }];
//    
//    // 举报帖子
//    self.reportStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        
//        NSString *channel = (NSString *)input;
//        
//        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            @strongify(self);
//            //获取数据
//            
//            return nil;
//        }];
//        
//        return signal;
//    }];
//    
//    // 删除帖子
//    self.deleteStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        
//        NSString *channel = (NSString *)input;
//        
//        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            @strongify(self);
//            //获取数据
//            
//            return nil;
//        }];
//        
//        return signal;
//    }];
//    
//    // 举报评论
//    self.reportCommentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        
//        NSString *channel = (NSString *)input;
//        
//        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            @strongify(self);
//            //获取数据
//            
//            return nil;
//        }];
//        
//        return signal;
//    }];
//    
//    // 删除评论
//    self.deleteCommentCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        
//        NSString *channel = (NSString *)input;
//        
//        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            @strongify(self);
//            //获取数据
//            
//            return nil;
//        }];
//        
//        return signal;
//    }];
}
@end
