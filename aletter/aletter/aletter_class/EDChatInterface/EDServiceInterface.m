//
//  EDServiceInterface.m
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDServiceInterface.h"
#import "MOLMessageRequest.h"
#import "MOLHead.h"
#import "EDBaseMessageModel.h"
#import "EDTextMessageModel.h"
#import "EDImageMessageModel.h"
#import "EDAudioMessageModel.h"
#import "EDTimeMessageModel.h"

@implementation EDServiceInterface


/**
 * 从服务端获取更多消息
 */
+ (void)interfaceGetHistoryMessageWithParameter:(NSDictionary *)para
                                       delegate:(id<EDServiceInterfaceDelegate>)delegate
{
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_messageContentWithParameter:para];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            NSMutableArray *arrM = [NSMutableArray array];
            
            NSArray *array = [request.responseObject mol_jsonArray:@"resBody"];
            NSString *frontCreatTime = nil;
            for (NSInteger i = array.count - 1; i >= 0; i--) {
                
                NSDictionary *dic = array[i];
                
                if (i == array.count - 1) {  // 添加第一条的时间
                    EDTimeMessageModel *timeM = [[EDTimeMessageModel alloc] initWithTime:[NSString moli_timeGetMessageTimeWithTimestamp:[dic mol_jsonString:@"createTime"]]];
                    [arrM addObject:timeM];
                    
                }else{
                    if (([dic mol_jsonInteger:@"createTime"] - frontCreatTime.integerValue > MOL_TIME_MARGIN * 1000)) {
                        EDTimeMessageModel *timeM = [[EDTimeMessageModel alloc] initWithTime:[NSString moli_timeGetMessageTimeWithTimestamp:[dic mol_jsonString:@"createTime"]]];
                        [arrM addObject:timeM];
                    }
                }
                
                frontCreatTime = [dic mol_jsonString:@"createTime"];
                
                NSInteger type = [dic mol_jsonInteger:@"chatType"];
                if (type == 0) {
                    EDTextMessageModel *textM = [EDTextMessageModel mj_objectWithKeyValues:dic];
                    [arrM addObject:textM];
                }else if (type == 1){
                    EDImageMessageModel *imageM = [EDImageMessageModel mj_objectWithKeyValues:dic];
                    [arrM addObject:imageM];
                }else if (type == 2){
                    EDAudioMessageModel *audioM = [EDAudioMessageModel mj_objectWithKeyValues:dic];
                    [arrM addObject:audioM];
                }
                
            }
            // 获取消息成功
            if ([delegate respondsToSelector:@selector(interface_didReceiveHistoryMessages:)]) {
                [delegate interface_didReceiveHistoryMessages:arrM];
            }
        }else{
            // 获取消息失败
            if ([delegate respondsToSelector:@selector(interface_getLoadHistoryMessageError)]) {
                [delegate interface_getLoadHistoryMessageError];
            }
            [MOLToast toast_showWithWarning:YES title:message];
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
       
    }];
}


/**
 * 收到新消息 - 从服务器拉取
 */
+ (void)interfaceGetNewMessageWithParameter:(NSDictionary *)para
                                   delegate:(id<EDServiceInterfaceDelegate>)delegate
{
    // 从服务器拉取一条新的消息
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_messageContentWithParameter:para];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            NSMutableArray *arrM = [NSMutableArray array];
            
            NSArray *array = [request.responseObject mol_jsonArray:@"resBody"];
            NSString *frontCreatTime = nil;
            for (NSInteger i = array.count - 1; i >= 0; i--) {
                
                NSDictionary *dic = array[i];
                
                if (i == array.count - 1) {  // 添加第一条的时间
                    EDTimeMessageModel *timeM = [[EDTimeMessageModel alloc] initWithTime:[NSString moli_timeGetMessageTimeWithTimestamp:[dic mol_jsonString:@"createTime"]]];
                    [arrM addObject:timeM];
                    
                }else{
                    if (([dic mol_jsonInteger:@"createTime"] - frontCreatTime.integerValue > MOL_TIME_MARGIN * 1000)) {
                        EDTimeMessageModel *timeM = [[EDTimeMessageModel alloc] initWithTime:[NSString moli_timeGetMessageTimeWithTimestamp:[dic mol_jsonString:@"createTime"]]];
                        [arrM addObject:timeM];
                    }
                }
                
                frontCreatTime = [dic mol_jsonString:@"createTime"];
                
                NSInteger type = [dic mol_jsonInteger:@"chatType"];
                if (type == 0) {
                    EDTextMessageModel *textM = [EDTextMessageModel mj_objectWithKeyValues:dic];
                    [arrM addObject:textM];
                }else if (type == 1){
                    EDImageMessageModel *imageM = [EDImageMessageModel mj_objectWithKeyValues:dic];
                    [arrM addObject:imageM];
                }else if (type == 2){
                    EDAudioMessageModel *audioM = [EDAudioMessageModel mj_objectWithKeyValues:dic];
                    [arrM addObject:audioM];
                }
                
            }
            // 获取消息成功
            if ([delegate respondsToSelector:@selector(interface_didReceiveNewMessages:)]) {
                [delegate interface_didReceiveNewMessages:arrM];
            }
        }else{
            
            [MOLToast toast_showWithWarning:YES title:message];
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
    }];
}

