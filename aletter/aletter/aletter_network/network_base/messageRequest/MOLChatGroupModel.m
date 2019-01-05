//
//  MOLChatGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChatGroupModel.h"

@implementation MOLChatGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLChatModel class]
             };
}
@end
