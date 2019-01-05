//
//  MOLBaseNavigationController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseNavigationController.h"
#import "MOLHomeViewController.h"
#import "MOLChooseLoginViewController.h"
#import "MOLInfoCheckViewController.h"
#import "MOLMailboxViewController.h"
#import "MOLReportViewController.h"
#import "MOLReportCommentViewController.h"
#import "MOLMineViewController.h"
#import "MOLSendPostViewController.h"
#import "MOLSendEndPostViewController.h"
#import "RecordVoiceViewController.h"
#import "MOLPrisonViewController.h"
#import "LocationViewController.h"

@interface MOLBaseNavigationController ()<UINavigationControllerDelegate>

@end

@implementation MOLBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    
    UIImage *bgImage = [[UIImage imageNamed:@"nav_back_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = NO;
}
- (UIImage *)createAImageWithColor:(UIColor *)color alpha:(CGFloat)alpha{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetAlpha(context, alpha);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 隐藏导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isHidden = NO;
    if ([viewController isKindOfClass:[MOLHomeViewController class]] ||
        [viewController isKindOfClass:[MOLChooseLoginViewController class]] ||
        [viewController isKindOfClass:[MOLInfoCheckViewController class]] ||
        [viewController isKindOfClass:[MOLMailboxViewController class]] ||
        [viewController isKindOfClass:[MOLReportViewController class]] ||
        [viewController isKindOfClass:[MOLReportCommentViewController class]] ||
        [viewController isKindOfClass:[MOLMineViewController class]] ||
        [viewController isKindOfClass:[MOLSendPostViewController class]] ||
        [viewController isKindOfClass:[MOLSendEndPostViewController class]] ||
        [viewController isKindOfClass:[RecordVoiceViewController class]] ||
        [viewController isKindOfClass:[MOLPrisonViewController class]] ||
        [viewController isKindOfClass:[LocationViewController class]]) {
        isHidden = YES;
    }
    [viewController.navigationController setNavigationBarHidden:isHidden animated:YES];
    
}


- (UIViewController *)childViewControllerForStatusBarStyle
{
     return self.topViewController;
}
@end
