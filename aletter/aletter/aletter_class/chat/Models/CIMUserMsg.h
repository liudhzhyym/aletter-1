//
//  CIMUserMsg.h
//  aletter
//
//  Created by xiaolong li on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//
//  会话用户消息

#import "CIMMsgBase.h"
//消息状态
typedef NS_ENUM(NSInteger, EIM_MSGCONTENT_TYPE){
    MSGCONTENTTYPE_NORMAL = 0,    //纯文本，默认值
    MSGCONTENTTYPE_FACE = 1,      //表情 + 文本
    MSGCONTENTTYPE_DEF_FACE = 2,  //自定义表情
    MSGCONTENTTYPE_IMAGE = 3,     //图片类型
    MSGCONTENTTYPE_VOICE = 4,     //语音类型
};


@interface CIMUserMsg : CIMMsgBase
/*消息类型 0 文字 1图片 2语音*/
@property(nonatomic, copy) NSString* chatType;

/*消息内容*/
@property(nonatomic, copy) NSString* content;

/*消息 1已读 0未读*/
@property(nonatomic, copy) NSString* isRead;

/*用户ID*/
@property(nonatomic, copy) NSString* userId;
/*用户名称*/
@property(nonatomic, copy) NSString* userName;
/* 消息内容类型 */
@property(nonatomic, assign) EIM_MSGCONTENT_TYPE Face;
/* 时间戳*/
@property(nonatomic, assign) long createTime;

/* 消息ID */
@property(nonatomic, copy) NSString* logId;

/* 是否是历史消息 */
@property(nonatomic, assign) BOOL isHistory;

/* 是否显示时间 */
@property(nonatomic, assign) BOOL DispTime;

@end
