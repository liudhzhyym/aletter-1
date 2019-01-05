//
//  MOLMessageRequest.h
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLNetRequest.h"
#import "MOLChatGroupModel.h"
#import "MOLSystemGroupModel.h"
#import "MOLNotificationGroupModel.h"
#import "CIMSUCModel.h"
#import "ChatDetailModel.h"
#import "CIMUserMsg.h"

@interface MOLMessageRequest : MOLNetRequest

/// 会话列表
- (instancetype)initRequest_messageListWithParameter:(NSDictionary *)parameter;

/// 查询帖子下的会话是否存在
- (instancetype)initRequest_checkChatWithParameter:(NSDictionary *)parameter;

/// 发布私聊
- (instancetype)initRequest_publishMessageWithParameter:(NSDictionary *)parameter;

/// 查询会话详情
- (instancetype)initRequest_chatStoryInfoWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 会话内容
- (instancetype)initRequest_messageContentWithParameter:(NSDictionary *)parameter;

/// 系统、互动通知
- (instancetype)initRequest_systemNotiWithParameter:(NSDictionary *)parameter;

/// 系统、互动通知详细内容
- (instancetype)initRequest_notifacationCotiContentWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 关闭对话
- (instancetype)initRequest_closeChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 重新打开会话
- (instancetype)initRequest_openChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 同意打开会话
- (instancetype)initRequest_agreeOpenChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 删除私聊
- (instancetype)initRequest_deleteChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;

/// 互动通知已读
- (instancetype)initRequest_readInteractWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId;
@end
