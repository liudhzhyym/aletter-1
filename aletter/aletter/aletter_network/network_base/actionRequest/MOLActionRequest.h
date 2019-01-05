//
//  MOLActionRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLOldNameGroupModel.h"
#import "MOLUserModel.h"

@interface MOLActionRequest : MOLNetRequest

/// 获取开关接口
- (instancetype)initRequest_getSwitchActionCommentWithParameter:(NSDictionary *)parameter;

/// 点赞帖子
- (instancetype)initRequest_likeActionStoryWithParameter:(NSDictionary *)parameter;

/// 收藏帖子
- (instancetype)initRequest_collectActionStoryWithParameter:(NSDictionary *)parameter;

/// 发布私密帖子
- (instancetype)initRequest_publsihPrivateStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 删除帖子
- (instancetype)initRequest_deleteActionStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 举报帖子/评论
- (instancetype)initRequest_reportActionWithParameter:(NSDictionary *)parameter;

/// 删除评论
- (instancetype)initRequest_deleteActionCommentWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 修改评论名字
- (instancetype)initRequest_changeCommentNameActionCommentWithParameter:(NSDictionary *)parameter;

/// 查询使用过的所有名字
- (instancetype)initRequest_searchCommentNameActionCommentWithParameter:(NSDictionary *)parameter;

/// 查询上次使用的名字（私信、帖子）
- (instancetype)initRequest_lastCommentNameActionCommentWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 获取用户信息
- (instancetype)initRequest_getUserInfoActionCommentWithParameter:(NSDictionary *)parameter;
@end
