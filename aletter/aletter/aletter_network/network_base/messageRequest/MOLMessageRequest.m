//
//  MOLMessageRequest.m
//  aletter
//
//  Created by moli-2017 on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMessageRequest.h"

typedef NS_ENUM(NSUInteger, MOLMessageRequestType) {
    MOLMessageRequestType_msgList,   // 会话列表
    MOLMessageRequestType_checkChat,  // 检查会话
    MOLMessageRequestType_publishChat, // 发布私聊
    MOLMessageRequestType_msgContent,  // 私聊内容
    MOLMessageRequestType_noti,  // 通知最新消息
    MOLMessageRequestType_notiContent,  // 通知具体内容
    MOLMessageRequestType_chatStoryInfo,  // 聊天的帖子信息
    MOLMessageRequestType_close,  // 关闭对话
    MOLMessageRequestType_open,  // 重新打开对话
    MOLMessageRequestType_agreeOpen,  // 同意重新打开
    MOLMessageRequestType_deleteChat,  // 删除
    MOLMessageRequestType_readInteract,  // 已读
};

@interface MOLMessageRequest ()
@property (nonatomic, assign) MOLMessageRequestType type;
@property (nonatomic, strong) NSDictionary *parameter;
@property (nonatomic, strong) NSString *parameterId;
@end

@implementation MOLMessageRequest

/// 会话列表
- (instancetype)initRequest_messageListWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_msgList;
        _parameter = parameter;
    }
    
    return self;
}

/// 查询会话
- (instancetype)initRequest_checkChatWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_checkChat;
        _parameter = parameter;
    }
    
    return self;
}

/// 发布私聊
- (instancetype)initRequest_publishMessageWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_publishChat;
        _parameter = parameter;
    }
    
    return self;
}

/// 查询会话详情
- (instancetype)initRequest_chatStoryInfoWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_chatStoryInfo;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 会话内容
- (instancetype)initRequest_messageContentWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_msgContent;
        _parameter = parameter;
    }
    
    return self;
}


/// 系统、互动通知
- (instancetype)initRequest_systemNotiWithParameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_noti;
        _parameter = parameter;
    }
    
    return self;
}

/// 系统、互动通知详细内容
- (instancetype)initRequest_notifacationCotiContentWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_notiContent;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 关闭对话
- (instancetype)initRequest_closeChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_close;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 重新打开会话
- (instancetype)initRequest_openChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_open;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 同意打开会话
- (instancetype)initRequest_agreeOpenChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_agreeOpen;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 删除私聊
- (instancetype)initRequest_deleteChatWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_deleteChat;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    
    return self;
}

/// 互动通知已读
- (instancetype)initRequest_readInteractWithParameter:(NSDictionary *)parameter parameterId:(NSString *)parameterId
{
    self = [super init];
    if (self) {
        _type = MOLMessageRequestType_readInteract;
        _parameter = parameter;
        _parameterId = parameterId;
    }
    return self;
}

- (id)requestArgument
{
    return _parameter;
}

- (Class)modelClass
{
    if (_type == MOLMessageRequestType_msgList) {
        return [MOLChatGroupModel class];
    }else if (_type == MOLMessageRequestType_checkChat){
        return [MOLBaseModel class];
    }else if (_type == MOLMessageRequestType_publishChat){
        return [CIMUserMsg class];
    }else if (_type == MOLMessageRequestType_msgContent){
        return [CIMSUCModel class];
    }else if (_type == MOLMessageRequestType_noti){
        return [MOLSystemGroupModel class];
    }else if (_type == MOLMessageRequestType_notiContent){
        return [MOLNotificationGroupModel class];
    }else if (_type == MOLMessageRequestType_chatStoryInfo){
        return [ChatDetailModel class];
    }
    else{
        return [MOLBaseModel class];
    }
}

- (NSString *)requestUrl
{
    switch (_type) {
        case MOLMessageRequestType_msgList:
        {
            NSString *url = @"/chat";
            return url;
        }
            break;
        case MOLMessageRequestType_checkChat:
        {
            NSString *url = @"/chat/query";
            return url;
        }
            break;
        case MOLMessageRequestType_publishChat:
        {
            NSString *url = @"/chat/publish";
            return url;
        }
            break;
        case MOLMessageRequestType_chatStoryInfo:
        {
            NSString *url = @"/chat/{chatId}";
            url = [url stringByReplacingOccurrencesOfString:@"{chatId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLMessageRequestType_msgContent:
        {
            NSString *url = @"/chatLog";
            return url;
        }
            break;
        case MOLMessageRequestType_noti:
        {
            NSString *url = @"/newMsg";
            return url;
        }
            break;
        case MOLMessageRequestType_notiContent:
        {
            NSString *url = @"/pushMsg/{msgType}";
            url = [url stringByReplacingOccurrencesOfString:@"{msgType}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLMessageRequestType_close:
        {
            NSString *url = @"/closeChat/{chatId}";
            url = [url stringByReplacingOccurrencesOfString:@"{chatId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLMessageRequestType_open:
        {
            NSString *url = @"/resetChat/{chatId}";
            url = [url stringByReplacingOccurrencesOfString:@"{chatId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLMessageRequestType_agreeOpen:
        {
            NSString *url = @"/openChat/{chatId}";
            url = [url stringByReplacingOccurrencesOfString:@"{chatId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLMessageRequestType_deleteChat:
        {
            NSString *url = @"/deleteChat/{chatId}";
            url = [url stringByReplacingOccurrencesOfString:@"{chatId}" withString:self.parameterId];
            return url;
        }
            break;
        case MOLMessageRequestType_readInteract:
        {
            NSString *url = @"/readMsg/{msgId}";
            url = [url stringByReplacingOccurrencesOfString:@"{msgId}" withString:self.parameterId];
            return url;
        }
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)parameterId {
    if (!_parameterId.length) {
        return @"";
    }
    return _parameterId;
}
@end
