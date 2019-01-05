//
//  MOLMailDetailRichTextCell.m
//  aletter
//
//  Created by moli-2017 on 2018/8/3.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailDetailRichTextCell.h"
#import "MOLHead.h"
#import "MOLActionViewModel.h"


@interface MOLMailDetailRichTextCell ()
@property (nonatomic, weak) UIView *backContentView;  // 内容view
@property (nonatomic, weak) UILabel *nameLabel;        // 姓名
@property (nonatomic, weak) UIImageView *sexImageView; // 性别
@property (nonatomic, weak) UILabel *schoolLabel; // 学校
@property (nonatomic, weak) UIImageView *envelopeImageView;  // 信封
@property (nonatomic, weak) YYLabel *contentLabel;   // 正文
@property (nonatomic, weak) UIButton *allTextButton; // 查看全文
@property (nonatomic, weak) FLAnimatedImageView *imageView_one; // 图片1
@property (nonatomic, weak) FLAnimatedImageView *imageView_two; // 图片2
@property (nonatomic, weak) FLAnimatedImageView *imageView_three; // 图片3
@property (nonatomic, weak) UILabel *actionLabel;   // 3分钟前 · 2 同感 · 4评论
@property (nonatomic, weak) UIButton *likeButton;  // 喜欢

@property (nonatomic, strong) MOLActionViewModel *actionViewModel;
@end

@implementation MOLMailDetailRichTextCell
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.actionViewModel = [[MOLActionViewModel alloc] init];
        [self stupMailDetailRichTextCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self bindingViewModel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatus_changeStatus:) name:@"MOL_LIKE_STATUS" object:nil];
    }
    return self;
}

- (void)likeStatus_changeStatus:(NSNotification*)note
{
    MOLStoryModel *model = [note object];
    if ([model.storyId isEqualToString:self.storyModel.storyId]) {
        self.storyModel.isAgree = model.isAgree;
        self.likeButton.selected = self.storyModel.isAgree;
        if (self.likeButton.selected) {
            self.storyModel.likeCount = [NSString stringWithFormat:@"%ld",self.storyModel.likeCount.integerValue + 1];
        }else{
            NSInteger count = self.storyModel.likeCount.integerValue - 1 > 0 ? self.storyModel.likeCount.integerValue - 1 : 0;
            self.storyModel.likeCount = [NSString stringWithFormat:@"%ld",count];
        }
        
        [self setActionLabelWithModel:self.storyModel];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)setActionLabelWithModel:(MOLStoryModel *)model
{
    NSString *bottomSting = nil;
    NSString *showTime = [NSString moli_timeGetMessageTimeWithTimestamp:model.createTime];
    if ([MOLSwitchManager shareSwitchManager].normalStatus) {
        if (model.likeCount.integerValue == 0 && model.commentCount.integerValue == 0) {
            bottomSting = showTime;
        }else if (model.likeCount.integerValue == 0){
            bottomSting = [NSString stringWithFormat:@"%@ · %@评论",showTime,model.commentCount];
        }else if (model.commentCount.integerValue == 0){
            bottomSting = [NSString stringWithFormat:@"%@ · %@%@",showTime,model.likeCount,(model.channelVO.agreeContent.length ? model.channelVO.agreeContent:@"喜欢")];
        }else{
            bottomSting = [NSString stringWithFormat:@"%@ · %@%@ · %@评论",showTime,model.likeCount,(model.channelVO.agreeContent.length ? model.channelVO.agreeContent:@"喜欢"),model.commentCount];
        }
    }else{
        bottomSting = showTime;
    }
    
    self.actionLabel.text = bottomSting;
}

#pragma mark - viewModel
- (void)bindingViewModel
{
    // 点赞
    @weakify(self);
    [self.actionViewModel.likeStoryCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        self.likeButton.userInteractionEnabled = YES;
        NSInteger code = [x integerValue];
        if (code == MOL_SUCCESS_REQUEST) {
            self.likeButton.selected = self.storyModel.isAgree;
        }
    }];
}

