//
//  MOLRecordInputView.h
//  aletter
//
//  Created by moli-2017 on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MOLRecordInputViewType) {
    MOLRecordInputViewType_begin,
    MOLRecordInputViewType_record,
    MOLRecordInputViewType_end,
};

@protocol MOLRecordInputViewDelegate <NSObject>
/// 录制结果
- (void)recordInputView_recordWithVoiceFile:(NSString *)voice voiceTime:(NSInteger)time iflyResults:(NSArray *)results;

/// 开始录音
- (void)recordInputView_beginRecord;

/// 结束录音
- (void)recordInputView_endRecord;

/// 重新录音
- (void)recordInputView_againRecord;

/// 开始试听
- (void)recordInputView_beginListen;

/// 结束试听
- (void)recordInputView_endListen;
@end

@interface MOLRecordInputView : UIView
@property (nonatomic, assign) MOLRecordInputViewType keyBoardType;  // 键盘状态
@property (nonatomic, strong) id <MOLRecordInputViewDelegate> delegate;

- (void)recordInputView_resetData;
@end
