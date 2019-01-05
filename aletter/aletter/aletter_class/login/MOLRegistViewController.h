//
//  MOLRegistViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLHead.h"

@interface MOLRegistViewController : MOLBaseViewController
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, assign) NSInteger registType;  // 0 去注册  1 设置密码
@end
