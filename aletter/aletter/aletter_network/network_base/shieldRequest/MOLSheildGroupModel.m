//
//  MOLSheildGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSheildGroupModel.h"

@implementation MOLSheildGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLSheildModel class]
             };
}
@end
