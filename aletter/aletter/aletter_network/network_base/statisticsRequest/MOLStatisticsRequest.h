//
//  MOLStatisticsRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/9/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"

@interface MOLStatisticsRequest : MOLNetRequest

/// 播放主贴统计
- (instancetype)initRequest_statisticsPlayStoryWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;
@end
