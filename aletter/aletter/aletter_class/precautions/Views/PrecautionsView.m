//
//  PrecautionsView.m
//  aletter
//
//  Created by xujin on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "PrecautionsView.h"
#import "MOLSheildModel.h"
#import "MOLHead.h"


@interface PrecautionsView()<UITextFieldDelegate>
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,strong) MOLSheildModel *model;
@property(nonatomic,assign) NSInteger contentType;
@property(nonatomic,strong) UIView *topView;
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UITextField *textField;
@property(nonatomic,strong) UILabel *tipLable;
@end

@implementation PrecautionsView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentType =0;
       // [self setBackgroundColor: [UIColor redColor]];
    }
    return self;
}

- (void)precautionsView:(NSInteger)type count:(NSInteger)count{
    self.contentType =type;
    for (id views in self.subviews) {
        [views removeFromSuperview];
    }
    self.bottomView =UIView.new;
    [self addSubview:self.bottomView];
    self.textField =[UITextField new];
    [self.textField setDelegate:self];
    [self.textField setPlaceholder: @"1~10个字"];
    [self.textField setTextColor:HEX_COLOR_ALPHA(0xffffff, 0.5)];
    [self.textField setFont:MOL_REGULAR_FONT(13)];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    //_phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:self.textField.placeholder];
    
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:HEX_COLOR_ALPHA(0xffffff, 0.5)
                        range:NSMakeRange(0, self.textField.placeholder.length)];
    [placeholder addAttribute:NSFontAttributeName
                        value:MOL_REGULAR_FONT(13)
                        range:NSMakeRange(0, self.textField.placeholder.length)];
    self.textField.attributedPlaceholder = placeholder;
    [self.textField setKeyboardType:UIKeyboardTypeDefault];
    [self.textField setReturnKeyType:UIReturnKeyDone];
    [self.bottomView addSubview:self.textField];
    
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setImage:[UIImage imageNamed:@"addPrecautions"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(completeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:button];
    
    UIView *lineView =UIView.new;
    [lineView setBackgroundColor:HEX_COLOR_ALPHA(0xffffff, 0.2)];
    [self.bottomView addSubview:lineView];
    [self.bottomView setHidden:YES];
    
    
    __weak __typeof(self) weakSelf = self;
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(weakSelf);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.bottomView).offset(-20);
        make.bottom.mas_equalTo(lineView.mas_top).offset(-8);
        make.width.height.mas_equalTo(28);
    }];
    
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.bottomView).offset(20);
        make.bottom.mas_equalTo(lineView.mas_top).offset(-8);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(18);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.bottomView.mas_left).offset(20);
        make.right.mas_equalTo(weakSelf.bottomView.mas_right).offset(-20);
        make.height.mas_equalTo(1);
        make.top.mas_equalTo(weakSelf.bottomView.mas_bottom);
    }];
    
    
    self.topView =UIView.new;
    //[topView setBackgroundColor: [UIColor blueColor]];
    [self addSubview:self.topView];
    
    UILabel *content =UILabel.new;
    [content setBackgroundColor:[UIColor clearColor]];
    [content setText:@"+添加屏蔽关键词"];
    [content setTextColor:HEX_COLOR(0xffffff)];
    [content setFont:MOL_REGULAR_FONT(14)];
    [content setTextAlignment:NSTextAlignmentLeft];
    [self.topView addSubview:content];
    
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.topView addGestureRecognizer:tap];
    
    self.tipLable =[UILabel new];
    [self.tipLable setBackgroundColor:[UIColor clearColor]];
    [self.tipLable setText:[NSString stringWithFormat:@"已屏蔽%ld/30",count]];
    [self.tipLable setTextColor:HEX_COLOR_ALPHA(0xffffff, 0.6)];
    [self.tipLable setFont:MOL_REGULAR_FONT(14)];
    [self.tipLable setTextAlignment:NSTextAlignmentRight];
    //[tipLable setBackgroundColor: [UIColor yellowColor]];
    [self.topView addSubview:self.tipLable];
    
  //  __weak __typeof(self) weakSelf = self;
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(weakSelf);
    }];
    
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.topView).offset(20);
        make.right.mas_lessThanOrEqualTo(weakSelf.tipLable.mas_left);
        make.bottom.mas_equalTo(weakSelf.topView).offset(-8);
        make.height.mas_equalTo(28);
    }];
    
    
    [self.tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.topView).offset(-20);
        make.left.mas_greaterThanOrEqualTo(content.mas_right);
        make.bottom.mas_equalTo(weakSelf.topView).offset(-8);
        make.height.mas_equalTo(28);
    }];
    
    
}

- (void)tap:(UITapGestureRecognizer *)tap{
    [self topShow];
}

#pragma mark-
#pragma mark 删除事件
- (void)completeEvent:(UIButton *)sender{
    MOLSheildModel *moldel =[MOLSheildModel new];
    moldel.name =self.textField.text;
    self.precautionsAddWordBlock(moldel);
    [self endEvent];
    NSLog(@"完成事件");
   // self.cellDeleteBlock(self.indexPath, self.model);
}

-(void)topShow{
    [self.textField becomeFirstResponder];
    [self.topView setHidden:YES];
    [self.bottomView setHidden:NO];
}

-(void)endEvent{
    [self.textField setText:@""];
    [self.bottomView setHidden:YES];
    [self.topView setHidden:NO];
    [self.textField resignFirstResponder];
}

- (void)precautionsViewShowTopEvent:(NSInteger)count{
    [self.tipLable setText:[NSString stringWithFormat:@"已屏蔽%ld/30",count]];
    [self endEvent];
}

#pragma mark
#pragma mark UITextFieldDelegate
/**
 *  手机ha控制位数为11位
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        if (self.textField.text.length>0) {
            MOLSheildModel *moldel =[MOLSheildModel new];
            moldel.name =self.textField.text;
            self.precautionsAddWordBlock(moldel);
        }
        [self endEvent];
    }
        if (string.length == 0) return YES;
    
//    if (textField == self.textField) {
//        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
//        if (range.length == 1 && string.length == 0) {
//            return YES;
//        }
//        //so easy
//        else if (self.textField.text.length >= 10) {
//            self.textField.text = [textField.text substringToIndex:10];
//            return NO;
//        }
//    }


    return YES;
}


- (void)textFieldDidChange:(UITextField *)textField
{
    if (!textField||!textField.text) {
        return;
    }
    //将要结束的时候判断所有数据是否填充完整，来判断下一步是否可以点击
    if (self.textField==textField) {
        if (self.textField.text.length > 10) {
            self.textField.text = [self.textField.text substringToIndex:10];
        }
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
