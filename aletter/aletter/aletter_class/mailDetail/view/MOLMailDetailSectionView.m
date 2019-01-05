//
//  MOLMailDetailSectionView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailDetailSectionView.h"
#import "MOLLightTopicModel.h"

@interface MOLMailDetailSectionView ()
@property (nonatomic, weak) UILabel *warnLabel; // 雷区
@property (nonatomic, weak) UIButton *warnButton; // 雷区
@property (nonatomic, weak) UIView *backView;  // 内容view
@property (nonatomic, weak) UILabel *topicNameLabel; // 热门话题
@property (nonatomic, weak) UIButton *moreButton; // 更多

@property (nonatomic, strong) NSMutableArray *topicLabelArray;
@end

@implementation MOLMailDetailSectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _topicLabelArray = [NSMutableArray array];
        [self setupMailDetailSectionViewUI];
        self.moreSubject = [RACReplaySubject subject];
        self.topicSubject = [RACReplaySubject subject];
        self.landSubject = [RACReplaySubject subject];
    }
    return self;
}

#pragma mark - 赋值
- (void)setTopicArray:(NSArray *)topicArray
{
    _topicArray = topicArray;
    
    for (NSInteger i = 0; i < topicArray.count; i++) {
        
        MOLLightTopicModel *model = topicArray[i];
        NSString *title = model.topicName;
        NSString *topicId = model.topicId;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title];
        text.yy_font = MOL_LIGHT_FONT(14);
        text.yy_color = HEX_COLOR(0x4A90E2);
        
        YYTextHighlight *highlight = [YYTextHighlight new];
        [text yy_setTextHighlight:highlight range:text.yy_rangeOfAll];
        
        YYLabel *label = [[YYLabel alloc] init];
        label.attributedText = text;
        @weakify(self);
        label.highlightTapAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect) {
            @strongify(self);
            [self.topicSubject sendNext:topicId];
        };
        [self.topicLabelArray addObject:label];
        [self.backView addSubview:label];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setWarningName:(NSString *)warningName
{
    _warningName = warningName;
    if (self.needTap) {
        NSString *name = [NSString stringWithFormat:@"%@",warningName];
        [self.warnButton setTitle:name forState:UIControlStateNormal];
        self.warnLabel.text = name;
    }else{
        NSString *name = [NSString stringWithFormat:@"%@",warningName];
        self.warnLabel.text = name;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setNeedTap:(BOOL)needTap
{
    _needTap = needTap;
    if (needTap) {
        self.warnButton.hidden = NO;
        self.warnLabel.hidden = YES;
    }else{
        self.warnButton.hidden = YES;
        self.warnLabel.hidden = NO;
    }
}

#pragma mark - 点击
- (void)button_clickWarnLabel
{
    if (self.needTap) {    
        [self.landSubject sendNext:nil];
    }
}

#pragma mark - UI
- (void)setupMailDetailSectionViewUI
{
    UIButton *warnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _warnButton = warnButton;
    warnButton.hidden = YES;
    [warnButton setTitle:@" " forState:UIControlStateNormal];
    [warnButton setTitleColor:HEX_COLOR(0xFAFAF0) forState:UIControlStateNormal];
    [warnButton setImage:[UIImage imageNamed:@"detail_warn_more"] forState:UIControlStateNormal];
    warnButton.titleLabel.font = MOL_REGULAR_FONT(14);
    warnButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    warnButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    @weakify(self);
    [[warnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.landSubject sendNext:nil];
    }];
    [self addSubview:warnButton];
    
    UILabel *warnLabel = [[UILabel alloc] init];
    _warnLabel = warnLabel;
    warnLabel.hidden = YES;
    warnLabel.text = @" ";
    warnLabel.textColor = HEX_COLOR(0xFAFAF0);
    warnLabel.font = MOL_REGULAR_FONT(14);
    warnLabel.numberOfLines = 0;
    UITapGestureRecognizer *labelT = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickWarnLabel)];
    [warnLabel addGestureRecognizer:labelT];
    warnLabel.userInteractionEnabled = YES;
    [self addSubview:warnLabel];
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = HEX_COLOR(0xffffff);
    [self addSubview:backView];
    
    UILabel *topicNameLabel = [[UILabel alloc] init];
    _topicNameLabel = topicNameLabel;
    topicNameLabel.text = @"热门话题";
    topicNameLabel.textColor = HEX_COLOR(0x074D81);
    topicNameLabel.font = MOL_MEDIUM_FONT(14);
    [backView addSubview:topicNameLabel];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreButton = moreButton;
    [moreButton setTitle:@"更多" forState:UIControlStateNormal];
    [moreButton setTitleColor:HEX_COLOR(0x537A99) forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"detail_topic_more"] forState:UIControlStateNormal];
    moreButton.titleLabel.font = MOL_LIGHT_FONT(14);
    [[moreButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.moreSubject sendNext:nil];
    }];
    [backView addSubview:moreButton];
    
}

