//
//  MOLUserManager.h
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOLUserModel.h"

#define MOLUserManagerInstance [MOLUserManager shareUserManager]

@interface MOLUserManager : NSObject

+ (instancetype)shareUserManager;
@property (nonatomic, strong) NSString *platUserId;
@property (nonatomic, strong) NSString *platOpenid;
@property (nonatomic, strong) NSString *platUid;
@property (nonatomic, strong) NSString *platToken;
@property (nonatomic, assign) NSInteger platType;

/// 保存用户登录信息
- (void)user_saveLoginWithStatus:(BOOL)status;
/// 获取用户是否登录
- (BOOL)user_isLogin;

/// 获取用户是否需要完善信息
- (BOOL)user_needCompleteInfo;

/// 保存用户信息
- (void)user_saveUserInfoWithModel:(MOLUserModel *)user;

/// 获取用户信息
- (MOLUserModel *)user_getUserInfo;

/// 清除用户信息
- (void)user_resetUserInfo;

/// 保存和获取用户最近使用的名字
- (void)user_saveUserLastNameWithName:(NSString *)name;
- (NSString *)user_getUserLastName;


/// 获取用户是否管理员
- (BOOL)user_isPower;
@end
