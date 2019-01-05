//
//  EDBaseMessageModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLStoryModel.h"
#import "MOLLightUserModel.h"

@class EDBaseChatCell;


//定义cell中的布局
/**
 * cell的content字体大小
 */
static CGFloat const kEDCellContentTitleFont = 14.0;
/**
 * cell的左右间距
 */
static CGFloat const kEDCellHorizontalEdgeSpacing = 20.0;
/**
 * cell的上下间距
 */
static CGFloat const kEDCellVerticalEdgeSpacing = 10.0;
/**
 * 气泡的左右间距
 */
static CGFloat const kEDBubbleHorizontalEdgeSpacing = 15.0;
/**
 * 气泡的上下间距
 */
static CGFloat const kEDBubbleVerticalEdgeSpacing = 10.0;

/**
 *  message的来源枚举定义
 *  MQChatMessageIncoming - 收到的消息
 *  MQChatMessageOutgoing - 发送的消息
 */
typedef NS_ENUM(NSUInteger, MessageFromType) {
    MessageFromType_me,
    MessageFromType_other
};

typedef NS_ENUM(NSUInteger, MessageSendStatusType) {
    MessageSendStatusType_success,
    MessageSendStatusType_sending,
    MessageSendStatusType_failure,
};

@interface EDBaseMessageModel : NSObject

/** 消息id */
@property (nonatomic, copy) NSString *logId;

/** 用户id */
@property (nonatomic, copy) NSString *userId;

/** 用户id */
@property (nonatomic, copy) NSString *userName;

/** 消息的来源类型 */
@property (nonatomic, assign) MessageFromType fromType;

/** 消息内容 */
@property (nonatomic, copy) NSString *content;

/** 消息类型 */
@property (nonatomic, assign) NSInteger chatType; // 消息类型 0 文字 1图片 2语音 3 帖子 10 时间 

/** 消息已读 */
@property (nonatomic, assign) BOOL isRead;

/** 消息时间 */
@property (nonatomic, copy) NSString *createTime;


@property (nonatomic, assign) CGRect iconImageViewFrame;  // 头像（暂时没用）
@property (nonatomic, assign) CGRect bubbleImageFrame; // 别人的气泡
@property (nonatomic, assign) CGRect sendingIndicatorFrame;  // 发送状态
@property (nonatomic, assign) CGRect failureIndicatorFrame;  // 发送失败状态


/** 消息发送的状态 */
@property (nonatomic, assign) MessageSendStatusType sendStatus;

- (EDBaseChatCell *)getCellWithReuseIdentifier:(NSString *)identifier;

- (CGFloat)getCellHeight;


/* -------------------------------------- 帖子 --------------------------------------*/
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, assign) NSInteger isClose;    // 0 未关闭  1 已关闭  2 申请重新开启 3 举报关闭
@property (nonatomic, strong) NSString *closeUserId;
@property (nonatomic, strong) MOLLightUserModel *ownUser;
@property (nonatomic, strong) MOLStoryModel *storyVO;
@property (nonatomic, strong) MOLLightUserModel *toUser;

@property (nonatomic, strong) NSString *storyId;
@end
