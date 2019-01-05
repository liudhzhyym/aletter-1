//
//  MOLMineMailModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMailModel.h"

@implementation MOLMineMailModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"storyList":[MOLStoryModel class]
             };
}
@end
