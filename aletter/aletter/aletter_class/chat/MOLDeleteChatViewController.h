//
//  MOLDeleteChatViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLChatModel.h"
#import "MOLSystemModel.h"
@interface MOLDeleteChatViewController : MOLBaseViewController
@property (nonatomic, strong) MOLChatModel *chatModel;
//@property (nonatomic, strong) MOLSystemModel *sysModel;
@property (nonatomic, strong) void(^deleteChatBlock)(void);
@end
