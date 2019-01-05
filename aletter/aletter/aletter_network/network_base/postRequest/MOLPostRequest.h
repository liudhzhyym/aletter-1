//
//  MOLPostRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"

typedef NS_ENUM(NSUInteger, MOLPostRequestType) {
    MOLPostRequestType_weather,
    MOLPostRequestType_stamp,
    MOLPostRequestType_channelDetails,
    MOLPostRequestType_privateEnvelope,
    MOLPostRequestType_updateStory,
};

@interface MOLPostRequest : MOLNetRequest

/// 查询天气（回帖）
- (instancetype)initRequest_weatherWithParameter:(NSDictionary *)parameter;

/// 查询邮票（回帖）
- (instancetype)initRequest_StampWithParameter:(NSDictionary *)parameter;

/// 获取频道详情
- (instancetype)initRequest_channelDetailsWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 发布私密信封
- (instancetype)initRequest_privateEnvelopeWithParameter:(NSDictionary *)parameter;

/// 修改帖子
- (instancetype)initRequest_UpdateStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

@end
