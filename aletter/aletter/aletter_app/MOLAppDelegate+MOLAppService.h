//
//  MOLAppDelegate+MOLAppService.h
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLAppDelegate.h"
#import "MOLHead.h"

@interface MOLAppDelegate (MOLAppService) <JPUSHRegisterDelegate>

/// 注册bugly
- (void)app_registBugly;
/// 注册友盟
- (void)app_registUmeng;
/// 注册极光
- (void)app_registJpush:(NSDictionary *)launchOptions;
/// 注册讯飞
- (void)app_registIFly;
@end
