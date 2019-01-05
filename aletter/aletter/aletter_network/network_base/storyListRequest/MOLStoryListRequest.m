//
//  MOLStoryListRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryListRequest.h"

typedef NS_ENUM(NSUInteger, MOLStoryListRequestType) {
    MOLStoryListRequest_channelStoryList,
    MOLStoryListRequest_storyDetail,
    MOLStoryListRequest_storyCommentList,
    MOLStoryListRequest_publishComment,
    MOLStoryListRequest_meetStoryList,
};

@interface MOLStoryListRequest ()
@property (nonatomic, assign) MOLStoryListRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLStoryListRequest
/// 获取频道的帖子列表
- (instancetype)initRequest_channelStoryListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLStoryListRequest_channelStoryList;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}


/// 获取帖子详情
- (instancetype)initRequest_storyDetailWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLStoryListRequest_storyDetail;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 帖子评论列表
- (instancetype)initRequest_storyCommentListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLStoryListRequest_storyCommentList;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}


/// 发布评论
- (instancetype)initRequest_publishCommentListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLStoryListRequest_publishComment;
        _parameter = parameter;
    }
    
    return self;
}


/// 获取遇见的帖子列表
- (instancetype)initRequest_meetStoryListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLStoryListRequest_meetStoryList;
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
    if (_type == MOLStoryListRequest_channelStoryList) {
        return [MOLStoryGroupModel class];
    }else if (_type == MOLStoryListRequest_storyDetail){
        return [MOLStoryModel class];
    }else if (_type == MOLStoryListRequest_storyCommentList){
        return [MOLCommentGroupModel class];
    }else if (_type == MOLStoryListRequest_publishComment){
        return [MOLCommentModel class];
    }else if (_type == MOLStoryListRequest_meetStoryList){
        return [MOLStoryGroupModel class];
    }else {
        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLStoryListRequest_channelStoryList:
        {
            NSString *url = @"/{channelId}/channelStories";
            url = [url stringByReplacingOccurrencesOfString:@"{channelId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLStoryListRequest_storyDetail:
        {
            NSString *url = @"/story/{storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLStoryListRequest_storyCommentList:
        {
            NSString *url = @"/{storyId}/comments";
            url = [url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLStoryListRequest_publishComment:
        {
            NSString *url = @"/comment/publish";
            return url;
        }
            break;
        case MOLStoryListRequest_meetStoryList:
        {
            NSString *url = @"/recommendInfo";
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
