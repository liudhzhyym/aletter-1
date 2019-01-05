//
//  MOLInputView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInputView.h"
#import "MOLHead.h"
#import "JAGrowingTextView.h"
#import "MOLRecordInputView.h"

#define kRecordInputHeight 252

@interface MOLInputView ()<JAGrowingTextViewDelegate,YYTextKeyboardObserver,MOLRecordInputViewDelegate>
@property (nonatomic, assign) BOOL needNotifacationKeyBoard;  // 是否需要监听键盘
@property (nonatomic, weak) UIButton *gestureButton;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UIView *toolView;
@property (nonatomic, weak) JAGrowingTextView *textView;  // 文本框
@property (nonatomic, weak) UIButton *switchButton;  // 键盘录音开关按钮
@property (nonatomic, weak) UIButton *sendButton;    // 发送按钮
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) MOLRecordInputView *recordView;

@property (nonatomic, strong) NSString *frontPlaceHolder;  // 前一个占位文字，是否清除数据的标记

// 数据参数
@property (nonatomic, strong) NSString *inputText;
@property (nonatomic, strong) NSString *inputVoice;
@property (nonatomic, strong) NSString *iflyText;
/*
 时间key:    time
 解析文字key: text
 */
@property (nonatomic, strong) NSMutableDictionary *inputVoicePara;
@property (nonatomic, assign) CGFloat keyBoardHeight;
@end


@implementation MOLInputView

- (void)dealloc
{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _inputVoicePara = [NSMutableDictionary dictionary];
        [self setupInputViewUI];
        self.backgroundColor = [UIColor clearColor];
        self.hasText = NO;
        self.hasVoice = NO;
        self.needNotifacationKeyBoard = YES;
    }
    return self;
}

#pragma mark - publish
- (void)inputView_showSuperView:(UIView *)view placeHolder:(NSString *)placeholder
{
    if (![view.subviews containsObject:self]) {
        [view addSubview:self];
    }
    [self.textView becomeFirstResponder];
    self.y = view.height;
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.y = 0;
    }];
    
    if (placeholder.length) {
        NSMutableAttributedString *place = [[NSMutableAttributedString alloc] initWithString:placeholder];
        [place addAttributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14), NSForegroundColorAttributeName : HEX_COLOR(0x091F38)} range:[placeholder rangeOfString:placeholder]];
        self.textView.placeholderAttributedText = place;
        
        // 清除数据
        if (![self.frontPlaceHolder isEqualToString:placeholder]) {
            [self resetRecordData];
        }
        self.frontPlaceHolder = placeholder;
    }
    // 弹出时键盘的高度 - 目的：不要挡住评论
    if ([self.delegate respondsToSelector:@selector(inputView_keyboardShowWithHeight:)]) {
        [self.delegate inputView_keyboardShowWithHeight:self.keyBoardHeight];
    }
}
- (void)inputView_hidden
{
    [self.textView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.y = self.superview.height;
    } completion:^(BOOL finished) {
        self.y = 0;
        self.hidden = YES;
    }];
}

- (void)setNeedNotifacationKeyBoard:(BOOL)needNotifacationKeyBoard
{
    _needNotifacationKeyBoard = needNotifacationKeyBoard;
    
    if (needNotifacationKeyBoard) {
        [[YYTextKeyboardManager defaultManager] addObserver:self];
    }else{
        [[YYTextKeyboardManager defaultManager] removeObserver:self];
    }
}

// 清除数据
- (void)resetRecordData
{
    self.inputText = nil;
    self.hasText = NO;
    
    self.hasVoice = NO;
    self.inputVoice = nil;
    
    [self.inputVoicePara removeAllObjects];
    
    self.textView.text = nil;
    self.sendButton.selected = NO;
    
    // 清空录制键盘数据
    [self.recordView recordInputView_resetData];
}


/// 是否隐藏键盘开关
- (void)inputView_hiddenSwitch:(BOOL)hidde
{
    self.switchButton.hidden = hidde;
}

