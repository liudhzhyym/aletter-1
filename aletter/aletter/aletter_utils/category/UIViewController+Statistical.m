//
//  UIViewController+Statistical.m
//  aletter
//
//  Created by xujin on 2018/9/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "UIViewController+Statistical.h"
#import "MOLHomeCollectionViewController.h"
#import "MOLMeetViewController.h"
#import "MOLMailboxViewController.h"
#import "MOLChooseLoginViewController.h"
#import "MOLMineMessageViewController.h"
#import "MOLMineMailViewController.h"
#import "MOLMineSettingViewController.h"
#import "MOLStoryDetailViewController.h"
#import "MOLTopicListViewController.h"
#import "MOLMailDetailViewController.h"
#import "MOLSystemNotiViewController.h"
#import "MOLInteractNotiViewController.h"
#import "MOLPhoneInputViewController.h"
#import "MOLBindingCodeViewController.h"
#import "EDChatViewController.h"
#import "MOLRegistViewController.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import <UMAnalytics/MobClick.h>
//#import "MOLLoginViewController.h"

@implementation UIViewController (Statistical)
+ (void)load{
    swizzleMethod([self class], @selector(viewWillAppear:), @selector(swizzled_viewWillAppear:));
    swizzleMethod([self class], @selector(viewWillDisappear:), @selector(swizzled_viewWillDisappear:));
}

- (void)swizzled_viewWillAppear:(BOOL)animated{
    [self swizzled_viewWillAppear:animated];
    NSLog(@"viewWillAppear %@", NSStringFromClass([self class]));
    if ([self isKindOfClass:[MOLHomeCollectionViewController class]]) { //首页数据统计
        [MobClick beginLogPageView:@"首页"];
    }
    else if ([self isKindOfClass:[MOLMeetViewController class]]) { //遇见数据统计
        [MobClick beginLogPageView:@"遇见"];
    }
    else if ([self isKindOfClass:[MOLMailboxViewController class]]) { //是否装进信封数据统计
        [MobClick beginLogPageView:@"是否装进信封"];
        [MobClick event:@"_pv_post"];
    }else if ([self isKindOfClass:[MOLChooseLoginViewController class]]) { //选择登录方式数据统计
        [MobClick beginLogPageView:@"选择登录方式"];
        [MobClick event:@"_pv_select_loginmethod"];
    }
    else if ([self isKindOfClass:[MOLMineMessageViewController class]]) { //个人中心-消息数据统计
        [MobClick beginLogPageView:@"个人中心-消息"];
    }
    else if ([self isKindOfClass:[MOLMineMailViewController class]]) { //个人中心-信件封数据统计
        [MobClick beginLogPageView:@"个人中心-信件"];
    }else if ([self isKindOfClass:[MOLMineSettingViewController class]]) { //个人中心-设置数据统计
        [MobClick beginLogPageView:@"个人中心-设置"];
    }else if ([self isKindOfClass:[MOLStoryDetailViewController class]]) { //帖子详情数据统计
        [MobClick beginLogPageView:@"帖子详情"];
    }else if ([self isKindOfClass:[MOLTopicListViewController class]]) { //热门话题列表数据统计
        MOLTopicListViewController *objec =(MOLTopicListViewController *)self;
        if (!objec.isChooseTopic) {
            [MobClick beginLogPageView:@"热门话题列表"];
        }
        
    }else if ([self isKindOfClass:[MOLMailDetailViewController class]]) { //频道id数据统计
        MOLMailDetailViewController *objec =(MOLMailDetailViewController *)self;
        if (objec.channelId) {
            [MobClick beginLogPageView:[NSString stringWithFormat:@"频道id%@",objec.channelId]];
        }else if (objec.topicId) {
            [MobClick beginLogPageView:[NSString stringWithFormat:@"话题id%@",objec.topicId]];
        }

    }else if ([self isKindOfClass:[MOLSystemNotiViewController class]]) { //系统通知统计
            [MobClick beginLogPageView:@"系统通知"];
    }else if ([self isKindOfClass:[MOLSystemNotiViewController class]]) { //互动通知统计
        [MobClick beginLogPageView:@"互动通知"];
    }else if ([self isKindOfClass:[EDChatViewController class]]) { //私聊对话统计
        [MobClick beginLogPageView:@"私聊对话"];
    }else if ([self isKindOfClass:[MOLPhoneInputViewController class]]) { //进入绑定手机页
        MOLPhoneInputViewController *phone =(MOLPhoneInputViewController *)self;
        if (phone.type==1 || phone.type==2) {
            [MobClick event:@"_pv_bound_phone"];
        }
    }else if ([self isKindOfClass:[MOLBindingCodeViewController class]]) { //进入绑定手机输入验证页
        
            [MobClick event:@"_pv_bound_code"];
    }else if ([self isKindOfClass:[MOLRegistViewController class]]) { //进入设置密码页
      //  MOLRegistViewController *regist =(MOLRegistViewController *)self;
        //if(regist.registType==1){
            [MobClick event:@"_pv_set_password"];
        //}
        
    }
    
    
}

