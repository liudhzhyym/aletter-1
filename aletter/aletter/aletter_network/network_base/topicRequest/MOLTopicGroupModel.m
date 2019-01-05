//
//  MOLTopicGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLTopicGroupModel.h"

@implementation MOLTopicGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLLightTopicModel class]
             };
}
@end
