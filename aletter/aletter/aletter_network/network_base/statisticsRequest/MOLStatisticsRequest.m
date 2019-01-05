//
//  MOLStatisticsRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/9/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStatisticsRequest.h"
typedef NS_ENUM(NSUInteger, MOLStatisticsRequestType) {
    MOLStatisticsRequestType_playStory,   // 播放主贴
    
};

@interface MOLStatisticsRequest ()
@property (nonatomic, assign) MOLStatisticsRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLStatisticsRequest

/// 播放主贴统计
- (instancetype)initRequest_statisticsPlayStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLStatisticsRequestType_playStory;
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
    return [MOLBaseModel class];
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLStatisticsRequestType_playStory:
        {
            NSString *url = @"/playStory/{storyId}";
            url = [url stringByReplacingOccurrencesOfString:@"{storyId}" withString:self.parameterId];
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

- (BOOL)isToast
{
    return NO;
}
@end
