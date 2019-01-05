//
//  MOLExitViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLExitViewController : MOLBaseViewController
@property (nonatomic, strong) void(^exitBlock)(void);
@end
