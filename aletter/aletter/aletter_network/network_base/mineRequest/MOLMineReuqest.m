//
//  MOLMineReuqest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineReuqest.h"
typedef NS_ENUM(NSUInteger, MOLMineReuqestType) {
    MOLMineReuqestType_likeStory,
    MOLMineReuqestType_myStory,
    
};

@interface MOLMineReuqest ()
@property (nonatomic, assign) MOLMineReuqestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end
@implementation MOLMineReuqest

/// 喜欢的帖子列表
- (instancetype)initRequest_mineLikeStoryListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMineReuqestType_likeStory;
        _parameter = parameter;
        
    }
    
    return self;
}


/// 我的帖子列表
- (instancetype)initRequest_myStoryListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMineReuqestType_myStory;
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
    if (_type == MOLMineReuqestType_likeStory) {
        return [MOLStoryGroupModel class];
    }else if (_type == MOLMineReuqestType_myStory){
        return [MOLMineMailGroupModel class];
    }else{
        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLMineReuqestType_likeStory:
        {
            NSString *url = @"/story/likeStoryList";
            return url;
        }
            break;
        case MOLMineReuqestType_myStory:
        {
            NSString *url = @"/own/stories";
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
