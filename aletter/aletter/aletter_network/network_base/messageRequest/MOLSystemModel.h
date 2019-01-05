//
//  MOLSystemModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
/*
    消息列表的model
 */

#import "MOLBaseModel.h"

@interface MOLSystemModel : MOLBaseModel

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *msgType;
@property (nonatomic, strong) NSString *unReadNum;
@property (nonatomic, strong) NSString *createTime;
@end
