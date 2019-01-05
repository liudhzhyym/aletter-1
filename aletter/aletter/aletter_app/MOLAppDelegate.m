//
//  MOLAppDelegate.m
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLAppDelegate.h"
#import "MOLHead.h"
#import "MOLAppDelegate+MOLAppService.h"
#import "MOLAppDelegate+MOLRootController.h"
#import "MOLWebViewController.h"
#import "MOLPhoneInputViewController.h"
#import "MOLLoginViewController.h"
#import "MOLRegistViewController.h"
#import "MOLBindingCodeViewController.h"

@implementation MOLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [AvoidCrash becomeEffective];
    
    // 配置ytk
    YTKNetworkAgent *agent = [YTKNetworkAgent sharedAgent];
    NSSet *acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", @"text/css", nil];
    NSString *keypath = @"jsonResponseSerializer.acceptableContentTypes";
    [agent setValue:acceptableContentTypes forKeyPath:keypath];
    
    // 加载manager
    [MOLGlobalManager shareGlobalManager];
    [MOLPlayVoiceManager sharePlayVoiceManager];
    [MOLALiyunManager shareALiyunManager];
    
    // 三方
    [self app_registBugly];
    [self app_registUmeng];
    [self app_registJpush:launchOptions];
    [self app_registIFly];
    
    // 根控制器
    [self app_setHomeRootViewController];
    
    return YES;
}

//获取DeviceToken成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    UIViewController *vc = [[MOLGlobalManager shareGlobalManager] global_currentViewControl];
    if ([vc isKindOfClass:[MOLPhoneInputViewController class]]
        || [vc isKindOfClass:[MOLLoginViewController class]]
        || [vc isKindOfClass:[MOLRegistViewController class]]
        || [vc isKindOfClass:[MOLBindingCodeViewController class]]) {   
        return NO;
    }
    return YES;
}
@end
