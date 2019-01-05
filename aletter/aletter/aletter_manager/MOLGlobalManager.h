//
//  MOLGlobalManager.h
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOLBaseViewController.h"
#import "MOLBaseNavigationController.h"

@interface MOLGlobalManager : NSObject
+ (instancetype)shareGlobalManager;

// 获取根控制器
- (MOLBaseViewController *)global_rootViewControl;
- (MOLBaseNavigationController *)global_rootNavigationViewControl;

// 获取当前控制器
- (UIViewController *)global_currentViewControl;
- (UINavigationController *)global_currentNavigationViewControl;

// 登录选择控制器
- (void)global_modalChooseViewController;

// 确认信息控制器
- (void)global_modalInfoCheckViewControllerWithAnimated:(BOOL)animated;
@end
