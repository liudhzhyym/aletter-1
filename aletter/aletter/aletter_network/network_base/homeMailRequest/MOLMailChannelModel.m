//
//  MOLMailChannelModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailChannelModel.h"

@implementation MOLMailChannelModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"channelVOList":[MOLMailModel class]
             };
}
@end