#pragma mark - 按钮的点击
- (void)button_clickSwitchButton:(UIButton *)button
{
    if (self.hasVoice) {
        [self.switchButton setImage:[UIImage imageNamed:@"meet_comment_voice_red"] forState:UIControlStateNormal];
    }else{
        [self.switchButton setImage:[UIImage imageNamed:@"meet_comment_voice"] forState:UIControlStateNormal];
    }
    
    button.selected = !button.selected;
    if (button.selected) {
        [self.textView resignFirstResponder];
    }else{
        [self.textView becomeFirstResponder];
    }
}

- (void)setHasVoice:(BOOL)hasVoice
{
    _hasVoice = hasVoice;
    if (hasVoice) {
        [self.switchButton setImage:[UIImage imageNamed:@"meet_comment_voice_red"] forState:UIControlStateNormal];
    }else{
        [self.switchButton setImage:[UIImage imageNamed:@"meet_comment_voice"] forState:UIControlStateNormal];
    }
}

// 发送按钮
- (void)button_clickSendButton:(UIButton *)button
{
    if (!button.selected) {
        [MOLToast toast_showWithWarning:YES title:@"请输入文字"];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(inputView_sendStoryInfoWithText:voiceString:parameter:)]) {
        [self.delegate inputView_sendStoryInfoWithText:self.inputText voiceString:self.inputVoice parameter:self.inputVoicePara];
    }
}

- (void)button_clickGestureButton
{
    [self inputView_hidden];
}

#pragma mark - MOLRecordInputViewDelegate
/// 录制结果
- (void)recordInputView_recordWithVoiceFile:(NSString *)voice voiceTime:(NSInteger)time iflyResults:(NSArray *)results
{
    if (results.count) {
        
        NSString *string = nil;
        NSString *oldT = self.textView.text;
        if (oldT.length) {
            string = [NSString stringWithFormat:@"%@%@",oldT,[results componentsJoinedByString:@""]];
        }else{
            string = [results componentsJoinedByString:@""];
        }
        
        self.textView.text = string;
    }
    
    if (voice.length) {
        self.hasVoice = YES;
        self.inputVoice = voice;
    }
    
    self.inputVoicePara[@"time"] = @(time);
    self.inputVoicePara[@"text"] = [results componentsJoinedByString:@""];
}

/// 开始录音
- (void)recordInputView_beginRecord
{
    if ([self.delegate respondsToSelector:@selector(inputView_beginRecord)]) {
        [self.delegate inputView_beginRecord];
    }
}

/// 结束录音
- (void)recordInputView_endRecord
{
    if ([self.delegate respondsToSelector:@selector(inputView_endRecord)]) {
        [self.delegate inputView_endRecord];
    }
}

/// 重新录音
- (void)recordInputView_againRecord
{
    if ([self.delegate respondsToSelector:@selector(inputView_againRecord)]) {
        [self.delegate inputView_againRecord];
    }
    [[MOLPlayVoiceManager sharePlayVoiceManager] playManager_pause];
    [self resetRecordData];
}

/// 开始试听
- (void)recordInputView_beginListen
{
    if ([self.delegate respondsToSelector:@selector(inputView_beginListen)]) {
        [self.delegate inputView_beginListen];
    }
}

/// 结束试听
- (void)recordInputView_endListen
{
    if ([self.delegate respondsToSelector:@selector(inputView_endListen)]) {
        [self.delegate inputView_endListen];
    }
}

