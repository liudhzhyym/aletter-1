//
//  MOLCommentGroupModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLCommentGroupModel.h"

@implementation MOLCommentGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"commentList":[MOLCommentModel class]
             };
}
@end
