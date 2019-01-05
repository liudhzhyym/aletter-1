//
//  MOLActionRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLActionRequest.h"

typedef NS_ENUM(NSUInteger, MOLActionRequestType) {
    MOLActionRequestType_likeStory,
    MOLActionRequestType_collectStory,
    MOLActionRequestType_deleteStory,
    MOLActionRequestType_report,
    MOLActionRequestType_deleteComment,
    MOLActionRequestType_changeCommentName,
    MOLActionRequestType_searchCommentName,
    MOLActionRequestType_lastCommentName,
    MOLActionRequestType_publishPrivateStory,
    MOLActionRequestType_userInfo,
    MOLActionRequestType_switch,
};

@interface MOLActionRequest ()
@property (nonatomic, assign) MOLActionRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLActionRequest

/// 获取开关接口
- (instancetype)initRequest_getSwitchActionCommentWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_switch;
        _parameter = parameter;
    }
    
    return self;
}

/// 点赞帖子
- (instancetype)initRequest_likeActionStoryWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_likeStory;
        _parameter = parameter;
    }
    
    return self;
}

/// 收藏帖子
- (instancetype)initRequest_collectActionStoryWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_collectStory;
        _parameter = parameter;
    }
    
    return self;
}


/// 发布私密帖子
- (instancetype)initRequest_publsihPrivateStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_publishPrivateStory;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 删除帖子
- (instancetype)initRequest_deleteActionStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_deleteStory;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}


/// 举报帖子/评论
- (instancetype)initRequest_reportActionWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_report;
        _parameter = parameter;
    }
    
    return self;
}

/// 删除评论
- (instancetype)initRequest_deleteActionCommentWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_deleteComment;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 修改评论名字
- (instancetype)initRequest_changeCommentNameActionCommentWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_changeCommentName;
        _parameter = parameter;
    }
    
    return self;
}

/// 查询之前评论名字
- (instancetype)initRequest_searchCommentNameActionCommentWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_searchCommentName;
        _parameter = parameter;
    }
    
    return self;
}

/// 查询上次使用的名字（私信、帖子）
- (instancetype)initRequest_lastCommentNameActionCommentWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_lastCommentName;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}


/// 获取用户信息
- (instancetype)initRequest_getUserInfoActionCommentWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLActionRequestType_userInfo;
        _parameter = parameter;
    }
    
    return self;
}


- (id)requestArgument
{
    return _parameter;
}

- (Class)modelClass
{
    if (_type == MOLActionRequestType_searchCommentName) {
        return [MOLOldNameGroupModel class];
    }else if (_type == MOLActionRequestType_lastCommentName){
        return [MOLOldNameModel class];
    }else if (_type == MOLActionRequestType_userInfo){
        return [MOLUserModel class];
    }else{
        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLActionRequestType_switch:
        {
            NSString *url = @"/versionInfo";
            return url;
        }
            break;
        case MOLActionRequestType_likeStory:
        {
            NSString *url = @"/agree/agree";
            return url;
        }
            break;
        case MOLActionRequestType_collectStory:
        {
            NSString *url = @"/collection/collection";
            return url;
        }
            break;
        case MOLActionRequestType_publishPrivateStory:
        {
            NSString *url = @"/public/{storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLActionRequestType_deleteStory:
        {
            NSString *url = @"/deleteStory/{storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLActionRequestType_report:
        {
            NSString *url = @"/report";
            url = [url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLActionRequestType_deleteComment:
        {
            NSString *url = @"/deletedComment/{commentId}";
            url = [url stringByReplacingOccurrencesOfString:@"{commentId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLActionRequestType_changeCommentName:
        {
            NSString *url = @"/name/updateCommentName";
            return url;
        }
            break;
        case MOLActionRequestType_searchCommentName:
        {
            NSString *url = @"/names";
            return url;
        }
            break;
        case MOLActionRequestType_lastCommentName:
        {
            NSString *url = @"/name/{nameType}";
            url = [url stringByReplacingOccurrencesOfString:@"{nameType}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLActionRequestType_userInfo:
        {
            NSString *url = @"/user/userInfo";
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)parameterId {
    if (!_parameterId.length) {
        return @"";
    }
    return _parameterId;
}
@end
