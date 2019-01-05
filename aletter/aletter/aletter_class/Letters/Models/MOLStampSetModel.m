//
//  MOLStampSetModel.m
//  aletter
//
//  Created by xujin on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStampSetModel.h"
#import "StampModel.h"

@implementation MOLStampSetModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"stampList":[StampModel class]
             };
}
@end