#pragma mark - 按钮点击
- (void)button_clickLikeButton:(UIButton *)button
{
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        // 跳出性别选择
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    
    button.userInteractionEnabled = NO;
    [self.actionViewModel.likeStoryCommand execute:self.storyModel];
}

- (void)button_clickImage:(UIGestureRecognizer *)tap
{
    UIView *v = tap.view;
    int index = 0;
    if (v == self.imageView_one) {
        index = 0;
    }else if (v == self.imageView_two){
        index = 1;
    }else if (v == self.imageView_three){
        index = 2;
    }
    
    HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
    browser.isNeedLandscape = NO;
    browser.currentImageIndex = index;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < self.storyModel.photos.count; i++) {
        MOLLightPhotoModel *photo = self.storyModel.photos[i];
        [arr addObject:photo.src];
    }
    browser.imageArray = arr;
    [browser show];
}

#pragma mark - 赋值
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    
    self.nameLabel.text = storyModel.user.userName;
    self.schoolLabel.text = storyModel.user.school;
    self.sexImageView.image = storyModel.user.sex == 1 ? [UIImage imageNamed:@"detail_man"] : [UIImage imageNamed:@"detail_woman"];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:storyModel.content];
    text.yy_color = HEX_COLOR(0x074D81);
    text.yy_font = MOL_LIGHT_FONT(14);
    if (storyModel.topicVO.topicName.length) {
        NSRange range = [storyModel.content rangeOfString:storyModel.topicVO.topicName];
        [text yy_setColor:HEX_COLOR(0x4A90E2) range:range];
        [text yy_setFont:MOL_MEDIUM_FONT(14) range:range];
        @weakify(self);
        [text yy_setTextHighlightRange:range color:HEX_COLOR(0x4A90E2) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            @strongify(self);
            if (self.clickHighText) {
                self.clickHighText(storyModel);
            }
        }];
    }
    self.contentLabel.attributedText = text;
    
    self.allTextButton.hidden = !storyModel.showAllButton;
    
    if (storyModel.sort > 0) {
        self.envelopeImageView.image = [UIImage imageNamed:@"detail_hot"];
    }else{
        self.envelopeImageView.image = [UIImage imageNamed:@"detail_envelope"];
    }
    
    if (storyModel.photos.count == 3) {
        self.imageView_one.hidden = NO;
        self.imageView_two.hidden = NO;
        self.imageView_three.hidden = NO;
        MOLLightPhotoModel *image1 = storyModel.photos.firstObject;
        MOLLightPhotoModel *image2 = storyModel.photos[1];
        MOLLightPhotoModel *image3 = storyModel.photos.lastObject;
        
        [self.imageView_one sd_setImageWithURL:[NSURL URLWithString:image1.src]];
        [self.imageView_two sd_setImageWithURL:[NSURL URLWithString:image2.src]];
        [self.imageView_three sd_setImageWithURL:[NSURL URLWithString:image3.src]];
    }else if (storyModel.photos.count == 2){
        
        self.imageView_one.hidden = NO;
        self.imageView_two.hidden = NO;
        self.imageView_three.hidden = YES;
        MOLLightPhotoModel *image1 = storyModel.photos.firstObject;
        MOLLightPhotoModel *image2 = storyModel.photos.lastObject;
        [self.imageView_one sd_setImageWithURL:[NSURL URLWithString:image1.src]];
        [self.imageView_two sd_setImageWithURL:[NSURL URLWithString:image2.src]];
        
    }else if (storyModel.photos.count == 1){
        self.imageView_one.hidden = NO;
        self.imageView_two.hidden = YES;
        self.imageView_three.hidden = YES;
        MOLLightPhotoModel *image1 = storyModel.photos.firstObject;
        [self.imageView_one sd_setImageWithURL:[NSURL URLWithString:image1.src]];
        
    }else{
        self.imageView_one.hidden = YES;
        self.imageView_two.hidden = YES;
        self.imageView_three.hidden = YES;
    }
    
    [self setActionLabelWithModel:storyModel];
    
    self.likeButton.selected = storyModel.isAgree;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UI
