//
//  MOLPrisonRequest.h
//  aletter
//
//  Created by 徐天牧 on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"

@interface MOLPrisonRequest : MOLNetRequest

/// 封号到期时间
- (instancetype)initRequest_PrisonWithParameter:(NSDictionary *)parameter;
@end
