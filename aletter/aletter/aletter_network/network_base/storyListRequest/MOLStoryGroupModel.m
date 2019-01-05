//
//  MOLStoryGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryGroupModel.h"

@implementation MOLStoryGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"storyList":[MOLStoryModel class],
             @"resBody":[MOLStoryModel class]
             };
}

@end
