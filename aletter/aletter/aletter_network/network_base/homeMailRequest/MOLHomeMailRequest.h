//
//  MOLHomeMailRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLMailGroupModel.h"
#import "MOLCatogeryGroupModel.h"

@interface MOLHomeMailRequest : MOLNetRequest

/// 获取频道类别列表
- (instancetype)initRequest_channelCatogeryWithParameter:(NSDictionary *)parameter;

/// 获取频道列表
- (instancetype)initRequest_channelListWithParameter:(NSDictionary *)parameter;

/// 获取版本更新
- (instancetype)initRequest_versionCheckWithParameter:(NSDictionary *)parameter;

/// 获取AD
- (instancetype)initRequest_adWithParameter:(NSDictionary *)parameter;
@end
