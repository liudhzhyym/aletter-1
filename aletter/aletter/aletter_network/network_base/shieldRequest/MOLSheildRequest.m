//
//  MOLSheildRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSheildRequest.h"

typedef NS_ENUM(NSUInteger, MOLSheildRequestType) {
    MOLSheildRequestType_sheildList,   // 列表
    MOLSheildRequestType_add,  // 增加
    MOLSheildRequestType_delete, // 删除
};

@interface MOLSheildRequest ()
@property (nonatomic, assign) MOLSheildRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLSheildRequest

/// 屏蔽列表
- (instancetype)initRequest_sheildListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLSheildRequestType_sheildList;
        _parameter = parameter;
    }
    
    return self;
}

/// 增加屏蔽
- (instancetype)initRequest_addSheildWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLSheildRequestType_add;
        _parameter = parameter;
    }
    
    return self;
}

/// 删除屏蔽
- (instancetype)initRequest_deleteSheildWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLSheildRequestType_delete;
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
    if (_type == MOLSheildRequestType_sheildList) {
       
        return [MOLSheildGroupModel class];
    }else if (_type == MOLSheildRequestType_add) {
        return [MOLSheildModel class];
    }
    else if (_type == MOLSheildRequestType_delete) {
        return [MOLSheildModel class];
    }
    else{

        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLSheildRequestType_sheildList:
        {
            NSString *url = @"/user/shieldWords";
            return url;
        }
            break;
        case MOLSheildRequestType_add:
        {
            NSString *url = @"/user/addShieldWord";
            return url;
        }
            break;
        case MOLSheildRequestType_delete:
        {
            NSString *url = @"/user/deleteShieldWord";
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
