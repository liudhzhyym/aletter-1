//
//  MOLFiltrateView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLFiltrateView.h"
#import "MOLHead.h"

@interface MOLFiltrateView ()<CAAnimationDelegate>
@property (nonatomic, weak) UIView *contentView;  // 内容view

@property (nonatomic, weak) UIView *contentView_top;  // 内容view

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) UIView *contentView_bottom;  // 内容view

@property (nonatomic, weak) UIView *lineView1;

@property (nonatomic, weak) UIView *contentView_admin;  // 内容view

@property (nonatomic, weak) UIButton *sureButton; // 确认按钮

@property (nonatomic, strong) NSArray *sexArray;
@property (nonatomic, strong) NSArray *ageArray;
@property (nonatomic, strong) NSArray *adminArray;

@property (nonatomic, strong) NSMutableArray *filSexArr;
@property (nonatomic, strong) NSMutableArray *filAgeArr;
@property (nonatomic, strong) NSMutableArray *filAdminArr;
@end

@implementation MOLFiltrateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.filAgeArr = [NSMutableArray array];
        self.filSexArr = [NSMutableArray array];
        self.filAdminArr = [NSMutableArray array];
        
        self.sexArray = @[@"全部",MOL_SEX_SAME,MOL_SEX_UNSAME];
        self.ageArray = @[@"全部",MOL_AGE_00,MOL_AGE_95,MOL_AGE_90,MOL_AGE_85,MOL_AGE_80,MOL_AGE_75];
        self.adminArray = @[@"全部",@"官方",@"用户"];
        
        [self.filAgeArr addObjectsFromArray:self.ageArray];
        [self.filSexArr addObjectsFromArray:self.sexArray];
        [self.filAdminArr addObjectsFromArray:self.adminArray];
        
        [self setupFiltrateViewUI];
        
        @weakify(self);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [[tap rac_gestureSignal] subscribeNext:^(id x) {
            @strongify(self);
            [self filtrateView_hidden];
        }];
        [self addGestureRecognizer:tap];
        
        self.commitReplySubject = [RACReplaySubject subject];
    }
    return self;
}

#pragma mark - 按钮点击
- (void)buttonClick_sexbuttonClick:(UIButton *)button   // 点击性别
{
    button.selected = !button.selected;
    if (button.tag == 1) {
        [self buttonChooseStatus:self.contentView_top.subviews isAll:YES];
    }else{
        [self buttonChooseStatus:self.contentView_top.subviews isAll:NO];
    }
    
    if (button.tag == 1) {
        
        if (button.selected) {  // 添加全部
            for (NSInteger i = 0; i<self.sexArray.count; i++) {
                NSString *name = self.sexArray[i];
                if (![self.filSexArr containsObject:name]) {
                    [self.filSexArr addObject:name];
                }
            }
        }else{   // 移除全部
            [self.filSexArr removeAllObjects];
        }
        
    }else{
        
        if (button.selected) {   // 添加
            if (![self.filSexArr containsObject:button.currentTitle]) {
                [self.filSexArr addObject:button.currentTitle];
            }
            if (self.filSexArr.count == self.sexArray.count - 1) {
                [self.filSexArr insertObject:@"全部" atIndex:0];
            }
        }else{  // 移除
            if ([self.filSexArr containsObject:button.currentTitle]) {
                [self.filSexArr removeObject:button.currentTitle];
            }
            if (self.filSexArr.count < self.sexArray.count) {
                [self.filSexArr removeObject:@"全部"];
            }
        }
    }
}

- (void)buttonChooseStatus:(NSArray *)buttonArray isAll:(BOOL)isAll
{
    if (isAll) {
        UIButton *btn = buttonArray.firstObject;
        [buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = btn.selected;
        }];
    }else{
        __block BOOL all = YES;
        [buttonArray enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.selected && obj.tag != 1) {
                all = NO;
                *stop = YES;
            }
        }];
        UIButton *btn = buttonArray.firstObject;
        btn.selected = all;
    }
}

- (void)buttonClick_ageButtonClick:(UIButton *)button    // 点击年龄
{
    button.selected = !button.selected;
    if (button.tag == 1) {
        [self buttonChooseStatus:self.contentView_bottom.subviews isAll:YES];
    }else{
        [self buttonChooseStatus:self.contentView_bottom.subviews isAll:NO];
    }
    
    if (button.tag == 1) {
        
        if (button.selected) {  // 添加全部
            for (NSInteger i = 0; i<self.ageArray.count; i++) {
                NSString *name = self.ageArray[i];
                if (![self.filAgeArr containsObject:name]) {
                    [self.filAgeArr addObject:name];
                }
            }
        }else{   // 移除全部
            [self.filAgeArr removeAllObjects];
        }
        
    }else{
        
        if (button.selected) {   // 添加
            if (![self.filAgeArr containsObject:button.currentTitle]) {
                [self.filAgeArr addObject:button.currentTitle];
            }
            if (self.filAgeArr.count == self.ageArray.count - 1) {
                [self.filAgeArr insertObject:@"全部" atIndex:0];
            }
        }else{  // 移除
            if ([self.filAgeArr containsObject:button.currentTitle]) {
                [self.filAgeArr removeObject:button.currentTitle];
            }
            if (self.filAgeArr.count < self.ageArray.count) {
                [self.filAgeArr removeObject:@"全部"];
            }
        }
    }
}

