//
//  MOLLightChatLogModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/24.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLLightChatLogModel.h"

@implementation MOLLightChatLogModel

- (NSString *)content
{
    if (self.chatType == 0) {
        return _content;;
    }else if (self.chatType.integerValue == 1){
        return @"[图片]";
    }else if (self.chatType.integerValue == 2){
        return @"[语音]";
    }
    
    return _content;
}
@end
