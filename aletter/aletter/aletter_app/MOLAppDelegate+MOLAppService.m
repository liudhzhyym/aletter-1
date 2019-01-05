//
//  MOLAppDelegate+MOLAppService.m
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLAppDelegate+MOLAppService.h"
#import "STSystemHelper.h"
#import <iflyMSC/IFlyMSC.h>
#import <UserNotifications/UserNotifications.h>

#import "MOLStoryDetailViewController.h"
#import "MOLMailDetailViewController.h"

@implementation MOLAppDelegate (MOLAppService)

#pragma mark - 友盟
/// 注册友盟
- (void)app_registUmeng
{
    // 三方分享、登录
    [self Umeng_confitUShareSettings];
    [self Umeng_configUSharePlatforms];
    
    // 友盟统计
    [self Umeng_configAnalyticsPlatforms];
}

- (void)Umeng_configAnalyticsPlatforms
{
    NSInteger platformType = [MOLSystemManager system_platformType];
    if (platformType == UIDeviceSimulator ||
        platformType == UIDeviceSimulatoriPhone ||
        platformType == UIDeviceSimulatoriPad ||
        platformType == UIDeviceSimulatorAppleTV) {
        // 模拟器不初始化友盟统计
        return;
    }
    
    [UMConfigure initWithAppkey:@"5b6919ad8f4a9d587100020a" channel:@"App Store"];
}

- (void)Umeng_configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx85e220079a9f0209" appSecret:@"d92ab7966b96a84d572361fb4d8bef6e" redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1107697829"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];// 3NKle44axynkGeHR
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1105092489"  appSecret:@"58f558d7dc88852bdb4e4b34f75d8925" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
}

- (void)Umeng_confitUShareSettings
{
    [[UMSocialManager defaultManager] openLog:NO];
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"5b6919ad8f4a9d587100020a"];
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
}

/// 友盟的回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

#pragma mark - bugly
/// 注册bugly
- (void)app_registBugly
{
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.reportLogLevel = BuglyLogLevelWarn;
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 2;
    config.unexpectedTerminatingDetectionEnable = YES;
    config.version = [STSystemHelper getApp_version];
    config.deviceIdentifier = [NSString stringWithFormat:@"%@ %@",[STSystemHelper iphoneNameAndVersion], [[UIDevice currentDevice] systemVersion]];
    if (user.userId.length) {
        [Bugly setUserIdentifier:user.userId];
    }
    [Bugly startWithAppId:@"5b18153ae0" config:config];
}

#pragma mark - 讯飞
/// 注册讯飞
- (void)app_registIFly
{
    [IFlyDebugLog setShowLog:NO];
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"5b73cf1e"]; //5b73cf1e
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark - 极光
/// 注册极光
- (void)app_registJpush:(NSDictionary *)launchOptions
{
    // 初始化APNS
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    BOOL isP = NO;
#ifdef MOL_TEST_HOST
    isP = YES;
#endif
    // 初始化极光push
    NSString *jpushKey = @"2b9e909c2cc425f7c972a128";
    // 获取bundleId
    NSString *bundleId = [STSystemHelper getApp_bundleid];
    if ([bundleId containsString:@"Dev"]) {
        jpushKey = @"22107acec4f8855730d34cb3";
    }
    [JPUSHService setupWithOption:launchOptions appKey:jpushKey
                          channel:MOL_APPStore
                 apsForProduction:isP
            advertisingIdentifier:nil];
    [JPUSHService setLogOFF];
    
    if (iOS10) {}else{  // ios10 以下的系统kill掉app收到推送后走这
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (userInfo[@"_j_business"]) {
            // 处理极光push消息
        }
    }
    
    // 极光透传消息
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

// 极光透传
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    // 解析服务器数据
    NSDictionary *dic = notification.userInfo;
    
    // msgType :1系统推送 2评论推送 3点赞推送 4私聊推送5关闭会话 6重新发起会话
    // type    : chat /
    if (dic[@"_j_msgid"]) {
        NSDictionary *ext = dic[@"extras"];
        NSInteger type = [ext[@"msgType"] integerValue];
        NSString *subtype = ext[@"type"];
        NSString *chatId = ext[@"typeId"];
        
        if (type == 4 || type == 5 || type == 6) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ALETTER_PUSH_MESSAGE" object:ext];
        }
        if (type != 5 && type != 6) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ALETTER_PUSH" object:nil];
        }
    }
    
}

#pragma mark - JPUSHRegisterDelegate
// iOS 10 Support 前台
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler
{
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
//        [self push_receiveService:userInfo];
    }
    
}

// iOS 10 Support 后台 或者 kill掉
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [self push_receiveService:userInfo];
    }
    
    completionHandler();  // 系统要求执行这个方法
}

// iOS 7、8、9收到远程通知（后台）
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if (application.applicationState == UIApplicationStateActive) {  // 前台
        
    }else{   // 后台
        
    }
    [self push_receiveService:userInfo];
}

// 处理服务器消息体
- (void)push_receiveService:(NSDictionary *)userInfo{
    
    if (userInfo[@"_j_msgid"]) {
        NSDictionary *ext = userInfo;
        NSInteger msgType = [ext[@"msgType"] integerValue];
        NSString *subtype = ext[@"type"];
        NSString *chatId = ext[@"typeId"];
        NSInteger systemType = [ext[@"systemType"] integerValue];
        
        if (msgType != 1) {
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (systemType == 0) {  // 跳转
                if ([subtype isEqualToString:@"story"]) {
                    MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
                    vc.storyId = chatId;
                    [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
                }else if ([subtype isEqualToString:@"channel"]){
                    MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
                    vc.channelId = chatId;
                    [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
                }else if ([subtype isEqualToString:@"topic"]){
                    MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
                    vc.topicId = chatId;
                    [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
                }
            }
        });
    }
}
@end
