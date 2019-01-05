//
//  MOLStoryDetailViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLStoryDetailViewModel : MOLBaseViewModel

@property (nonatomic, strong) RACCommand *storyInfoCommand;  // 帖子详情
@property (nonatomic, strong) RACCommand *commentListCommand;  // 评论列表
@property (nonatomic, strong) RACCommand *publishCommand;  // 发布评论
@property (nonatomic, strong) RACCommand *publishStoryCommand;  // 发布私密帖子
@property (nonatomic, strong) RACCommand *messageNameCommand;  // 是否起名字
@end
