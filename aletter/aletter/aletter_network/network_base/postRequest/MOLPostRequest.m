//
//  MOLPostRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPostRequest.h"
#import "MOLLightWeatherModel.h"
#import "MOLMailModel.h"
#import "MOLStampSetModel.h"
#import "MOLStoryModel.h"


@interface MOLPostRequest ()
@property (nonatomic, assign) MOLPostRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLPostRequest

/// 查询天气（回帖）
- (instancetype)initRequest_weatherWithParameter:(NSDictionary *)parameter{
    
    if (self =[super init]) {
        _type = MOLPostRequestType_weather;
        _parameter =parameter;
    }
    return self;
}

/// 获取邮票数据（回帖）
- (instancetype)initRequest_StampWithParameter:(NSDictionary *)parameter{
    
    if (self =[super init]) {
        _type = MOLPostRequestType_stamp;
        _parameter =parameter;
    }
    return self;
}

/// 获取频道详情
- (instancetype)initRequest_channelDetailsWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId{
    
    if (self =[super init]) {
        _type = MOLPostRequestType_channelDetails;
        _parameter =parameter;
        _parameterId = parameterId;
    }
    return self;
}

/// 发布私密信封
- (instancetype)initRequest_privateEnvelopeWithParameter:(NSDictionary *)parameter{
    
    if (self =[super init]) {
        _type = MOLPostRequestType_privateEnvelope;
        _parameter =parameter;
    }
    return self;
}

/// 修改帖子
- (instancetype)initRequest_UpdateStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId{
    if (self =[super init]) {
        _type = MOLPostRequestType_updateStory;
        _parameter =parameter;
        _parameterId = parameterId;
    }
    return self;
}


- (id)requestArgument
{
    return _parameter;
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLPostRequestType_weather:
        {
            NSString *url = @"/weather/weatherInfo";
            //            url = [url stringByReplacingOccurrencesOfString:@"{nameType}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLPostRequestType_stamp:
        {
            NSString *url = @"/stamp/stampList";
            return url;
        }
            break;
        case MOLPostRequestType_channelDetails:
        {
            NSString *url = @"/channel/{channelId}/channelInfo";
            url = [url stringByReplacingOccurrencesOfString:@"{channelId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLPostRequestType_privateEnvelope:
        {
            NSString *url = @"/story/publish";
            return url;
        }
            break;
        case MOLPostRequestType_updateStory:
        {
            NSString *url = @"/updateStory/{storyId}";
            url =[url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
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

- (Class)modelClass
{
    if (_type == MOLPostRequestType_weather){
        return [MOLLightWeatherModel class];
    }else if (_type == MOLPostRequestType_stamp){
        return [MOLStampSetModel class];
    }else if (_type == MOLPostRequestType_channelDetails){
        return [MOLMailModel class];
    }else if(_type == MOLPostRequestType_updateStory){
        return [MOLStoryModel class];
    }else{
        return [MOLBaseModel class];
    }
}



@end
