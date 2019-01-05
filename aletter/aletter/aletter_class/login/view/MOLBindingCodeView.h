//
//  MOLBindingCodeView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/21.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOLBindingCodeView : UIView
@property (nonatomic, weak) UITextField *codeTextField;
@property (nonatomic, weak) UIButton *sendCodeButton;
@property (nonatomic, strong) NSString *phoneString;
@end
