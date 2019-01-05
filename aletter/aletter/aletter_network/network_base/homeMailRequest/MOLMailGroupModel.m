//
//  MOLMailGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailGroupModel.h"

@implementation MOLMailGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLMailChannelModel class]
             };
}
@end
