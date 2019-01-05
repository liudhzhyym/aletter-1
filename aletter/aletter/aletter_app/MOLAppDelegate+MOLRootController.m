//
//  MOLAppDelegate+MOLRootController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLAppDelegate+MOLRootController.h"
#import "MOLHomeViewController.h"
#import "MOLBaseNavigationController.h"

@implementation MOLAppDelegate (MOLRootController)

/// 设置广告跟控制器
- (void)app_setADRootViewController
{
    
}

/// 设置首页跟控制器
- (void)app_setHomeRootViewController
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    MOLHomeViewController *vc = [[MOLHomeViewController alloc] init];
    MOLBaseNavigationController *nav = [[MOLBaseNavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}
@end
