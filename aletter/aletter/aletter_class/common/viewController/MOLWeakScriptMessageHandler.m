//
//  MOLWeakScriptMessageHandler.m
//  aletter
//
//  Created by 徐天牧 on 2018/9/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLWeakScriptMessageHandler.h"

@implementation MOLWeakScriptMessageHandler

- (instancetype)initWithHandler:(id<JAScriptMessageHandler>)ja_handler {
    self = [super init];
    if (self) {
        _ja_handler = ja_handler;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.ja_handler && [self.ja_handler respondsToSelector:@selector(ja_userContentController:didReceiveScriptMessage:)]) {
        [self.ja_handler ja_userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
