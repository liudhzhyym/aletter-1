//
//  MOLProxy.h
//  aletter
//
//  Created by moli-2017 on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOLProxy : NSObject
@property (weak, nonatomic) id target;
+ (instancetype)proxyWithTarget:(id)target;
@end
