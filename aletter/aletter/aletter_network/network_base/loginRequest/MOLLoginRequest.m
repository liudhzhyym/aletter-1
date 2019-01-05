//
//  MOLLoginRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLLoginRequest.h"

typedef NS_ENUM(NSUInteger, MOLLoginRequestType) {
    MOLLoginRequestType_code,
    MOLLoginRequestType_login,
    MOLLoginRequestType_regist,
    MOLLoginRequestType_info,
    MOLLoginRequestType_binding,
    MOLLoginRequestType_school,
    MOLLoginRequestType_schoolList,
    MOLLoginRequestType_changeSchool,
};

@interface MOLLoginRequest ()
@property (nonatomic, assign) MOLLoginRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLLoginRequest

/// 获取验证码
- (instancetype)initRequest_getCodeWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_code;
        _parameter = parameter;
    }
    
    return self;
}

/// 注册
- (instancetype)initRequest_registWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_regist;
        _parameter = parameter;
    }
    
    return self;
}

/// 登录
- (instancetype)initRequest_loginWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_login;
        _parameter = parameter;
    }
    
    return self;
}

/// 信息确认
- (instancetype)initRequest_infoCheckWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_info;
        _parameter = parameter;
    }
    
    return self;
}


/// 绑定手机
- (instancetype)initRequest_bindingPhoneWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_binding;
        _parameter = parameter;
    }
    return self;
}

/// 搜索学校
- (instancetype)initRequest_searchSchoolWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_school;
        _parameter = parameter;
    }
    return self;
}

/// 学校列表
- (instancetype)initRequest_schoolListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_schoolList;
        _parameter = parameter;
    }
    return self;
}

/// 修改学校信息
- (instancetype)initRequest_changeSchoolWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLLoginRequestType_changeSchool;
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
    if (_type == MOLLoginRequestType_regist || _type == MOLLoginRequestType_login || _type == MOLLoginRequestType_info || _type == MOLLoginRequestType_binding) {
        return [MOLUserModel class];
    }
    
    if (_type == MOLLoginRequestType_school || _type == MOLLoginRequestType_schoolList) {
        return [MOLSchoolGroupModel class];
    }
    return [MOLBaseModel class];
}


- (NSString *)requestUrl
{
    switch (_type) {
        case MOLLoginRequestType_code:
        {
            NSString *url = @"/login/getPhoneCode";
            return url;
        }
            break;
        case MOLLoginRequestType_login:
        {
            NSString *url = @"/login/login";
            return url;
        }
            break;
        case MOLLoginRequestType_regist:
        {
            NSString *url = @"/login/register";
            return url;
        }
            break;
        case MOLLoginRequestType_info:
        {
            NSString *url = @"/login/upUser";
            return url;
        }
            break;
        case MOLLoginRequestType_binding:
        {
            NSString *url = @"/login/APPBinding";
            return url;
        }
            break;
        case MOLLoginRequestType_school:
        {
            NSString *url = @"/user/searchSchool";
            return url;
        }
            break;
        case MOLLoginRequestType_schoolList:
        {
            NSString *url = @"/user/schools";
            return url;
        }
            break;
        case MOLLoginRequestType_changeSchool:
        {
            NSString *url = @"/user/updateSchool";
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
