//
//  MOLGlobalManager.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLGlobalManager.h"
#import "MOLHead.h"
#import "MOLChooseLoginViewController.h"
#import "MOLInfoCheckViewController.h"

@implementation MOLGlobalManager
+ (instancetype)shareGlobalManager
{
    static MOLGlobalManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[MOLGlobalManager alloc] init];
            
        }
    });
    return instance;
}

// 获取根控制器
- (MOLBaseViewController *)global_rootViewControl
{
    MOLBaseNavigationController *nav = (MOLBaseNavigationController *)MOLAppDelegateWindow.rootViewController;
    return (MOLBaseViewController *)nav.topViewController;
}
- (MOLBaseNavigationController *)global_rootNavigationViewControl
{
    MOLBaseNavigationController *nav = (MOLBaseNavigationController *)MOLAppDelegateWindow.rootViewController;
    return nav;
}


// 获取当前控制器
- (UIViewController *)global_currentViewControl
{
    return [self currentViewController];
}

- (UINavigationController *)global_currentNavigationViewControl
{
    return [self global_currentViewControl].navigationController;
}

// 获取当前控制器
- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
    MOLBaseNavigationController *vc = [[MOLGlobalManager shareGlobalManager] global_rootNavigationViewControl];
    return [self findBestViewController:vc];
}


// 登录选择控制器
- (void)global_modalChooseViewController
{
    MOLChooseLoginViewController *vc = [[MOLChooseLoginViewController alloc] init];
    MOLBaseNavigationController *nav = [[MOLBaseNavigationController alloc] initWithRootViewController:vc];
    [[self global_rootNavigationViewControl] presentViewController:nav animated:YES completion:nil];
}

// 确认信息控制器
- (void)global_modalInfoCheckViewControllerWithAnimated:(BOOL)animated
{
    MOLInfoCheckViewController *vc = [[MOLInfoCheckViewController alloc] init];
    MOLBaseNavigationController *nav = [[MOLBaseNavigationController alloc] initWithRootViewController:vc];
    [[self global_rootNavigationViewControl] presentViewController:nav animated:animated completion:nil];
}
@end
