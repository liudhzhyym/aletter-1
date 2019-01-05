//
//  MOLHomeMailRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLHomeMailRequest.h"
typedef NS_ENUM(NSUInteger, MOLHomeMailRequestType) {
    MOLHomeMailRequest_channelCatogery,
    MOLHomeMailRequest_channelList,
    MOLHomeMailRequest_version,
    MOLHomeMailRequest_ad,
};

@interface MOLHomeMailRequest ()
@property (nonatomic, assign) MOLHomeMailRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLHomeMailRequest

/// 获取频道类别列表
- (instancetype)initRequest_channelCatogeryWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLHomeMailRequest_channelCatogery;
        _parameter = parameter;
        
    }
    
    return self;
}

/// 获取频道列表
- (instancetype)initRequest_channelListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLHomeMailRequest_channelList;
        _parameter = parameter;
        
    }
    
    return self;
}



/// 获取版本更新
- (instancetype)initRequest_versionCheckWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLHomeMailRequest_version;
        _parameter = parameter;
        
    }
    
    return self;
}

/// 获取AD
- (instancetype)initRequest_adWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLHomeMailRequest_ad;
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
    if (_type == MOLHomeMailRequest_channelList) {
        return [MOLMailGroupModel class];
    }else if(_type == MOLHomeMailRequest_channelCatogery){
        return [MOLCatogeryGroupModel class];
    }else{
        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLHomeMailRequest_channelCatogery:
        {
            NSString *url = @"/style/styleList";
            return url;
        }
            break;
        case MOLHomeMailRequest_channelList:
        {
            NSString *url = @"/channel/channelList";
//            url = [url stringByReplacingOccurrencesOfString:@"{userId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLHomeMailRequest_version:
        {
            NSString *url = @"/version";
            return url;
        }
            break;
        case MOLHomeMailRequest_ad:
        {
            NSString *url = @"/ad";
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
