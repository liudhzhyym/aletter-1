//
//  MOLNotificationGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNotificationGroupModel.h"

@implementation MOLNotificationGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLNotificationModel class]
             };
}
@end
