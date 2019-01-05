//
//  MOLUserModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/13.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLUserModel.h"
#import "MOLHead.h"

@implementation MOLUserModel
- (NSString *)age
{
    
    if (_age.integerValue == 100 || _age.integerValue == 0) {
        _age = @"00";
    }
    
    if (_age.integerValue == 105 || _age.integerValue == 5) {
        _age = @"05";
    }
    
    return _age;
}
MJCodingImplementation
@end
