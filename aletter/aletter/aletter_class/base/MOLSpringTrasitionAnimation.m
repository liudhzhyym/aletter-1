//
//  MOLSpringTrasitionAnimation.m
//  aletter
//
//  Created by moli-2017 on 2018/8/18.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSpringTrasitionAnimation.h"

@implementation MOLSpringTrasitionAnimation

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    // 下面这几个参数的获取和意义我们不说了，前面代码中都有
    UIViewController * fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toViewController   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView           * contextView        = [transitionContext containerView];
    
    BOOL isPresent   = (toViewController.presentingViewController == fromViewController);
    
    if (isPresent) {
        [contextView addSubview:toViewController.view];
        toViewController.view.frame = CGRectMake(0, 0, contextView.frame.size.width, contextView.frame.size.height);
        
    }
    
    if (isPresent) {
        
        toViewController.view.transform = CGAffineTransformMakeScale(0.8, 0.8);
        // Present
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1.0 / 0.55 options:0 animations:^{
            
            toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
            
        } completion:^(BOOL finished) {
            
            BOOL  cancle = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!cancle];
            
            if (cancle) {
                //失败后，我们要把vc1显示出来
                fromViewController.view.hidden = NO;
            }
        }];
        
    }else{
        
        // Dismiss
        [UIView animateWithDuration:0.15 animations:^{
            fromViewController.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
            fromViewController.view.alpha = 0.7;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] - 0.15 animations:^{
                
                fromViewController.view.transform = CGAffineTransformMakeScale(0.75, 0.75);
                fromViewController.view.alpha = 0.0;
            } completion:^(BOOL finished) {
                
                if ([transitionContext transitionWasCancelled]) {
                    //失败了接标记失败
                    [transitionContext completeTransition:NO];
                }else{
                    //如果成功了，我们需要标记成功，同时让vc1显示出来，然后移除截图视图，
                    [transitionContext completeTransition:YES];
                    toViewController.view.hidden = NO;
                }
            }];
        }];
    }
}
@end
