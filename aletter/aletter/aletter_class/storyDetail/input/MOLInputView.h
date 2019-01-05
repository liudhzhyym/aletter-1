//
//  MOLInputView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLRecordInputView.h"

@protocol MOLInputViewDelegate <NSObject>

/// 键盘变化
- (void)inputView_keyboardShowWithHeight:(CGFloat)height;

/// 点击发送
- (void)inputView_sendStoryInfoWithText:(NSString *)text voiceString:(NSString *)voice parameter:(NSDictionary *)para;

/// 开始录音
- (void)inputView_beginRecord;

/// 结束录音
- (void)inputView_endRecord;

/// 重新录音
- (void)inputView_againRecord;

/// 开始试听
- (void)inputView_beginListen;

/// 结束试听
- (void)inputView_endListen;

@end

@interface MOLInputView : UIView
@property (nonatomic, assign) BOOL hasVoice;
@property (nonatomic, assign) BOOL hasText;

@property (nonatomic, weak) id <MOLInputViewDelegate> delegate;

- (void)inputView_showSuperView:(UIView *)view placeHolder:(NSString *)placeholder;
- (void)inputView_hidden;
/// 清除数据
- (void)resetRecordData;

/// 是否隐藏键盘开关
- (void)inputView_hiddenSwitch:(BOOL)hidden;
@end
