//
//  MOLTopicListViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLTopicListViewModel : MOLBaseViewModel
@property (nonatomic, strong) RACCommand *topicListCommand;
@end
