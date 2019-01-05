//
//  MOLTopicRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLTopicGroupModel.h"
#import "MOLStoryGroupModel.h"

@interface MOLTopicRequest : MOLNetRequest

/// 获取频道下所有话题列表
- (instancetype)initRequest_topicListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 获取频道下热门话题列表
- (instancetype)initRequest_hotTopicListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 获取话题下的帖子列表
- (instancetype)initRequest_topicStoryListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;
@end
