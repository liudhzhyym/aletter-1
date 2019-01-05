//
//  MOLCheckInfoViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLCheckInfoViewModel : MOLBaseViewModel

@property (nonatomic, strong) NSString *sexString;  // 性别
@property (nonatomic, strong) NSString *ageString;  // 年龄段
@property (nonatomic, strong) NSString *schoolString;  // 学校

@property (nonatomic, strong) RACCommand *sexInfoCommand;     // 获取性别数据
@property (nonatomic, strong) RACCommand *ageInfoCommand;     // 获取年龄段数据
@property (nonatomic, strong) RACCommand *schoolInfoCommand;     // 获取学校数据
@property (nonatomic, strong) RACCommand *checkInfoCommand;   // 获取确认信息数据
@property (nonatomic, strong) RACCommand *commitInfoCommand;  // 提交数据

@end
