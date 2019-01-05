//
//  MOLActionChatViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLActionChatViewController : MOLBaseViewController
@property (nonatomic, assign) NSInteger type;  // 0 举报对话 1 举报+关闭
@property (nonatomic, strong) void(^reportChatBlock)(NSString *reason);
@property (nonatomic, strong) void(^closeChatBlock)(void);
@end
