//
//  MOLChatViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
@class MOLStoryModel,MOLChatModel,MOLLightUserModel;

@interface MOLChatViewController : MOLBaseViewController
/**
 1.建立会话存在会话chatId 未建立会话时，无会话chatId
 2.前期根据storyID帖子id，toUserId私聊对象，用户userid三个确认消息唯一
 */
@property (nonatomic,copy)NSString *chatId; //会话id
@property (nonatomic,strong)MOLStoryModel *storyModel;
@property (nonatomic,assign)MOLLightUserModel *userModel; //1表示已建立会话 0表示未建立会话 默认0
@end
