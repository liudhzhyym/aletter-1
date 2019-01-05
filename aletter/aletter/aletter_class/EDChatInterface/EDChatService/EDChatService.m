//
//  EDChatService.m
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDChatService.h"
#import "EDServiceInterface.h"
#import "MOLToast.h"

@interface EDChatService () <EDServiceInterfaceDelegate>

@end

@implementation EDChatService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellModels = [NSMutableArray array];
    }
    return self;
}

#pragma mark - EDServiceInterfaceDelegate
/**
 * 发送消息结果
 */
- (void)interface_sendMessageResultWithNewMsgId:(NSString *)newMsgId
                                       oldMsgId:(NSString *)oldMsgId
                                     newMsgDate:(NSDate *)newMsgDate
                                  newMsgContent:(id)newMsgContent
                                     sendStatus:(MessageSendStatusType)status
{
    if (status == MessageSendStatusType_success) {
        if ([self.ServiceDelegate respondsToSelector:@selector(service_sendMessageResultWithisResult:messageId:messageBody:)]) {
            [self.ServiceDelegate service_sendMessageResultWithisResult:YES messageId:newMsgId messageBody:newMsgContent];
        }
    }else{
        if ([self.ServiceDelegate respondsToSelector:@selector(service_sendMessageResultWithisResult:messageId:messageBody:)]) {
            [self.ServiceDelegate service_sendMessageResultWithisResult:NO messageId:nil messageBody:nil];
        }
    }
}

/**
 * 收到历史消息
 */
- (void)interface_didReceiveHistoryMessages:(NSArray *)messages
{
    if (!messages.count) {
//        [MOLToast toast_showWithWarning:NO title:@"没有更多数据"];
    }
    
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange: NSMakeRange(0, messages.count)];
    [self.cellModels insertObjects:messages atIndexes:set];
    if ([self.ServiceDelegate respondsToSelector:@selector(service_didGetHistoryMessages)]) {
        [self.ServiceDelegate service_didGetHistoryMessages];
    }
}


/**
 *  收到获取历史消息的错误
 */
- (void)interface_getLoadHistoryMessageError
{
}

/**
 * 收到新消息
 */
- (void)interface_didReceiveNewMessages:(NSArray *)message
{
    [self.cellModels removeAllObjects];
    [self.cellModels addObjectsFromArray:message];
    if ([self.ServiceDelegate respondsToSelector:@selector(service_didReceiveMessageWithMsg:)]) {
        [self.ServiceDelegate service_didReceiveMessageWithMsg:message];
    }
}

#pragma mark - EDChatService方法
/**
 * 获取更多历史聊天消息
 */
- (void)serviceStartGettingHistoryMessagesWithChatId:(NSString *)chatId
{
    // 获取第一条id
    EDBaseMessageModel *model = self.cellModels.firstObject;
    for (NSInteger i = 0 ; i<self.cellModels.count; i++) {
        EDBaseMessageModel *m = self.cellModels[i];
        if ([m isKindOfClass:[EDTimeMessageModel class]] || [m isKindOfClass:[EDStoryMessageModel class]]) {
            continue;
        }
        model = m;
        break;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"chatId"] = chatId;
    dic[@"pageSize"] = @"20";
    dic[@"chatLogId"] = model.logId;
    [EDServiceInterface interfaceGetHistoryMessageWithParameter:dic delegate:self];
}

/**
 * 收到聊天消息
 */
- (void)serviceGettingNewMessagesWithChatId:(NSString *)chatId
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"chatId"] = chatId;
    dic[@"pageSize"] = @"20";
    [EDServiceInterface interfaceGetNewMessageWithParameter:dic delegate:self];
}

/**
 * 发送文字消息
 */
- (void)serviceSendTextMessageWithContent:(NSString *)content user:(NSDictionary *)user
{
    [EDServiceInterface interfaceSendTextMessageWithContent:content localMsgId:nil user:user delegate:self];
}

/**
 * 发送图片消息
 */
- (void)serviceSendImageMessageWithImage:(NSString *)image user:(NSDictionary *)user
{
    [EDServiceInterface interfaceSendTextMessageWithImage:image localMsgId:nil user:user delegate:self];
}

/**
 * 发送语音消息
 */
- (void)serviceSendVoiceMessageWithAMRFilePath:(NSString *)filePath user:(NSDictionary *)user
{
    [EDServiceInterface interfaceSendTextMessageWithAudio:filePath localMsgId:nil user:user delegate:self];
}

/**
 * 重新发送消息
 * @param index 需要重新发送的index
 * @param resendData 重新发送的字典 [text/image/voice : data]
 */
- (void)serviceResendMessageAtIndex:(NSInteger)index resendData:(NSDictionary *)resendData user:(NSDictionary *)user
{
    // 从本地移除该条数据
    
    // 如果前一条是时间cell 也一并移除
    
    // 然后才执行重新发送
    if (resendData[@"text"]) {
        [self serviceSendTextMessageWithContent:resendData[@"text"] user:user];
    }
    if (resendData[@"image"]) {
        [self serviceSendImageMessageWithImage:resendData[@"image"] user:user];
    }
    if (resendData[@"voice"]) {
        [self serviceSendVoiceMessageWithAMRFilePath:resendData[@"voice"] user:user];
    }
}

@end
