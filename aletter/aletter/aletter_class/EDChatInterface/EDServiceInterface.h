//
//  EDServiceInterface.h
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDBaseMessageModel.h"

@protocol EDServiceInterfaceDelegate <NSObject>

/**
 * 发送消息结果
 */
- (void)interface_sendMessageResultWithNewMsgId:(NSString *)newMsgId
                                       oldMsgId:(NSString *)oldMsgId
                                     newMsgDate:(NSDate *)newMsgDate
                                  newMsgContent:(id)newMsgContent
                                     sendStatus:(MessageSendStatusType)status;

/**
 * 收到历史消息
 */
- (void)interface_didReceiveHistoryMessages:(NSArray *)messages;


/**
 *  收到获取历史消息的错误
 */
- (void)interface_getLoadHistoryMessageError;


/**
 * 收到新消息
 */
- (void)interface_didReceiveNewMessages:(NSArray *)messages;

@end

@interface EDServiceInterface : NSObject

@property (nonatomic, weak) id<EDServiceInterfaceDelegate> serviceInterfaceDelegate;

/**
 * 从服务端获取更多消息
 */
+ (void)interfaceGetHistoryMessageWithParameter:(NSDictionary *)para
                                       delegate:(id<EDServiceInterfaceDelegate>)delegate;

/**
 * 收到新消息 - 从服务器拉取
 */
+ (void)interfaceGetNewMessageWithParameter:(NSDictionary *)para
                                       delegate:(id<EDServiceInterfaceDelegate>)delegate;

/**
 * 发送文字消息
 */
+ (void)interfaceSendTextMessageWithContent:(NSString *)content
                                 localMsgId:(NSString *)localMsgId
                                       user:(NSDictionary *)user
                                   delegate:(id<EDServiceInterfaceDelegate>)delegate;

/**
 * 发送图片消息
 */
+ (void)interfaceSendTextMessageWithImage:(NSString *)image
                                 localMsgId:(NSString *)localMsgId
                                     user:(NSDictionary *)user
                                   delegate:(id<EDServiceInterfaceDelegate>)delegate;

/**
 * 发送语音消息
 */
+ (void)interfaceSendTextMessageWithAudio:(NSString *)audio
                                 localMsgId:(NSString *)localMsgId
                                     user:(NSDictionary *)user
                                   delegate:(id<EDServiceInterfaceDelegate>)delegate;
@end
