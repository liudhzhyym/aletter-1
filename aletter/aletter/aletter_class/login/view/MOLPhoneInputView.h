//
//  MOLPhoneInputView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOLPhoneInputView : UIView
@property (nonatomic, weak) UITextField *phoneTextField;
@property (nonatomic, strong) NSString *frontPhoneNum;
@property (nonatomic, assign) NSInteger type; // 0 手机登录  1 绑定手机(注册账号) 2 绑定手机(绑定账户)
@end
