//
//  CIMMsgBase.h
//  aletter
//
//  Created by xiaolong li on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//
// 消息基类

//消息类型

#import "MOLBaseModel.h"

typedef NS_ENUM(NSInteger, EIMMSG_TYPE) {
    MSGTYPE_UNDEFINED = 0,            //未知
    MSGTYPE_SUC = 1,                  //单聊消息
};

//消息子类型
typedef NS_ENUM(NSInteger, EIMMSG_SUBTYPE){
    MSGSUBTYPE_UNDEFINED = 0,         //未知
    MSGSUBTYPE_SUC_SEND = 1,          //当前用户发送的单聊消息
    MSGSUBTYPE_SUC_RECV = 2,          //当前用户接收的在线单聊消息
    MSGSUBTYPE_SUC_RECVOFFLINE = 3,   //当前用户接收的离线单聊消息
};

//消息状态
typedef NS_ENUM(NSInteger, EIMMSG_STATUS){
    MSGSTATUS_UNDEFINED = 0,  //未知
    MSGSTATUS_UNREAD,         //未读
    MSGSTATUS_READ,           //已读
    MSGSTATUS_SENDING,        //发送中
    MSGSTATUS_SENDERROR,      //发送失败
    MSGSTATUS_SENDOK          //发送成功
};

@interface CIMMsgBase : MOLBaseModel

/* 消息类型 */
@property(nonatomic, assign) EIMMSG_TYPE MsgType;
/* 消息子类型 */
@property(nonatomic, assign) EIMMSG_SUBTYPE MsgSubType;
/* 消息状态 */
@property(nonatomic, assign) EIMMSG_STATUS Status;
/* 消息内容 */
@property(nonatomic, copy) NSString* Msg;

@end


