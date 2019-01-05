//
//  MOLAdminRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/9/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLAdminRequest.h"

typedef NS_ENUM(NSUInteger, MOLAdminRequestType) {
    MOLAdminRequestType_hide, // 隐藏主贴
    
};

@interface MOLAdminRequest ()
@property (nonatomic, assign) MOLAdminRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLAdminRequest

/// 隐藏主贴
- (instancetype)initRequest_adminHideStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLAdminRequestType_hide;
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
        case MOLAdminRequestType_hide:
        {
            NSString *url = @"/examineStory/{storyId}";
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

@end
