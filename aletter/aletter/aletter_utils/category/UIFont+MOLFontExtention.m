//
//  UIFont+MOLFontExtention.m
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "UIFont+MOLFontExtention.h"

@implementation UIFont (MOLFontExtention)
+ (UIFont *)mol_systemFontOfSize:(CGFloat)fontSize fontWithName:(NSString *)fontName
{
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];//这个是9.0以后自带的平方字体
    if (font == nil) {
        //这个是手动导入的第三方平方字体
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

@end
