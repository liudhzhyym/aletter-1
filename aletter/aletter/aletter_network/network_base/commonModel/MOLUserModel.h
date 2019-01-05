//
//  MOLUserModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.


/*
    用在登录注册返回的用户信息的model
 */

#import "MOLBaseModel.h"

@interface MOLUserModel : MOLBaseModel
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *age;
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, strong) NSString *commentName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *reportLevel;
@property (nonatomic, assign) NSInteger power;
@property (nonatomic, assign) NSInteger schoolNum;
@property (nonatomic, strong) NSString *school;
@end
