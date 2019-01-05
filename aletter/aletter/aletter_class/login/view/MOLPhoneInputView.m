//
//  MOLPhoneInputView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/2.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPhoneInputView.h"
#import "MOLHead.h"
#import "MOLWebViewController.h"

@interface MOLPhoneInputView ()<UITextFieldDelegate>
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) YYLabel *protocolLabel;
@end

@implementation MOLPhoneInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPhoneInputViewUI];
    }
    return self;
}

- (void)setType:(NSInteger)type
{
    _type = type;
    if (type == 0) return;
    self.titleLabel.text = @"绑定手机号";
    self.subTitleLabel.text = @"为了维护有封信秩序，防止恶意注册，保障账号的安全，请绑定手机号。";
    [self.titleLabel sizeToFit];
    [self.subTitleLabel sizeToFit];
}

#pragma mark - UI
- (void)setupPhoneInputViewUI
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"手机登录";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = MOL_MEDIUM_FONT(26);
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel = subTitleLabel;
    subTitleLabel.text = @"未经注册过的手机号将自动创建有封信账号";
    subTitleLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    subTitleLabel.font = MOL_REGULAR_FONT(14);
    subTitleLabel.numberOfLines = 2;
    [self addSubview:subTitleLabel];
    
    UITextField *phoneTextField = [[UITextField alloc] init];
    _phoneTextField = phoneTextField;
    phoneTextField.font = MOL_REGULAR_FONT(14);
    phoneTextField.textColor = HEX_COLOR(0xffffff);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"请输入手机号码" attributes:
  @{NSForegroundColorAttributeName:HEX_COLOR_ALPHA(0xffffff, 0.6),NSFontAttributeName:phoneTextField.font}];
    phoneTextField.attributedPlaceholder = attrString;
    phoneTextField.delegate = self;
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [phoneTextField becomeFirstResponder];
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [[phoneTextField valueForKey:@"_clearButton"] setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
    [self addSubview:phoneTextField];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    [self addSubview:lineView];
    
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"继续代表您同意"];
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc] initWithString:@"有封信用户协议"];
    text.yy_font = MOL_MEDIUM_FONT(14);
    text.yy_color = HEX_COLOR(0xffffff);
    one.yy_font = MOL_MEDIUM_FONT(14);
    one.yy_color = HEX_COLOR(0xF4C054);
    one.yy_underlineStyle = NSUnderlineStyleSingle;
    @weakify(self);
    [one yy_setTextHighlightRange:one.yy_rangeOfAll
                            color:HEX_COLOR(0xF4C054)
                  backgroundColor:[UIColor clearColor]
                        tapAction:^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
                            @strongify(self);
                            MOLWebViewController *vc  = [[MOLWebViewController alloc] init];
                            NSString *baseUrl = MOL_OFFIC_SERVICE;  // 正式
                            NSString *url = @"/h5/static/views/app/about/userAgreement.html";
#ifdef MOL_TEST_HOST
                            baseUrl = MOL_TEST_SERVICE;  // 测试
#endif
                            NSString *str =[NSString stringWithFormat:@"%@%@",baseUrl,url];
                            vc.urlString = str;
                            vc.titleString = @"用户协议";
                            [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
                        }];
    [text appendAttributedString:one];
    YYLabel *protocolLabel = [[YYLabel alloc] init];
    _protocolLabel = protocolLabel;
    protocolLabel.width = 200;
    protocolLabel.height = 30;
    protocolLabel.attributedText = text;
    [self addSubview:protocolLabel];
}

- (void)calculatorPhoneInputViewFrame
{
    [self.titleLabel sizeToFit];
    self.titleLabel.x = 20;
    self.titleLabel.y = 32;// + MOL_StatusBarAndNavigationBarHeight;
    
    self.subTitleLabel.width = self.width - 40;
    [self.subTitleLabel sizeToFit];
    self.subTitleLabel.x = self.titleLabel.x;
    self.subTitleLabel.y = self.titleLabel.bottom + 10;
    
    self.phoneTextField.width = self.width - 40;
    self.phoneTextField.height = 30;
    self.phoneTextField.x = self.titleLabel.x;
    self.phoneTextField.y = self.titleLabel.bottom + 70;
    if (iPhone4){
        self.phoneTextField.y = self.titleLabel.bottom + 35;
    }
    
    self.lineView.width = self.phoneTextField.width;
    self.lineView.height = 1;
    self.lineView.x = self.phoneTextField.x;
    self.lineView.y = self.phoneTextField.bottom + 10;
    
    self.protocolLabel.centerX = self.width * 0.5;
    self.protocolLabel.bottom = self.height - 240;
    if (iPhone4){
        self.protocolLabel.bottom = self.lineView.bottom + 5;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorPhoneInputViewFrame];
}

#pragma mark - 手机号的输入设置
// 手机号码输入
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField) {
        NSString* text = textField.text;
        //删除
        if([string isEqualToString:@""]){
            
            //删除一位
            if(range.length == 1){
                //最后一位,遇到空格则多删除一次
                if (range.location == text.length-1 ) {
                    if ([text characterAtIndex:text.length-1] == ' ') {
                        [textField deleteBackward];
                    }
                    return YES;
                }
                //从中间删除
                else{
                    NSInteger offset = range.location;
                    
                    if (range.location < text.length && [text characterAtIndex:range.location] == ' ' && [textField.selectedTextRange isEmpty]) {
                        [textField deleteBackward];
                        offset --;
                    }
                    [textField deleteBackward];
                    textField.text = [self parseString:textField.text];
                    UITextPosition *newPos = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
                    textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
                    return NO;
                }
            }
            else if (range.length > 1) {
                BOOL isLast = NO;
                //如果是从最后一位开始
                if(range.location + range.length == textField.text.length ){
                    isLast = YES;
                }
                [textField deleteBackward];
                textField.text = [self parseString:textField.text];
                
                NSInteger offset = range.location;
                if (range.location == 3 || range.location  == 8) {
                    offset ++;
                }
                if (isLast) {
                    //光标直接在最后一位了
                }else{
                    UITextPosition *newPos = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
                    textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
                }
                
                return NO;
            }
            
            else{
                return YES;
            }
        }
        
        else if(string.length >0){
            
            //限制输入字符个数
            if (([self noneSpaseString:textField.text].length + string.length - range.length > 11) ) {
                return NO;
            }
            //判断是否是纯数字(千杀的搜狗，百度输入法，数字键盘居然可以输入其他字符)
            //            if(![string isNum]){
            //                return NO;
            //            }
            [textField insertText:string];
            textField.text = [self parseString:textField.text];
            
            NSInteger offset = range.location + string.length;
            if (range.location == 3 || range.location  == 8) {
                offset ++;
            }
            UITextPosition *newPos = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
            textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
            return NO;
        }else{
            return YES;
        }
    }
    return YES;
}

-(NSString*)noneSpaseString:(NSString*)string
{
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString*)parseString:(NSString*)string
{
    if (!string) {
        return nil;
    }
    NSMutableString* mStr = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if (mStr.length >3) {
        [mStr insertString:@" " atIndex:3];
    }if (mStr.length > 8) {
        [mStr insertString:@" " atIndex:8];
    }
    return  mStr;
}
@end
