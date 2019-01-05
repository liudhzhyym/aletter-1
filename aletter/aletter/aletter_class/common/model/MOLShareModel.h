//
//  MOLShareModel.h
//  aletter
//
//  Created by 徐天牧 on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOLShareModel : NSObject

@property (nonatomic, copy) NSString *type;  // 分享平台 1,qq   2,qq空间。3,微博   4，微信  5，朋友圈
/// 分享的类型
@property (nonatomic, copy) NSString *dataType;  // 分享类型 1，一般的url内容   2，URL图片 3，base64图片。 4分享音乐

/// 分享的标题
@property (nonatomic, copy) NSString *title;

/// 分享的描述
@property (nonatomic, copy) NSString *subtitle;

/// 分享的logo
@property (nonatomic, copy) NSString *logo;

/// 分享的url
@property (nonatomic, copy) NSString *shareUrl;


@end
