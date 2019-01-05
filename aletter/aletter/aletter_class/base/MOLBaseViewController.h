//
//  MOLBaseViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, UIBehaviorTypeStyle) {
    UIBehaviorTypeStyle_Normal = 0,     //初始化
    UIBehaviorTypeStyle_Refresh = 1,    //下拉刷新
    UIBehaviorTypeStyle_More =2,        //上拉加载更多
};

@interface MOLBaseViewController : UIViewController <UIViewControllerTransitioningDelegate>


- (void)basevc_setNavLeftItemWithTitle:(NSString *)title titleColor:(UIColor *)color;
- (void)basevc_setCenterTitle:(NSString *)title titleColor:(UIColor *)color;
- (void)leftBackAction;
@property (nonatomic, assign) BOOL needStar; // 是否需要星星

// 显示loading
- (void)basevc_showLoading;
// 隐藏loading
- (void)basevc_hiddenLoading;
// 展示空白页
- (void)basevc_showBlankPageWithY:(CGFloat)localY image:(NSString *)image title:(NSString *)title superView:(UIView *)view;
// 网络请求失败
- (void)basevc_showErrorPageWithY:(CGFloat)localY select:(SEL)select superView:(UIView *)view;
@end
