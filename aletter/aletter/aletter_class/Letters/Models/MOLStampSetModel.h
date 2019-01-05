//
//  MOLStampSetModel.h
//  aletter
//
//  Created by xujin on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"

@interface MOLStampSetModel : MOLBaseModel
@property (nonatomic, copy) NSString *allInviteCount;
@property (nonatomic, copy) NSString *getStampCount;
@property (nonatomic, strong) NSArray *stampList;
@end
