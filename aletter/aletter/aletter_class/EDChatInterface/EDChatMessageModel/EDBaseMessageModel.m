//
//  EDBaseMessageModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDBaseMessageModel.h"
#import "MOLHead.h"

@implementation EDBaseMessageModel

- (MessageFromType)fromType
{
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if ([user.userId isEqualToString:self.userId]) {
        return MessageFromType_me;
    }
    return MessageFromType_other;
}
- (CGFloat)getCellHeight{return 0;}
@end
