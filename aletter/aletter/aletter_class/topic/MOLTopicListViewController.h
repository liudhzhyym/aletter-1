//
//  MOLTopicListViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
@class MOLLightTopicModel;
@interface MOLTopicListViewController : MOLBaseViewController
@property (nonatomic, strong) NSString *channelId;  // 频道（邮箱）ID
@property (nonatomic, assign) BOOL isChooseTopic;
@property (nonatomic, strong) void(^chooseBlock)(MOLLightTopicModel *model);
@end