/**
 * 发送文字消息
 */
+ (void)interfaceSendTextMessageWithContent:(NSString *)content
                                 localMsgId:(NSString *)localMsgId
                                       user:(NSDictionary *)user
                                   delegate:(id<EDServiceInterfaceDelegate>)delegate
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"chatType"] = @"0";
    dic[@"content"] = content;
    dic[@"storyId"] = user[@"storyId"];
    dic[@"toUserId"] = user[@"toUserId"];
    dic[@"toUserName"] = user[@"toUserName"];
    dic[@"userName"] = user[@"userName"];
    
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_publishMessageWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        NSDictionary *res = request.responseObject;
        
        EDTextMessageModel *model = [EDTextMessageModel mj_objectWithKeyValues:res[@"resBody"]];
        
        if (code == MOL_SUCCESS_REQUEST) {
            if ([delegate respondsToSelector:@selector(interface_sendMessageResultWithNewMsgId:oldMsgId:newMsgDate:newMsgContent:sendStatus:)]) {
                [delegate interface_sendMessageResultWithNewMsgId:nil oldMsgId:nil newMsgDate:nil newMsgContent:model sendStatus:MessageSendStatusType_success];
            }
        }else{
            if ([delegate respondsToSelector:@selector(interface_sendMessageResultWithNewMsgId:oldMsgId:newMsgDate:newMsgContent:sendStatus:)]) {
                [delegate interface_sendMessageResultWithNewMsgId:nil oldMsgId:nil newMsgDate:nil newMsgContent:nil sendStatus:MessageSendStatusType_failure];
            }
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

/**
 * 发送图片消息
 */
+ (void)interfaceSendTextMessageWithImage:(NSString *)image
                               localMsgId:(NSString *)localMsgId
                                     user:(NSDictionary *)user
                                 delegate:(id<EDServiceInterfaceDelegate>)delegate
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"chatType"] = @"1";
    dic[@"content"] = image;
    dic[@"storyId"] = user[@"storyId"];
    dic[@"toUserId"] = user[@"toUserId"];
    dic[@"toUserName"] = user[@"toUserName"];
    dic[@"userName"] = user[@"userName"];
    
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_publishMessageWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        NSDictionary *res = request.responseObject;
        EDImageMessageModel *model = [EDImageMessageModel mj_objectWithKeyValues:res[@"resBody"]];
        
        if (code == MOL_SUCCESS_REQUEST) {
            if ([delegate respondsToSelector:@selector(interface_sendMessageResultWithNewMsgId:oldMsgId:newMsgDate:newMsgContent:sendStatus:)]) {
                [delegate interface_sendMessageResultWithNewMsgId:nil oldMsgId:nil newMsgDate:nil newMsgContent:model sendStatus:MessageSendStatusType_success];
            }
        }else{
            if ([delegate respondsToSelector:@selector(interface_sendMessageResultWithNewMsgId:oldMsgId:newMsgDate:newMsgContent:sendStatus:)]) {
                [delegate interface_sendMessageResultWithNewMsgId:nil oldMsgId:nil newMsgDate:nil newMsgContent:nil sendStatus:MessageSendStatusType_failure];
            }
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

/**
 * 发送语音消息
 */
+ (void)interfaceSendTextMessageWithAudio:(NSString *)audio
                               localMsgId:(NSString *)localMsgId
                                     user:(NSDictionary *)user
                                 delegate:(id<EDServiceInterfaceDelegate>)delegate
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"chatType"] = @"2";
    dic[@"content"] = audio;
    dic[@"storyId"] = user[@"storyId"];
    dic[@"toUserId"] = user[@"toUserId"];
    dic[@"toUserName"] = user[@"toUserName"];
    dic[@"userName"] = user[@"userName"];
    
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_publishMessageWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        NSDictionary *res = request.responseObject;
        EDAudioMessageModel *model = [EDAudioMessageModel mj_objectWithKeyValues:res[@"resBody"]];
        
        if (code == MOL_SUCCESS_REQUEST) {
            if ([delegate respondsToSelector:@selector(interface_sendMessageResultWithNewMsgId:oldMsgId:newMsgDate:newMsgContent:sendStatus:)]) {
                [delegate interface_sendMessageResultWithNewMsgId:nil oldMsgId:nil newMsgDate:nil newMsgContent:model sendStatus:MessageSendStatusType_success];
            }
        }else{
            if ([delegate respondsToSelector:@selector(interface_sendMessageResultWithNewMsgId:oldMsgId:newMsgDate:newMsgContent:sendStatus:)]) {
                [delegate interface_sendMessageResultWithNewMsgId:nil oldMsgId:nil newMsgDate:nil newMsgContent:nil sendStatus:MessageSendStatusType_failure];
            }
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];

}

@end
