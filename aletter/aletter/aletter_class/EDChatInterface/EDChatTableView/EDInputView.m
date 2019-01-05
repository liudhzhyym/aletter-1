//
//  EDInputView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDInputView.h"
#import "JAGrowingTextView.h"
#import "MOLHead.h"
#import "TZImagePickerController.h"

@interface EDInputView ()<JAGrowingTextViewDelegate,YYTextKeyboardObserver,EDRecordInputViewDelegate,TZImagePickerControllerDelegate>

@property (nonatomic, weak) JAGrowingTextView *textView;  // 文本框
@property (nonatomic, weak) UIButton *switchButton;  // 键盘录音开关按钮
@property (nonatomic, weak) UIButton *pictureButton;  // 图片开关按钮
@property (nonatomic, assign) CGFloat originalH;
@end

@implementation EDInputView

-(void)dealloc
{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInputViewUI];
        self.backgroundColor = [UIColor whiteColor];
        [[YYTextKeyboardManager defaultManager] addObserver:self];
    }
    return self;
}

- (void)inputResetText
{
    self.textView.text = nil;
}

- (void)inputRegist
{
    [self.textView resignFirstResponder];
}

- (void)inputBecomeFirstResponse
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.textView resignFirstResponder];
//        [self.textView reloadInputViews];
//        [self.textView becomeFirstResponder];
        [self.textView becomeFirstResponder];
    });
}

#pragma mark - JAGrowingTextViewDelegate
- (void)didChangeHeight:(CGFloat)height
{
    self.height = self.textView.height + 6 + MOL_TabbarSafeBottomMargin;
    self.y = self.y + self.originalH - self.height;
    if (self.originalH != self.height) {
        self.originalH = self.height;
    }
    self.switchButton.bottom = self.height - 6 - MOL_TabbarSafeBottomMargin;
    self.pictureButton.bottom = self.height - 6 - MOL_TabbarSafeBottomMargin;
}
- (void)textViewDidChange:(JAGrowingTextView *)growingTextView
{

}

// 发送文本
- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    if ([replacementText isEqualToString:@"\n"]) {
        // 发送
        if (self.textView.text.length) {
            if ([self.delegate respondsToSelector:@selector(input_sendTextMessage:)]) {   // 发送文本
                [self.delegate input_sendTextMessage:self.textView.text];
            }
        }
        
        return NO;
    }
    return YES;
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition
{
    CGRect kbFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self];
    
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        ///用此方法获取键盘的rect
        if (kbFrame.origin.y < 5) {  // 上
            self.y = self.superview.height - self.height - kbFrame.size.height;
            self.switchButton.selected = self.textView.inputView == nil ? NO : YES;
        }else{   // 下
            self.y = self.superview.height - self.height;
            self.switchButton.selected = NO;
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - EDRecordInputViewDelegate
// 发送语音
- (void)record_endWithFile:(NSString *)file time:(NSInteger)time ifyResult:(NSArray *)result
{
    if (!file.length) { // 录音失败
        return;
    }
    NSString *string = [result componentsJoinedByString:@""];
    // 上传阿里云
    [[MOLALiyunManager shareALiyunManager] aLiyun_uploadVoiceFile:file fileType:@"mp3" complete:^(NSString *filePath) {
       
        if (filePath.length) {

            if ([self.delegate respondsToSelector:@selector(input_sendAudioMessage:time:results:)]) {    // 发送语音
                // 发送语音
                [self.delegate input_sendAudioMessage:filePath time:time results:string];
            }
        }
    }];
    
}
- (void)record_fail
{
    [MOLToast toast_showWithWarning:YES title:@"录音失败"];
}

#pragma mark - TZImagePickerControllerDelegate
// 发送图片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
    // 上传阿里云
    [[MOLALiyunManager shareALiyunManager] aLiyun_uploadImages:photos complete:^(NSArray<NSDictionary *> *names) {
        
        if (names.count) {
            NSDictionary *dic = names.firstObject;
            // 发送图片
            if ([self.delegate respondsToSelector:@selector(input_sendImageMessage:)]) {
                [self.delegate input_sendImageMessage:[dic mol_jsonString:@"src"]];
            }
        }
    }];
}

#pragma mark - 按钮的点击
- (void)button_clickSwitchButton:(UIButton *)button
{
    if (self.textView.inputView) {
        self.textView.inputView = nil;
        [self.textView resignFirstResponder];
        [self.textView reloadInputViews];
        [self.textView becomeFirstResponder];
    }else{
        self.textView.inputView = self.recordInputView;
        [self.textView resignFirstResponder];
        [self.textView reloadInputViews];
        [self.textView becomeFirstResponder];
    }
}

- (void)button_clickPictureButton:(UIButton *)button   // 弹出图片选择框
{
//    [self.textView resignFirstResponder];
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    [imagePickerVc setNaviBgColor: [UIColor clearColor]];
    
    [[[MOLGlobalManager shareGlobalManager] global_currentViewControl] presentViewController:imagePickerVc animated:YES completion:nil];
    
}

#pragma mark - UI
- (void)setupInputViewUI
{
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
    textView.clipsToBounds = YES;
    
    [self addSubview:textView];
    
    UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _switchButton = switchButton;
    [switchButton setImage:[UIImage imageNamed:@"meet_comment_voice"] forState:UIControlStateNormal];
    [switchButton setImage:[UIImage imageNamed:@"meet_comment_keyboard"] forState:UIControlStateSelected];
    [switchButton addTarget:self action:@selector(button_clickSwitchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchButton];
    
    UIButton *pictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _pictureButton = pictureButton;
    [pictureButton setImage:[UIImage imageNamed:@"遇见"] forState:UIControlStateNormal];
    [pictureButton addTarget:self action:@selector(button_clickPictureButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pictureButton];
    
    [self calculatorInputViewFrame];
}

- (void)calculatorInputViewFrame
{
    self.height = self.textView.height + 6 + MOL_TabbarSafeBottomMargin;
    self.textView.width = MOL_SCREEN_WIDTH - 100 - 20;
    self.textView.x = 20;
    self.textView.y = (self.height - self.textView.height - MOL_TabbarSafeBottomMargin) * 0.5;
    
    self.switchButton.width = 30;
    self.switchButton.height = 30;
    self.switchButton.x = self.textView.right + 15;
    self.switchButton.bottom = self.height - 6 - MOL_TabbarSafeBottomMargin;
    
    self.pictureButton.width = 30;
    self.pictureButton.height = 30;
    self.pictureButton.x = self.switchButton.right + 15;
    self.pictureButton.bottom = self.height - 6 - MOL_TabbarSafeBottomMargin;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.width != 0) {
        self.originalH = self.height;
    }
}

#pragma mark - 懒加载
- (EDRecordInputView *)recordInputView
{
    if (_recordInputView == nil) {
        
        _recordInputView = [[EDRecordInputView alloc] init];
        _recordInputView.width = MOL_SCREEN_WIDTH;
        _recordInputView.height = 252;
        _recordInputView.delegate = self;
    }
    
    return _recordInputView;
}

- (void)setPlaceholder:(NSString *)placeholder{
    self.textView.placeholderAttributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@说...",placeholder?placeholder:@"我"] attributes:@{NSForegroundColorAttributeName : HEX_COLOR_ALPHA(0x091F38,0.7),NSFontAttributeName : MOL_LIGHT_FONT(14)}];
}
@end
