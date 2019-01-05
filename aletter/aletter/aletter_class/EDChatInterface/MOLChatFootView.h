//
//  MOLChatFootView.h
//  aletter
//
//  Created by moli-2017 on 2018/9/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MOLChatFootViewType) {
    MOLChatFootViewType_normal,   // 默认
    MOLChatFootViewType_requesting,   // 请求中
    MOLChatFootViewType_report,  // 举报
    MOLChatFootViewType_againChat,   // 关闭 重新申请会话
    MOLChatFootViewType_chatRequest  // 请求开启会话
};

@interface MOLChatFootView : UIView
@property (nonatomic, assign) MOLChatFootViewType footType;
@property (nonatomic, strong) void(^actionFootBlock)(MOLChatFootViewType type);
@end
