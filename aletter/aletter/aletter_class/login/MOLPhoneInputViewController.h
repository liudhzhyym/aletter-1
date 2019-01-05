//
//  MOLPhoneInputViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLPhoneInputViewController : MOLBaseViewController
@property (nonatomic, assign) NSInteger type;  // 0 手机登录  1 三方绑定手机(注册账号) 2 三方绑定手机(绑定账户)
@end
