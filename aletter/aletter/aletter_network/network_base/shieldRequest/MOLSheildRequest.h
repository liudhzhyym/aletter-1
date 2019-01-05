//
//  MOLSheildRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLSheildGroupModel.h"

@interface MOLSheildRequest : MOLNetRequest

/// 屏蔽列表
- (instancetype)initRequest_sheildListWithParameter:(NSDictionary *)parameter;

/// 增加屏蔽
- (instancetype)initRequest_addSheildWithParameter:(NSDictionary *)parameter;
/// 删除屏蔽
- (instancetype)initRequest_deleteSheildWithParameter:(NSDictionary *)parameter;
@end
