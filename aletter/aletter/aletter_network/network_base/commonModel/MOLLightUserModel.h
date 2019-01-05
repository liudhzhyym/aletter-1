//
//  MOLLightUserModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"

@interface MOLLightUserModel : MOLBaseModel
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *commentName;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, strong) NSString *school;
/**
 * 私聊权限设置（会话页面右上角...）： 1有权限显示 0没有权限不显示
 */
@property (nonatomic, assign) NSInteger canClose;
@end
