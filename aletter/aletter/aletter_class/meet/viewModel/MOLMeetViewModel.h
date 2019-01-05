//
//  MOLMeetViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLMeetViewModel : MOLBaseViewModel
@property (nonatomic, strong) RACCommand *meetStoryListCommand;  // 遇见帖子列表
@end
