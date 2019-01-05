//
//  MOLMineReuqest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLStoryGroupModel.h"
#import "MOLMineMailGroupModel.h"

@interface MOLMineReuqest : MOLNetRequest


/// 喜欢的帖子列表
- (instancetype)initRequest_mineLikeStoryListWithParameter:(NSDictionary *)parameter;

/// 我的帖子列表
- (instancetype)initRequest_myStoryListWithParameter:(NSDictionary *)parameter;
@end
