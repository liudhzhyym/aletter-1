//
//  MOLWeakScriptMessageHandler.h
//  aletter
//
//  Created by 徐天牧 on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@protocol JAScriptMessageHandler <NSObject>

@optional
- (void)ja_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface MOLWeakScriptMessageHandler : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<JAScriptMessageHandler> ja_handler;
- (instancetype)initWithHandler:(id<JAScriptMessageHandler>)ja_handler;

@end
