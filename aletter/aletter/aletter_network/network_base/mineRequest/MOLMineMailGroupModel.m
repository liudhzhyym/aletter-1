//
//  MOLMineMailGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailGroupModel.h"
#import "MOLHead.h"

@implementation MOLMineMailGroupModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"resBody":[MOLMineMailModel class]
             };
}
@end
