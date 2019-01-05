//
//  MOLSearchSchoolViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/9/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLSearchSchoolViewController : MOLBaseViewController
@property (nonatomic, strong) void(^schoolBlock)(NSString *school);
@property (nonatomic, assign) NSInteger enterType;  // 0  1 设置界面
@property (nonatomic, assign) NSInteger changeNum;  // 名字的修改次数（设置界面用的）
@end


