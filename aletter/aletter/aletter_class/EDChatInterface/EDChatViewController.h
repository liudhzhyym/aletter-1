//
//  EDChatViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "EDChatTableView.h"
#import "MOLStoryModel.h"
#import "MOLLightUserModel.h"

@interface EDChatViewController : MOLBaseViewController 
@property (nonatomic, strong) MOLLightUserModel *toUser;   // 和谁聊天
@property (nonatomic, strong) MOLStoryModel *storyModel;  // 会话帖子 (第一次建立聊天的时候才传，其余时候传chatId)
@property (nonatomic, strong) NSString *chatId;  // 会话id （非第一次聊天）

@property (nonatomic, assign) NSInteger vcType; // 0 正常聊天  1 给有封信建议 2 申诉

@property (nonatomic, strong) void(^refreshLastMessage)(NSString *message,NSString *type,BOOL isClose);
@end
