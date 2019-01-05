//
//  MOLSchoolGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/9/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSchoolGroupModel.h"

@implementation MOLSchoolGroupModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLSchoolModel class]
             };
}
@end
