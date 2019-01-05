//
//  MOLProxy.m
//  aletter
//
//  Created by moli-2017 on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLProxy.h"

@implementation MOLProxy
+ (instancetype)proxyWithTarget:(id)target
{
    MOLProxy* proxy = [[self class] alloc];
    proxy.target = target;
    return proxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation{
    SEL sel = [invocation selector];
    if ([self.target respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.target];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.target respondsToSelector:aSelector]) {
        
        return self.target;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

@end
