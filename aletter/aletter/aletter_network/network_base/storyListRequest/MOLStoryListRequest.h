//
//  MOLStoryListRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLStoryGroupModel.h"
#import "MOLCommentGroupModel.h"
@interface MOLStoryListRequest : MOLNetRequest

/// 获取频道的帖子列表
- (instancetype)initRequest_channelStoryListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 获取帖子详情
- (instancetype)initRequest_storyDetailWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 帖子评论列表
- (instancetype)initRequest_storyCommentListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 发布评论
- (instancetype)initRequest_publishCommentListWithParameter:(NSDictionary *)parameter;

/// 获取遇见的帖子列表
- (instancetype)initRequest_meetStoryListWithParameter:(NSDictionary *)parameter;


@end
