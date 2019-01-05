//
//  MOLJSBridgeHelper.m
//  aletter
//
//  Created by 徐天牧 on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLJSBridgeHelper.h"

#import <UMShare/UMShare.h>

#import <MJExtension.h>
#import "MOLHead.h"
#import "MOLShareManager.h"

@interface MOLJSBridgeHelper()

@end

@implementation MOLJSBridgeHelper
#pragma mark - JS调用  web页面需要的用户信息

//#pragma mark - JS调用 复制文字
- (void)shareWithCopyWord:(NSString *)jsonString
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [jsonString mj_JSONObject];
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        NSString *boardString = dic[@"copyString"];
        [board setString:boardString];
        if (board == nil) {
            
            [MBProgressHUD showSuccess:@"复制失败!"];
            
        }else {
            [MBProgressHUD showError:@"复制成功!"];
            
        }
    });
}
- (NSString *)getUserInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    dic[@"userId"] = user.userId;
    dic[@"appVersion"] = [STSystemHelper getApp_version];
    return [dic mj_JSONString];
}
//告诉H5发起分享
-(void)initiateH5Share{
    NSString *jsFun = @"Share";
    [self.webView evaluateJavaScript:jsFun completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}

#pragma mark - h5启动传值给h5
- (void)getAppStarts {
    
    NSString *jsFun = [NSString stringWithFormat:@"APP_data('%@')",[self getUserInfo]];
    [self.webView evaluateJavaScript:jsFun completionHandler:^(id _Nullable item, NSError * _Nullable error) {
        
    }];
}

//#pragma mark - 2.6.4 分享
- (void)shareActive:(NSString *)jsonString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *dic = [jsonString mj_JSONObject];
        
        MOLShareModel *moldel = [MOLShareModel mj_objectWithKeyValues:dic];
        
        [[MOLShareManager share] shareWithModel:moldel];
    });
}


@end
