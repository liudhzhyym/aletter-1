//
//  MOLPrisonViewController.h
//  aletter
//
//  Created by 徐天牧 on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLPrisonViewController : MOLBaseViewController

+ (instancetype)shared;
//展示封号页面 
+(void)show;
//网络请求
-(void)request_getPrisonData;
-(void)showAnimation:(BOOL)isAnimation;
@end