- (void)buttonClick_adminButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.tag == 1) {
        [self buttonChooseStatus:self.contentView_admin.subviews isAll:YES];
    }else{
        [self buttonChooseStatus:self.contentView_admin.subviews isAll:NO];
    }
    
    if (button.tag == 1) {
        
        if (button.selected) {  // 添加全部
            for (NSInteger i = 0; i<self.adminArray.count; i++) {
                NSString *name = self.adminArray[i];
                if (![self.filAdminArr containsObject:name]) {
                    [self.filAdminArr addObject:name];
                }
            }
        }else{   // 移除全部
            [self.filAdminArr removeAllObjects];
        }
        
    }else{
        
        if (button.selected) {   // 添加
            if (![self.filAdminArr containsObject:button.currentTitle]) {
                [self.filAdminArr addObject:button.currentTitle];
            }
            if (self.filAdminArr.count == self.adminArray.count - 1) {
                [self.filAdminArr insertObject:@"全部" atIndex:0];
            }
        }else{  // 移除
            if ([self.filAdminArr containsObject:button.currentTitle]) {
                [self.filAdminArr removeObject:button.currentTitle];
            }
            if (self.filAdminArr.count < self.adminArray.count) {
                [self.filAdminArr removeObject:@"全部"];
            }
        }
    }
}

- (void)commitFiltrateInfo  // 确认数据
{
    if (self.filSexArr.count == 0 && self.filAgeArr.count == 0) {
        [MOLToast toast_showWithWarning:YES title:@"至少选择一个条件"];
        return;
    }
    
    if ([MOLUserManagerInstance user_isPower]) {
        [self filtrateView_hidden];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"sexArr"] = self.filSexArr;
        dic[@"ageArr"] = self.filAgeArr;
        dic[@"adminArr"] = self.filAdminArr;
        [self.commitReplySubject sendNext:dic];
    }else{
        [self filtrateView_hidden];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"sexArr"] = self.filSexArr;
        dic[@"ageArr"] = self.filAgeArr;
        [self.commitReplySubject sendNext:dic];
    }
}

- (void)filtrateView_show
{
    self.hidden = NO;
    self.contentView.x = self.width;
    [UIView animateWithDuration:.4 animations:^{
        self.contentView.right = self.width;
    }];
}

