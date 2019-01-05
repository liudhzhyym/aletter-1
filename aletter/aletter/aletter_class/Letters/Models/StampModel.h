//
//  StampModel.h
//  aletter
//
//  Created by xujin on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"


@interface StampModel : MOLBaseModel
@property (nonatomic, copy)NSString *name; //邮票名称
@property (nonatomic, copy)NSString *lightImage; //可选邮票图标
@property (nonatomic, copy)NSString *darkImage; //不可选邮票图标
@property (nonatomic, copy)NSString *inviteCount; //用户邀请数量
@property (nonatomic, assign)BOOL isSelectStatus; //状态 yes已选 No未选
@property (nonatomic, copy)NSString *isAuthority; //权限 1 有选择权 0无选择权
@property (nonatomic, copy)NSString * stampId;

@end