- (void)swizzled_viewWillDisappear:(BOOL)animated{
    [self swizzled_viewWillDisappear:animated];
    NSLog(@"viewWillDisappear %@", NSStringFromClass([self class]));
    if ([self isKindOfClass:[MOLHomeCollectionViewController class]]) { //首页数据统计
        [MobClick endLogPageView:@"首页"];
    }else if ([self isKindOfClass:[MOLMeetViewController class]]) { //遇见数据统计
        [MobClick endLogPageView:@"遇见"];
    }else if ([self isKindOfClass:[MOLMailboxViewController class]]) { //是否装进信封数据统计
        [MobClick endLogPageView:@"是否装进信封"];
    }else if ([self isKindOfClass:[MOLChooseLoginViewController class]]) { //选择登录方式数据统计
        [MobClick endLogPageView:@"选择登录方式"];
        
    }else if ([self isKindOfClass:[MOLMineMessageViewController class]]) { //个人中心-消息数据统计
        [MobClick endLogPageView:@"个人中心-消息"];
    }
    else if ([self isKindOfClass:[MOLMineMailViewController class]]) { //个人中心-信件封数据统计
        [MobClick endLogPageView:@"个人中心-信件"];
    }else if ([self isKindOfClass:[MOLMineSettingViewController class]]) { //个人中心-设置数据统计
        [MobClick endLogPageView:@"个人中心-设置"];
    }else if ([self isKindOfClass:[MOLStoryDetailViewController class]]) { //帖子详情数据统计
        [MobClick endLogPageView:@"帖子详情"];
    }else if ([self isKindOfClass:[MOLTopicListViewController class]]) { //热门话题列表数据统计
        MOLTopicListViewController *objec =(MOLTopicListViewController *)self;
        if (!objec.isChooseTopic) {
            [MobClick endLogPageView:@"热门话题列表"];
        }
        
    }else if ([self isKindOfClass:[MOLMailDetailViewController class]]) { //频道id数据统计
        MOLMailDetailViewController *objec =(MOLMailDetailViewController *)self;
        if (objec.channelId) {
            [MobClick endLogPageView:[NSString stringWithFormat:@"频道id%@",objec.channelId]];
        }else if (objec.topicId) {
            [MobClick endLogPageView:[NSString stringWithFormat:@"话题id%@",objec.topicId]];
        }
    }else if ([self isKindOfClass:[MOLSystemNotiViewController class]]) { //系统通知统计
        [MobClick endLogPageView:@"系统通知"];
    }else if ([self isKindOfClass:[MOLSystemNotiViewController class]]) { //互动通知统计
        [MobClick endLogPageView:@"互动通知"];
    }else if ([self isKindOfClass:[EDChatViewController class]]) { //私聊对话统计
        [MobClick beginLogPageView:@"私聊对话"];
    }else if ([self isKindOfClass:[EDChatViewController class]]) { //私聊对话统计
        [MobClick beginLogPageView:@"私聊对话"];
    }
}



void swizzleMethod(Class class,SEL originalSelector,SEL swizzledSelector){
    // the method might not exist in the class, but in its superclass
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // class_addMethod will fail if original method already exists
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    // the method doesn’t exist and we just added one
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
