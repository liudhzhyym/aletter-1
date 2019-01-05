//
//  MOLRegistView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLHead.h"

@interface MOLRegistView : UIView
@property (nonatomic, weak) UITextField *codeTextField;
@property (nonatomic, weak) UITextField *pwdTextField;
@property (nonatomic, weak) UITextField *againPwdTextField;
@property (nonatomic, weak) UIButton *sendCodeButton;
@property (nonatomic, assign) NSInteger registType;  // 0 去注册  1 设置密码 // 暂时没用
@property (nonatomic, strong) NSString *phoneNum;
@end
