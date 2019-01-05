//
//  MOLAdminRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/9/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"

@interface MOLAdminRequest : MOLNetRequest

/// 隐藏主贴
- (instancetype)initRequest_adminHideStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;
@end
