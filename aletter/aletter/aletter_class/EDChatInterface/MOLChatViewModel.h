//
//  MOLChatViewModel.h
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOLHead.h"

@interface MOLChatViewModel : NSObject
@property (nonatomic, strong) RACCommand *closeChatCommand;  // 关闭对话
@property (nonatomic, strong) RACCommand *openChatCommand;   // 重新打开对话
@property (nonatomic, strong) RACCommand *agreeChatCommand;   // 同意重新打开对话
@property (nonatomic, strong) RACCommand *reportChatCommand;   // 举报对话
@end
