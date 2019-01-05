//
//  MOLActionViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLActionViewModel : MOLBaseViewModel

@property (nonatomic, strong) RACCommand *likeStoryCommand; // 点赞帖子
//@property (nonatomic, strong) RACCommand *collectStoryCommand; // 收藏帖子
//@property (nonatomic, strong) RACCommand *reportStoryCommand; // 举报帖子
//@property (nonatomic, strong) RACCommand *deleteStoryCommand; // 删除帖子
//@property (nonatomic, strong) RACCommand *reportCommentCommand; // 举报评论
//@property (nonatomic, strong) RACCommand *deleteCommentCommand; // 删除评论

@end
