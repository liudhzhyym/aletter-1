//
//  MOLToast.m
//  aletter
//
//  Created by moli-2017 on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLToast.h"
#import "MOLHead.h"

@interface MOLToast ()
@property (nonatomic, weak) UIButton *tapButton;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *titleLabel;
@end

@implementation MOLToast

+ (void)toast_showWithWarning:(BOOL)warning title:(NSString *)title
{
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MOLToast class]]) {
            obj.hidden = YES;
            obj = nil;
        }
    }];
    
    __block MOLToast *v = [[MOLToast alloc] init];
    v.imageView.image = warning ? [UIImage imageNamed:INTITLE_Warning_Read] : [UIImage imageNamed:INTITLE_LEFT_Highlight];
    v.titleLabel.text = title;
    [v.titleLabel sizeToFit];
    v.windowLevel = UIWindowLevelAlert;
    v.width = MOL_SCREEN_WIDTH;
    v.height = MOL_StatusBarAndNavigationBarHeight;
    v.backgroundColor = HEX_COLOR(0x074D81);
    v.hidden = NO;
    v.y = -v.height;
    [UIView animateWithDuration:0.5 animations:^{
        v.y = 0;
    } completion:^(BOOL finished) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                v.y = -v.height;
            } completion:^(BOOL finished) {
                v.hidden = YES;
                v = nil;
            }];
        });
    }];
}

+ (void)toast_hidden
{
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MOLToast class]]) {
            obj.hidden = YES;
            obj = nil;
        }
    }];
}

- (void)hiddenSelf
{
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MOLToast class]]) {
            __block UIWindow *v = obj;
            [UIView animateWithDuration:0.5 animations:^{
                v.y = -v.height;
            } completion:^(BOOL finished) {
                v.hidden = YES;
                v = nil;
            }];
        }
    }];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupToastUI];
    }
    return self;
}

- (void)setupToastUI
{
    UIButton *tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _tapButton = tapButton;
    [tapButton addTarget:self action:@selector(hiddenSelf) forControlEvents:UIControlEventTouchDown];
    [self addSubview:tapButton];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:INTITLE_LEFT_Highlight]];
    _imageView = imageView;
    [self addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @" ";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.numberOfLines = 2;
    titleLabel.font = MOL_MEDIUM_FONT(14);
    
    [self addSubview:titleLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tapButton.frame = self.bounds;
    
    self.imageView.x = 20;
    self.imageView.y = self.height - 20 - self.imageView.height;
    
    self.titleLabel.x = self.imageView.right + 7;
    [self.titleLabel sizeToFit];
    self.titleLabel.width = MOL_SCREEN_WIDTH - self.titleLabel.x - 10;
    self.titleLabel.centerY = self.imageView.centerY;
}
@end
