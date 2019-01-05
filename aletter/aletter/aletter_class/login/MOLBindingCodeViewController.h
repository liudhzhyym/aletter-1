//
//  MOLBindingCodeViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLBindingCodeViewController : MOLBaseViewController
@property (nonatomic, strong) NSString *phoneString;
@property (nonatomic, assign) NSInteger bindingType;  // 1 绑定（注册账户）  2 绑定（绑定账户）
@end