- (void)filtrateView_hidden
{

    [UIView animateWithDuration:.4 animations:^{
        self.contentView.x = self.width;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    [self.layer removeAllAnimations];
}

#pragma mark -UI
- (void)setupFiltrateViewUI
{
    UIView *contentView = [[UIView alloc] init];
    _contentView = contentView;
    contentView.backgroundColor = HEX_COLOR_ALPHA(0x284D6B, 0.95);
    [self addSubview:contentView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [contentView addGestureRecognizer:tap];
    
    UIView *contentView_top = [[UIView alloc] init];
    _contentView_top = contentView_top;
    contentView_top.backgroundColor = [UIColor clearColor];
    [contentView addSubview:contentView_top];
    
    for (NSInteger i = 0; i < self.sexArray.count; i++) {
        NSString *name = self.sexArray[i];
        UIButton *sexButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sexButton.tag = i + 1;
        [sexButton setTitle:name forState:UIControlStateNormal];
        [sexButton setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.7) forState:UIControlStateNormal];
        [sexButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
        [sexButton setImage:[UIImage imageNamed:@"detail_filtrate"] forState:UIControlStateNormal];
        [sexButton setImage:[UIImage imageNamed:@"detail_filtrated"] forState:UIControlStateSelected];
        [sexButton setImage:[UIImage imageNamed:@"detail_filtrated"] forState:UIControlStateSelected | UIControlStateHighlighted];
        sexButton.titleLabel.font = MOL_LIGHT_FONT(14);
        [sexButton addTarget:self action:@selector(buttonClick_sexbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        sexButton.selected = YES;
        [contentView_top addSubview:sexButton];
    }
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.1);
    [contentView addSubview:lineView];
    
    UIView *contentView_bottom = [[UIView alloc] init];
    _contentView_bottom = contentView_bottom;
    contentView_bottom.backgroundColor = [UIColor clearColor];
    [contentView addSubview:contentView_bottom];
    
    for (NSInteger i = 0; i < self.ageArray.count; i++) {
        NSString *name = self.ageArray[i];
        UIButton *ageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        ageButton.tag = i + 1;
        [ageButton setTitle:name forState:UIControlStateNormal];
        [ageButton setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.7) forState:UIControlStateNormal];
        [ageButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
        [ageButton setImage:[UIImage imageNamed:@"detail_filtrate"] forState:UIControlStateNormal];
        [ageButton setImage:[UIImage imageNamed:@"detail_filtrated"] forState:UIControlStateSelected];
        [ageButton setImage:[UIImage imageNamed:@"detail_filtrated"] forState:UIControlStateSelected | UIControlStateHighlighted];
        ageButton.titleLabel.font = MOL_LIGHT_FONT(14);
        [ageButton addTarget:self action:@selector(buttonClick_ageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        ageButton.selected = YES;
        [contentView_bottom addSubview:ageButton];
    }
    
    if ([MOLUserManagerInstance user_isPower]) {
        UIView *lineView1 = [[UIView alloc] init];
        _lineView1 = lineView1;
        lineView1.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.1);
        [contentView addSubview:lineView1];
        
        UIView *contentView_admin = [[UIView alloc] init];
        _contentView_admin = contentView_admin;
        contentView_admin.backgroundColor = [UIColor clearColor];
        [contentView addSubview:contentView_admin];
        
        for (NSInteger i = 0; i < self.adminArray.count; i++) {
            NSString *name = self.adminArray[i];
            UIButton *adminButton = [UIButton buttonWithType:UIButtonTypeCustom];
            adminButton.tag = i + 1;
            [adminButton setTitle:name forState:UIControlStateNormal];
            [adminButton setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.7) forState:UIControlStateNormal];
            [adminButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
            [adminButton setImage:[UIImage imageNamed:@"detail_filtrate"] forState:UIControlStateNormal];
            [adminButton setImage:[UIImage imageNamed:@"detail_filtrated"] forState:UIControlStateSelected];
            [adminButton setImage:[UIImage imageNamed:@"detail_filtrated"] forState:UIControlStateSelected | UIControlStateHighlighted];
            adminButton.titleLabel.font = MOL_LIGHT_FONT(14);
            [adminButton addTarget:self action:@selector(buttonClick_adminButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            adminButton.selected = YES;
            [contentView_admin addSubview:adminButton];
        }
    }
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureButton = sureButton;
    [sureButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    [sureButton setTitle:@"确认" forState:UIControlStateNormal];
    sureButton.titleLabel.font = MOL_REGULAR_FONT(14);
    sureButton.layer.cornerRadius = 5;
    sureButton.layer.borderColor = HEX_COLOR(0xffffff).CGColor;
    sureButton.layer.borderWidth = 1;
    sureButton.layer.masksToBounds = YES;
    [sureButton addTarget:self action:@selector(commitFiltrateInfo) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:sureButton];
}

- (void)calculatorFiltrateViewFrame
{
    self.contentView.width = 160;
    self.contentView.height = self.height;
    self.contentView.right = self.width;
    
    self.contentView_top.width = self.contentView.width;
    self.contentView_top.height = 125;
    self.contentView_top.y = 10 + MOL_StatusBarHeight;
    
    CGFloat w = 160 - 30;
    CGFloat h = 30;
    CGFloat margin = 10;
    
    for (NSInteger i = 0; i < self.contentView_top.subviews.count; i++) {
        UIButton *v = self.contentView_top.subviews[i];
        v.y = margin + i * (h + margin);
        v.width = w;
        v.height = h;
        v.x = 15;
        [v mol_setButtonImageTitleStyle:ButtonImageTitleStyleRightLeft padding:0];
    }
    
    self.lineView.width = 130;
    self.lineView.height = 1;
    self.lineView.x = 15;
    self.lineView.y = self.contentView_top.bottom;
    
    self.contentView_bottom.y = self.lineView.bottom;
    self.contentView_bottom.width = self.contentView.width;
    self.contentView_bottom.height = 290;
    
    for (NSInteger i = 0; i < self.contentView_bottom.subviews.count; i++) {
        UIButton *v = self.contentView_bottom.subviews[i];
        v.y = margin + i * (h + margin);
        v.width = w;
        v.height = h;
        v.x = 15;
        [v mol_setButtonImageTitleStyle:ButtonImageTitleStyleRightLeft padding:0];
    }
    
    self.lineView1.width = 130;
    self.lineView1.height = 1;
    self.lineView1.x = 15;
    self.lineView1.y = self.contentView_bottom.bottom;
    
    self.contentView_admin.y = self.lineView1.bottom;
    self.contentView_admin.width = self.contentView.width;
    self.contentView_admin.height = 125;
    
    for (NSInteger i = 0; i < self.contentView_admin.subviews.count; i++) {
        UIButton *v = self.contentView_admin.subviews[i];
        v.y = margin + i * (h + margin);
        v.width = w;
        v.height = h;
        v.x = 15;
        [v mol_setButtonImageTitleStyle:ButtonImageTitleStyleRightLeft padding:0];
    }
    
    self.sureButton.width = 130;
    self.sureButton.height = 36;
    self.sureButton.x = 15;
    self.sureButton.bottom = self.contentView.height - 15;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorFiltrateViewFrame];
}
@end
