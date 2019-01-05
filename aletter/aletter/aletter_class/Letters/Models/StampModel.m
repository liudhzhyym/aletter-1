//
//  StampModel.m
//  aletter
//
//  Created by xujin on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "StampModel.h"

@implementation StampModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    
    return @{
             @"stampId" : @"id", // stampId 替换key   id
             @"isAuthority" : @"open", // isAuthority 替换key   open
             };
    
}
@end
