//
//  MOLToast.h
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOLToast : UIWindow

+ (void)toast_showWithWarning:(BOOL)warning title:(NSString *)title;
+ (void)toast_hidden;
@end