- (void)stupMailDetailRichTextCellUI
{
    UIView *backContentView = [[UIView alloc] init];
    _backContentView = backContentView;
    backContentView.backgroundColor = HEX_COLOR(0xffffff);
    [self.contentView addSubview:backContentView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"加载中...";
    nameLabel.textColor = HEX_COLOR(0x004476);
    nameLabel.font = MOL_MEDIUM_FONT(14);
    [backContentView addSubview:nameLabel];
    
    UIImageView *sexImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_man"]];
    _sexImageView = sexImageView;
    [backContentView addSubview:sexImageView];
    
    UILabel *schoolLabel = [[UILabel alloc] init];
    _schoolLabel = schoolLabel;
    schoolLabel.text = @" ";
    schoolLabel.textColor = HEX_COLOR(0x809FC2);
    schoolLabel.font = MOL_MEDIUM_FONT(11);
//    schoolLabel.backgroundColor = HEX_COLOR_ALPHA(0xF4F4F4, 1);
    schoolLabel.textAlignment = NSTextAlignmentCenter;
    [backContentView addSubview:schoolLabel];
    
    UIImageView *envelopeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_envelope"]];
    _envelopeImageView = envelopeImageView;
    [backContentView addSubview:envelopeImageView];
    
    YYLabel *contentLabel = [[YYLabel alloc] init];
    _contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    [backContentView addSubview:contentLabel];
    
    UIButton *allTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _allTextButton = allTextButton;
    [allTextButton setTitle:@"查看全文" forState:UIControlStateNormal];
    [allTextButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateNormal];
    [allTextButton setImage:[UIImage imageNamed:@"detail_allText"] forState:UIControlStateNormal];
    allTextButton.titleLabel.font = MOL_MEDIUM_FONT(14);
    [backContentView addSubview:allTextButton];
    
    FLAnimatedImageView *imageView_one = [[FLAnimatedImageView alloc] init];
    _imageView_one = imageView_one;
    imageView_one.backgroundColor = [UIColor lightGrayColor];
    imageView_one.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickImage:)];
    [imageView_one addGestureRecognizer:tap1];
    imageView_one.contentMode = UIViewContentModeScaleAspectFill;
    imageView_one.clipsToBounds = YES;
    [backContentView addSubview:imageView_one];
    
    FLAnimatedImageView *imageView_two = [[FLAnimatedImageView alloc] init];
    _imageView_two = imageView_two;
    imageView_two.backgroundColor = [UIColor lightGrayColor];
    imageView_two.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickImage:)];
    [imageView_two addGestureRecognizer:tap2];
    imageView_two.contentMode = UIViewContentModeScaleAspectFill;
    imageView_two.clipsToBounds = YES;
    [backContentView addSubview:imageView_two];
    
    FLAnimatedImageView *imageView_three = [[FLAnimatedImageView alloc] init];
    _imageView_three = imageView_three;
    imageView_three.backgroundColor = [UIColor lightGrayColor];
    imageView_three.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(button_clickImage:)];
    [imageView_three addGestureRecognizer:tap3];
    imageView_three.contentMode = UIViewContentModeScaleAspectFill;
    imageView_three.clipsToBounds = YES;
    [backContentView addSubview:imageView_three];
    
    UILabel *actionLabel = [[UILabel alloc] init];
    _actionLabel = actionLabel;
    actionLabel.text = @"刚刚 · 0 同感 · 0评论";
    actionLabel.textColor = HEX_COLOR(0x074D81);
    actionLabel.font = MOL_LIGHT_FONT(12);
    [backContentView addSubview:actionLabel];
    
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    [likeButton setImage:[UIImage imageNamed:@"detail_agree"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"detail_agreed"] forState:UIControlStateSelected];
    [likeButton addTarget:self action:@selector(button_clickLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    [backContentView addSubview:likeButton];
}

- (void)calculatorMailDetailRichTextCellFrame
{
    self.backContentView.width = self.contentView.width - 40;
    self.backContentView.height = self.contentView.height - 5;
    self.backContentView.x = 20;
    self.backContentView.layer.cornerRadius = 12;
    self.backContentView.layer.masksToBounds = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 20;
    if (self.nameLabel.width > self.backContentView.width * 0.5) {
        self.nameLabel.width = self.backContentView.width * 0.5;
    }
    self.nameLabel.x = 15;
    self.nameLabel.y = 20;
    
    self.sexImageView.width = 12;
    self.sexImageView.height = self.sexImageView.width;
    self.sexImageView.x = self.nameLabel.right + 5;
    self.sexImageView.centerY = self.nameLabel.centerY;
    
    [self.schoolLabel sizeToFit];
    self.schoolLabel.width += 14;
    if (self.schoolLabel.width > (self.backContentView.width - 17) - (self.sexImageView.right + 10)) {
        self.schoolLabel.width = (self.backContentView.width - 17) - (self.sexImageView.right + 10);
    }
    self.schoolLabel.height = 16;
    self.schoolLabel.centerY = self.nameLabel.centerY;
    self.schoolLabel.right = self.backContentView.width - 17;
    self.schoolLabel.layer.cornerRadius = self.schoolLabel.height * 0.5;
    self.schoolLabel.clipsToBounds = YES;
    
    self.envelopeImageView.width = 50;
    self.envelopeImageView.height = 30;
    self.envelopeImageView.right = self.backContentView.width;
    

    self.contentLabel.width = self.backContentView.width - 30;
    self.contentLabel.height = [self getMessageHeight];
    self.contentLabel.x = 15;
    self.contentLabel.y = self.nameLabel.bottom + 10;
    
    [self.allTextButton sizeToFit];
    self.allTextButton.x = self.contentLabel.x;
    self.allTextButton.y = self.contentLabel.bottom + 5;
    [self.allTextButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
    
    self.imageView_one.width = 65;
    self.imageView_one.height = self.imageView_one.width;
    self.imageView_one.x = self.contentLabel.x;
    self.imageView_one.y = self.allTextButton.hidden ? self.contentLabel.bottom + 10 : self.allTextButton.bottom + 15;
    
    self.imageView_two.width = self.imageView_one.width;
    self.imageView_two.height = self.imageView_one.width;
    self.imageView_two.y = self.imageView_one.y;
    self.imageView_two.x = self.imageView_one.right + 4;
    
    self.imageView_three.width = self.imageView_one.width;
    self.imageView_three.height = self.imageView_one.width;
    self.imageView_three.y = self.imageView_one.y;
    self.imageView_three.x = self.imageView_two.right + 4;
    
    [self.actionLabel sizeToFit];
    self.actionLabel.x = self.contentLabel.x;
    
    if (self.imageView_one.hidden == NO) {
        self.actionLabel.y = self.imageView_one.bottom + 10;
    }else if (self.allTextButton.hidden == NO){
        self.actionLabel.y = self.allTextButton.bottom + 15;
    }else{
        self.actionLabel.y = self.contentLabel.bottom + 10;
    }
    
    self.likeButton.width = 24;
    self.likeButton.height = 24;
    self.likeButton.right = self.backContentView.width - 20;
    self.likeButton.centerY = self.actionLabel.centerY;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMailDetailRichTextCellFrame];
}

// 获取文本高度
-(CGFloat)getMessageHeight
{
    NSMutableAttributedString *introText = [[NSMutableAttributedString alloc] initWithString:self.storyModel.content];
    introText.yy_font = MOL_LIGHT_FONT(14);
    CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-40-30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:introText];
    CGFloat introHeight = layout.textBoundingSize.height;
    if (introHeight > MOL_TextMaxHeight) {
        introHeight = MOL_TextMaxHeight;
    }
    return introHeight;
}

@end
