//
//  EDChatService.h
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EDTextMessageModel.h"
#import "EDImageMessageModel.h"
#import "EDAudioMessageModel.h"
#import "EDTimeMessageModel.h"
#import "EDStoryMessageModel.h"

@protocol EDChatServiceDelegate <NSObject>

/**
 *  发送消息回调
 *  @param resultStatus 是否成功
 */
- (void)service_sendMessageResultWithisResult:(BOOL)resultStatus messageId:(NSString *)messageId messageBody:(id)messageBody;

/**
 *  获取到了更多历史消息
 */
- (void)service_didGetHistoryMessages;

/**
 *  通知viewController收到了消息
 */
- (void)service_didReceiveMessageWithMsg:(id)messageBody;

@end

@interface EDChatService : NSObject

/** EDChatService的委托 */
@property (nonatomic, weak) id<EDChatServiceDelegate> ServiceDelegate;

/** cellModel的缓存 */
@property (nonatomic, strong) NSMutableArray *cellModels;

/**
 * 获取更多历史聊天消息
 */
- (void)serviceStartGettingHistoryMessagesWithChatId:(NSString *)chatId;

/**
 * 收到聊天消息
 */
- (void)serviceGettingNewMessagesWithChatId:(NSString *)chatId;

/**
 * 发送文字消息
 */
- (void)serviceSendTextMessageWithContent:(NSString *)content user:(NSDictionary *)user;

/**
 * 发送图片消息
 */
- (void)serviceSendImageMessageWithImage:(NSString *)image user:(NSDictionary *)user;

/**
 * 发送语音消息
 */
- (void)serviceSendVoiceMessageWithAMRFilePath:(NSString *)filePath user:(NSDictionary *)user;

/**
 * 重新发送消息
 * @param index 需要重新发送的index
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)serviceResendMessageAtIndex:(NSInteger)index resendData:(NSDictionary *)resendData user:(NSDictionary *)user;
@end
