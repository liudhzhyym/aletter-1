//
//  CIMSUCModel.m
//  aletter
//
//  Created by xujin on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "CIMSUCModel.h"

@implementation CIMSUCModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[CIMUserMsg class]
             };
}
@end
