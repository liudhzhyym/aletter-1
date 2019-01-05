//
//  MOLUserManager.m
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLUserManager.h"
#import "MOLHead.h"

@implementation MOLUserManager

+ (instancetype)shareUserManager
{
    static MOLUserManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[MOLUserManager alloc] init];
        }
    });
    return instance;
}

/// 保存用户登录信息
- (void)user_saveLoginWithStatus:(BOOL)status
{
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"user_loginStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (status) {
        MOLUserModel *user = [self user_getUserInfo];
        NSString *alia = [NSString stringWithFormat:@"yfx%@",user.userId];
        [JPUSHService setAlias:alia completion:nil seq:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MOL_LOGIN_SUCCESS" object:nil];
    }else{
        [JPUSHService deleteAlias:nil seq:0];
    }
}

- (BOOL)user_isLogin
{
    BOOL status = [[NSUserDefaults standardUserDefaults] boolForKey:@"user_loginStatus"];
    MOLUserModel *user = [self user_getUserInfo];
    return status && user.userId.length;
}

/// 获取用户是否需要完善信息
- (BOOL)user_needCompleteInfo
{
    MOLUserModel *user = [self user_getUserInfo];
    if (user.sex > 0) {
        return NO;
    }else{
        return YES;
    }
}


/// 获取用户是否管理员
- (BOOL)user_isPower
{
    if (![self user_isLogin]) {
        return NO;
    }
    MOLUserModel *user = [self user_getUserInfo];
    if (user.power == 1) {
        return YES;
    }else{
        return NO;
    }
}

/// 保存和获取用户最近使用的名字
- (void)user_saveUserLastNameWithName:(NSString *)name
{
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"user_lastUserName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSString *)user_getUserLastName
{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_lastUserName"];
    return name;
}

/// 保存用户信息
- (void)user_saveUserInfoWithModel:(MOLUserModel *)user
{
//    NSString *filename = [NSString mol_creatFileWithFileName:@"mol_userInfo"];
    NSString *filename = [NSString mol_creatNSDocumentFileWithFileName:@"mol_userInfo"]; // 用户异常退出的bug
    
    if (!user.userId.integerValue) {
        [MOLToast toast_showWithWarning:YES title:@"用户信息异常,重新登录"];
        return;
    }
    
    BOOL status = [NSKeyedArchiver archiveRootObject:user toFile:filename];
    if (!status) {
        [self user_resetUserInfo];
        [MOLToast toast_showWithWarning:YES title:@"信息保存失败,重新登录"];
    }
}

// mol_creatNSDocumentFileWithFileName
/// 获取用户信息
- (MOLUserModel *)user_getUserInfo
{
//    NSString *filename = [NSString mol_creatFileWithFileName:@"mol_userInfo"];
    NSString *filename = [NSString mol_creatNSDocumentFileWithFileName:@"mol_userInfo"]; // 用户异常退出的bug
    // 读取本地缓存数据
    MOLUserModel *user = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    if (user) {
        return user;
    }else{
        return nil;
    }
}

/// 清除用户信息
- (void)user_resetUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_lastUserName"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_loginStatus"];
//    [self user_saveLoginWithStatus:NO];
    [JPUSHService deleteAlias:nil seq:0];
//    NSString *filename = [NSString mol_creatFileWithFileName:@"mol_userInfo"];
    NSString *filename = [NSString mol_creatNSDocumentFileWithFileName:@"mol_userInfo"];  // 用户异常退出的bug
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:filename];
    if (bRet) {
        NSError *err;
        [fileMgr removeItemAtPath:filename error:&err];
    }
}
@end
