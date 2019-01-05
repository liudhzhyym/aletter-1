//
//  MOLMailDetailViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLMailDetailViewModel : MOLBaseViewModel

@property (nonatomic, strong) RACCommand *hotTopicCommand; // 热门话题
@property (nonatomic, strong) RACCommand *mailStoryListCommand; // 邮箱内帖子列表
@property (nonatomic, strong) RACCommand *topicStoryListCommand; // 邮箱内帖子列表
@end
