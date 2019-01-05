//
//  CustomButton.m
//  USchoolCircle
//  聊天界面－－－语音动画类
//  Created by xiaolong li on 15/3/7.
//  Copyright (c) 2015年 uskytec. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (id) initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        /*
         *  扩展方法
         */
    }
    return self;
}


/*
 *  触发事件
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"event value is %@",event );
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    if (_delegate && [_delegate respondsToSelector:@selector(getTouchesBeganPointValue: andUIview:)]){
        [_delegate getTouchesBeganPointValue:point andUIview:[touch view]];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    if (_delegate && [_delegate respondsToSelector:@selector(getTouchesMovedPointValue: andUIView:)]){
        [_delegate getTouchesMovedPointValue: point andUIView:[touch view]];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    if (_delegate && [_delegate respondsToSelector:@selector(getTouchesEndedPointValue: andUIView:)]){
        [_delegate getTouchesEndedPointValue: point andUIView:[touch view]];
    }
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:self];
    if (_delegate && [_delegate respondsToSelector:@selector(getTouchesCancelledPointValue: andUIView:)]){
        [_delegate getTouchesCancelledPointValue:point andUIView:[touch view]];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
