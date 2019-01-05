//
//  MOLLoginRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLUserModel.h"
#import "MOLSchoolGroupModel.h"

@interface MOLLoginRequest : MOLNetRequest
/// 获取验证码
- (instancetype)initRequest_getCodeWithParameter:(NSDictionary *)parameter;

/// 注册
- (instancetype)initRequest_registWithParameter:(NSDictionary *)parameter;

/// 登录
- (instancetype)initRequest_loginWithParameter:(NSDictionary *)parameter;

/// 信息确认
- (instancetype)initRequest_infoCheckWithParameter:(NSDictionary *)parameter;

/// 绑定手机/设置密码
- (instancetype)initRequest_bindingPhoneWithParameter:(NSDictionary *)parameter;

/// 搜索学校
- (instancetype)initRequest_searchSchoolWithParameter:(NSDictionary *)parameter;
/// 学校列表
- (instancetype)initRequest_schoolListWithParameter:(NSDictionary *)parameter;
/// 修改学校信息
- (instancetype)initRequest_changeSchoolWithParameter:(NSDictionary *)parameter;
@end