#pragma mark - JAGrowingTextViewDelegate
- (void)didChangeHeight:(CGFloat)height
{
    [self calculatorInputViewFrame:self.switchButton.selected ? kRecordInputHeight : self.keyBoardHeight];
}
- (void)textViewDidChange:(JAGrowingTextView *)growingTextView
{
    if (growingTextView.text.length) {
        self.hasText = YES;
        self.sendButton.selected = YES;
        self.inputText = [growingTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        self.hasText = NO;
        self.sendButton.selected = NO;
    }
}

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    if ([replacementText isEqualToString:@"\n"]) {
        // 发送
        [self button_clickSendButton:self.sendButton];
        return NO;
    }
    return YES;
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition
{
    CGRect kbFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self];
    self.keyBoardHeight = kbFrame.size.height;
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        ///用此方法获取键盘的rect
        ///从新计算view的位置并赋值
        CGFloat h = self.height - fabs(kbFrame.origin.y);
        if (h > 100) {
            [self calculatorInputViewFrame:h];
            self.switchButton.selected = NO;
        }else{
            [self calculatorInputViewFrame:kRecordInputHeight];
            self.switchButton.selected = YES;
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UI
- (void)setupInputViewUI
{
    UIButton *gestureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _gestureButton = gestureButton;
    [gestureButton addTarget:self action:@selector(button_clickGestureButton) forControlEvents:UIControlEventTouchDown];
    [self addSubview:gestureButton];
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    
    UIView *toolView = [[UIView alloc] init];
    _toolView = toolView;
    [backView addSubview:toolView];
    
    JAGrowingTextView *textView = [[JAGrowingTextView alloc] initWithFrame:CGRectZero];
    _textView = textView;
    textView.font = MOL_LIGHT_FONT(14);
    textView.maxNumberOfLines = 4;
    textView.minNumberOfLines = 1;
    textView.textColor = HEX_COLOR(0x091F38);
    textView.backgroundColor = [UIColor clearColor];
    textView.size = [textView intrinsicContentSize];
    textView.textViewDelegate = self;
    textView.returnKeyType = UIReturnKeySend;
    NSString *placeHolder = @"回复楼主";
    self.frontPlaceHolder = placeHolder;
    NSMutableAttributedString *place = [[NSMutableAttributedString alloc] initWithString:placeHolder];
    [place addAttributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14), NSForegroundColorAttributeName : HEX_COLOR(0x091F38)} range:[placeHolder rangeOfString:placeHolder]];
    textView.placeholderAttributedText = place;
    [toolView addSubview:textView];
    
    UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _switchButton = switchButton;
    [switchButton setImage:[UIImage imageNamed:@"meet_comment_voice"] forState:UIControlStateNormal];
    [switchButton setImage:[UIImage imageNamed:@"meet_comment_keyboard"] forState:UIControlStateSelected];
    [switchButton setImage:[UIImage imageNamed:@"meet_comment_keyboard"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [switchButton addTarget:self action:@selector(button_clickSwitchButton:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:switchButton];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton = sendButton;
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = MOL_MEDIUM_FONT(14);
    [sendButton setTitleColor:HEX_COLOR(0xC7C7CD) forState:UIControlStateNormal];
    [sendButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateSelected];
    [sendButton addTarget:self action:@selector(button_clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:sendButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xededed);
    [toolView addSubview:lineView];
    
    MOLRecordInputView *recordView = [[MOLRecordInputView alloc] init];
    _recordView = recordView;
    recordView.delegate = self;
    recordView.keyBoardType = MOLRecordInputViewType_begin;
    [backView addSubview:recordView];
    
    [self calculatorInputViewFrame:kRecordInputHeight];
}

- (void)calculatorInputViewFrame:(CGFloat)height
{
    self.gestureButton.width = MOL_SCREEN_WIDTH;
    
    self.backView.width = MOL_SCREEN_WIDTH;
    
    self.toolView.width = self.backView.width;
    self.toolView.height = self.textView.height;
    
    self.textView.width = MOL_SCREEN_WIDTH - 100 - 20;
    self.textView.x = 20;
    self.textView.y = 0;
    
    self.switchButton.width = 30;
    self.switchButton.height = 30;
    self.switchButton.y = self.toolView.height - 6 - self.switchButton.height;
    self.switchButton.x = self.textView.right + 10;
    
    self.sendButton.width = 60;
    self.sendButton.height = 30;
    self.sendButton.centerY = self.switchButton.centerY;
    self.sendButton.right = self.toolView.width - 5;
    
    self.lineView.width = self.toolView.width;
    self.lineView.height = 1;
    self.lineView.y = self.toolView.height - 1;
    
    self.recordView.height = kRecordInputHeight;
    self.recordView.width = self.backView.width;
    self.recordView.y = self.toolView.bottom;
    
    self.backView.height = MOL_TabbarSafeBottomMargin + height + self.toolView.height;
    self.backView.y = self.height - self.backView.height;
    self.gestureButton.height = self.height - self.backView.height;
}

@end
