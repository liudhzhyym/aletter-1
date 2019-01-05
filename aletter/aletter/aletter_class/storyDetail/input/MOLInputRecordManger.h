//
//  MOLInputRecordManger.h
//  aletter
//
//  Created by moli-2017 on 2018/8/15.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MOLInputRecordMangerDelegate <NSObject>
- (void)inputRecord_recordDuration:(CGFloat)durarion volum:(CGFloat)volum;
- (void)inputRecord_recordFinishWithVoice:(NSString *)file results:(NSArray *)results voiceTime:(NSInteger)time;
- (void)inputRecord_recordError;
@end

@interface MOLInputRecordManger : NSObject

@property (nonatomic, weak) id <MOLInputRecordMangerDelegate> delegate;

/// 开始录制
- (void)inputRecord_Start;

/// 结束录制
- (void)inputRecord_Stop;

/// 清空资源
- (void)inputRecord_resetResource;
@end
