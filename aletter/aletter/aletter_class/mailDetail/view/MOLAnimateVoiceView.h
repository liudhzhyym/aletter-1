//
//  MOLAnimateVoiceView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLCommentModel.h"
#import "MOLStoryModel.h"
@interface MOLAnimateVoiceView : UIView
@property (nonatomic, weak) UIView *backViewButton;
@property (nonatomic, strong) NSString *showTime;

// 开始动画
- (void)animateVoiceView_start;
// 停止动画
- (void)animateVoiceView_stop;
@end
