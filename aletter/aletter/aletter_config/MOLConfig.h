//
//  MOLConfig.h
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "UIFont+MOLFontExtention.h"

#ifndef MOLConfig_h
#define MOLConfig_h

//字体
#define MOL_FONT(f)   [UIFont systemFontOfSize:(f)]
#define MOL_LIGHT_FONT(size) [UIFont mol_systemFontOfSize:size fontWithName:@"PingFangSC-Light"]
#define MOL_REGULAR_FONT(size) [UIFont mol_systemFontOfSize:size fontWithName:@"PingFangSC-Regular"]
#define MOL_MEDIUM_FONT(size) [UIFont mol_systemFontOfSize:size fontWithName:@"PingFangSC-Medium"]

// 系统
#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOS11 (SYSTEM_VERSION >= 11.0)?YES:NO
#define iOS10 (SYSTEM_VERSION >= 10.0)?YES:NO
#define iOS9 (SYSTEM_VERSION >= 9.0)?YES:NO
#define iOS8 (SYSTEM_VERSION >= 8.0)?YES:NO
#define iOS7 (SYSTEM_VERSION >= 7.0)?YES:NO
#define iOS6 (SYSTEM_VERSION >= 6.0)?YES:NO

// 设备类型
#define iPhoneX   ((MOL_SCREEN_HEIGHT==812)?YES:NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iTouch ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ((MOL_SCREEN_WIDTH==414)?YES:NO)
#define iPhone6   ((MOL_SCREEN_WIDTH==375)?YES:NO)
#define iPhone320 ((MOL_SCREEN_WIDTH==320)?YES:NO)
#define iPhone4 ((MOL_SCREEN_HEIGHT==480)?YES:NO)

// 尺寸
// 比例
#define MOL_SCREEN_SCALE      ([UIScreen mainScreen].scale)
// 屏幕宽
#define MOL_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
// 屏幕高
#define MOL_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
// 尺寸适配
#define MOL_SCREEN_ADAPTER(w) lrintf(1.0*MOL_SCREEN_WIDTH/375.0f*(w))


//适配（以iPhone6为基准传入高，得出当前设备应该有的高度）
#define MOL_SCALEHeight(height)  (height * 375.0f/MOL_SCREEN_WIDTH)

// 状态栏

#define MOL_STATUSBAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height  // 状态栏高度

// Status bar height.
#define  MOL_StatusBarHeight      (iPhoneX ? 44.f : 20.f)
// Navigation bar height.
#define  MOL_NavigationBarHeight  44.f
// Tabbar height.
#define  MOL_TabbarHeight         (iPhoneX ? (49.f+34.f) : 49.f)
// Tabbar safe bottom margin.
#define  MOL_TabbarSafeBottomMargin         (iPhoneX ? 34.f : 0.f)
// Status bar & navigation bar height.
#define  MOL_StatusBarAndNavigationBarHeight  (iPhoneX ? 88.f : 64.f)


// 指针弱化
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

// 常用宏
#define MOLAppDelegateWindow [UIApplication sharedApplication].delegate.window

#define MOL_IOS @"iOS"
#define MOL_APPStore @"App Store"




// 颜色
// 十六进制颜色值 使用：HEX_COLOR(0xf8f8f8)
#define HEX_COLOR_ALPHA(_HEX_,a) [UIColor colorWithRed:((float)((_HEX_ & 0xFF0000) >> 16))/255.0 green:((float)((_HEX_ & 0xFF00) >> 8))/255.0 blue:((float)(_HEX_ & 0xFF))/255.0 alpha:a]


#define HEX_COLOR(_HEX_) HEX_COLOR_ALPHA(_HEX_, 1.0)

#define HEX_COLOR_PERSONAL(_HEX_) HEX_COLOR_ALPHA(_HEX_, 0.8)


#define RGB_COLOR_ALPHA(r, g, b, a) [UIColor colorWithRed:(CGFloat)r/255.0f green:(CGFloat)g/255.0f blue:(CGFloat)b/255.0f alpha:a]
#define RGB_COLOR(r, g, b) RGB_COLOR_ALPHA(r, g, b, 1.0)
#endif /* MOLConfig_h */
