//
//  MOLCatogeryGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLCatogeryGroupModel.h"

@implementation MOLCatogeryGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[MOLCatogeryModel class]
             };
}
MJCodingImplementation
@end
