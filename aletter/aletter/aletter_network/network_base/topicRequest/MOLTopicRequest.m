//
//  MOLTopicRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLTopicRequest.h"

typedef NS_ENUM(NSUInteger, MOLTopicRequestType) {
    MOLTopicRequestType_topicList,
    MOLTopicRequestType_hotTopicList,
    MOLTopicRequestType_topicStoryList,
};

@interface MOLTopicRequest ()
@property (nonatomic, assign) MOLTopicRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLTopicRequest

/// 获取频道下所有话题列表
- (instancetype)initRequest_topicListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLTopicRequestType_topicList;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 获取频道下热门话题列表
- (instancetype)initRequest_hotTopicListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLTopicRequestType_hotTopicList;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 获取话题下的帖子列表
- (instancetype)initRequest_topicStoryListWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLTopicRequestType_topicStoryList;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

- (id)requestArgument
{
    return _parameter;
}

- (Class)modelClass
{
    if (_type == MOLTopicRequestType_topicList) {
        return [MOLTopicGroupModel class];
    }else if (_type == MOLTopicRequestType_hotTopicList){
        return [MOLTopicGroupModel class];
    }else if (_type == MOLTopicRequestType_topicStoryList){
        return [MOLStoryGroupModel class];
    }else {
        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLTopicRequestType_topicList:
        {
            NSString *url = @"/topics/{channelId}";
            url = [url stringByReplacingOccurrencesOfString:@"{channelId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLTopicRequestType_hotTopicList:
        {
            NSString *url = @"/hotTopics/{channelId}";
            url = [url stringByReplacingOccurrencesOfString:@"{channelId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLTopicRequestType_topicStoryList:
        {
            NSString *url = @"/{topicId}/topicStories";
            url = [url stringByReplacingOccurrencesOfString:@"{topicId}" withString:self.parameterId];
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
