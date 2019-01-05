//
//  MOLMineMessageViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewModel.h"
#import "MOLHead.h"

@interface MOLMineMessageViewModel : MOLBaseViewModel
@property (nonatomic, strong) RACCommand *messageListCommand;  // 消息列表
@property (nonatomic, strong) RACCommand *notiListCommand;  // 消息列表
@end
