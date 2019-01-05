//
//  MOLOldNameGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/16.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLOldNameGroupModel.h"

@implementation MOLOldNameGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLOldNameModel class]
             };
}
@end