- (void)calculatorMailDetailSectionViewFrame
{
    if (self.topicArray.count) {
        
        self.warnButton.width = self.width - 35 - 35;
        self.warnButton.height = 20;
        self.warnButton.x = 35;
        [self.warnButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
        
        self.warnLabel.width = self.width - 35 - 35;
        [self.warnLabel sizeToFit];
        self.warnLabel.width = self.width - 35 - 35;
        self.warnLabel.x = 35;
        
        self.backView.width = self.width - 40;
        self.backView.x = 20;
        if (self.warningName.length) {
            if (self.warnButton.hidden) {
                self.backView.y = self.warnLabel.bottom + 5;
            }else{
                self.backView.y = self.warnButton.bottom + 5;
            }
        }else{
            self.backView.y = 0;
        }
        self.backView.layer.cornerRadius = 12;
        self.backView.layer.masksToBounds = YES;
        
        [self.topicNameLabel sizeToFit];
        self.topicNameLabel.x = 15;
        self.topicNameLabel.y = 12;
        
        [self.moreButton sizeToFit];
        self.moreButton.x = self.backView.width - self.moreButton.width - 15;
        self.moreButton.centerY = self.topicNameLabel.centerY;
        [self.moreButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
        
        CGFloat width = 0;
        CGFloat j=0;
        CGFloat row = 0;
        
        CGFloat sideMargin = 15;
        CGFloat margin = MOL_SCREEN_ADAPTER(20);
        
        for (NSInteger i = 0; i < self.topicLabelArray.count; i++) {
            YYLabel *label = self.topicLabelArray[i];
            [label sizeToFit];
            label.height = 20;
            if (label.width > 200) {
                label.width = 200;
            }
            label.x = sideMargin + j * margin + width;
            label.y = self.topicNameLabel.bottom + 10 + row * 25;
            width += label.width;
            j++;
            
            if (label.right > self.backView.width - 15) {
                width = 0;
                j = 0;
                row++;
                label.x = sideMargin + j * margin + width;
                label.y = self.topicNameLabel.bottom + 10 + row * 25;
                j++;
                width += label.width;
            }
        }
        YYLabel *lastLabel = (YYLabel *)self.topicLabelArray.lastObject;
        self.backView.height = lastLabel.bottom + 15;
        
        self.width = MOL_SCREEN_WIDTH;
        self.height = self.backView.bottom + 5;
    }else{
        
        if (self.warningName.length) {
            
            self.warnButton.width = self.width - 35 - 35;
            self.warnButton.height = 20;
            self.warnButton.x = 35;
            [self.warnButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
            
            self.warnLabel.width = self.width - 35 - 35;
            [self.warnLabel sizeToFit];
            self.warnLabel.width = self.width - 35 - 35;
            self.warnLabel.x = 35;
            
            self.width = MOL_SCREEN_WIDTH;
            if (self.warnButton.hidden) {
                self.height = self.warnLabel.bottom + 5;
            }else{
                self.height = self.warnButton.bottom + 5;
            }
        }else{
            self.width = MOL_SCREEN_WIDTH;
            self.height = 0;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMailDetailSectionViewFrame];
}
@end
