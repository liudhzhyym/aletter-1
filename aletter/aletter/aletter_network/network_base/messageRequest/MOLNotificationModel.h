//
//  MOLNotificationModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/23.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseModel.h"
#import "MOLLightTopicModel.h"
#import "MOLMailModel.h"
#import "MOLStoryModel.h"
#import "MOLCommentModel.h"
#import "MOLChatModel.h"

@interface MOLNotificationModel : MOLBaseModel
@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *msgType;  // 1 系统通知  2 评论互动通知   3 喜欢互动通知
@property (nonatomic, strong) NSString *pushType;  // 类型 h5 、 channel 、
@property (nonatomic, strong) NSString *systemType;  // 通知类型 0普通分享  1违反  2 回收站  3举报
@property (nonatomic, strong) NSString *outUrlId;  //  跳转id
@property (nonatomic, strong) NSString *unReadNum;
@property (nonatomic, strong) NSString *textContent;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) MOLMailModel *channelVO;
@property (nonatomic, strong) MOLLightTopicModel *topicVO;
@property (nonatomic, strong) MOLStoryModel *storyVO;
@property (nonatomic, strong) MOLCommentModel *commentVO;
@property (nonatomic, strong) MOLChatModel *chatVO;

@property (nonatomic, assign) CGFloat systemNotiCellHeight;  // 系统通知的cell高度
@property (nonatomic, assign) CGFloat interactNotiCellHeight;  // 互动通知的cell高度

@end
