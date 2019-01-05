//
//  MOLLightUserModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLLightUserModel.h"

@implementation MOLLightUserModel

// 为啥两个名字？问服务器，一会一个名字！！！！
- (NSString *)userName
{
    if (_userName.length) {
        return _userName;
    }else{
        return _commentName;
    }
}

- (NSString *)commentName
{
    if (_commentName.length) {
        return _commentName;
    }else{
        return _userName;
    }
}
@end
