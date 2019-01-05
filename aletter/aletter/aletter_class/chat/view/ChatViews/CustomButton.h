//
//  CustomButton.h
//  USchoolCircle
//  聊天界面－－－语音动画类
//  Created by xiaolong li on 15/3/7.
//  Copyright (c) 2015年 uskytec. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  NS_ENUM(NSUInteger, TouchState)
{
    TouchStateDown,
    TouchStateUpInside,
    TouchStateUpOutside
};
/*
 *  实现委托类方法
 */
@protocol CustomButtonDelegate <NSObject>

@optional

-(void)getTouchesPointValue:(CGPoint)point andUIView:(UIView *)view;

-(void)getTouchesBeganPointValue:(CGPoint)point andUIview:(UIView *)view;

-(void)getTouchesMovedPointValue:(CGPoint)point andUIView:(UIView *)view;

-(void)getTouchesEndedPointValue:(CGPoint)point andUIView:(UIView *)view;

-(void)getTouchesCancelledPointValue:(CGPoint)point andUIView:(UIView *)view;

@end

@interface CustomButton : UIButton

@property (nonatomic, weak) id<CustomButtonDelegate>delegate;

-(void) addaction:(SEL)action forControlEvents:(TouchState)controlEvents;

@end




