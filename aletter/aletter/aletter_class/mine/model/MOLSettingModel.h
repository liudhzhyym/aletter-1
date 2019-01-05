//
//  MOLSettingModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"

@interface MOLSettingModel : MOLBaseModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *subName;
@property (nonatomic, assign) NSInteger type;   // 0 文字  1 图片  2 文字+图片 3 其他
@property (nonatomic, strong) void (^actionBlock)(void);
@end
