//
//  MOLStoryDetailBottomToolView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailBottomToolView.h"
#import "MOLHead.h"
#import "MOLActionViewModel.h"

@interface MOLStoryDetailBottomToolView ()
@property (nonatomic, strong) MOLActionViewModel *actionViewModel;
@end

@implementation MOLStoryDetailBottomToolView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.actionViewModel = [[MOLActionViewModel alloc] init];
        [self setupStoryDetailBottomToolViewUI];
        self.backgroundColor = HEX_COLOR(0xE9F6FF);
        [self bindingViewModel];
    }
    return self;
}

- (void)bindingViewModel
{
    // 点赞
    @weakify(self);
    [self.actionViewModel.likeStoryCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        self.likeButton.userInteractionEnabled = YES;
        NSInteger code = [x integerValue];
        if (code == MOL_SUCCESS_REQUEST) {
//            self.storyModel.isAgree = !self.storyModel.isAgree;
            self.likeButton.selected = self.storyModel.isAgree;
        }
    }];
}

#pragma mark - 按钮点击
- (void)button_clickLikeButton
{
    // 获取用户信息 判断是否跳转起名字的界面
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    
    self.likeButton.userInteractionEnabled = NO;
    [self.actionViewModel.likeStoryCommand execute:self.storyModel];
}

#pragma mark - 赋值
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel = storyModel;
    
    NSString *likeTitle = storyModel.channelVO.agreeContent.length ? storyModel.channelVO.agreeContent : @"喜欢";
    [self.likeButton setTitle:likeTitle forState:UIControlStateNormal];
    self.likeButton.selected = storyModel.isAgree;
    
    // 获取自己的信息
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if (!storyModel.chatOpen) {
        self.toolType = MOLStoryDetailBottomToolViewType_invalid;
    }else if ([storyModel.user.userId isEqualToString:user.userId]){
        self.toolType = MOLStoryDetailBottomToolViewType_own;
    }else{
        self.toolType = MOLStoryDetailBottomToolViewType_other;

    }
}

- (void)setToolType:(MOLStoryDetailBottomToolViewType)toolType
{
    _toolType = toolType;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - UI
- (void)setupStoryDetailBottomToolViewUI
{
    UIButton *msgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _msgButton = msgButton;
    [msgButton setTitle:@"私聊" forState:UIControlStateNormal];
    [msgButton setTitleColor:HEX_COLOR(0x537A99) forState:UIControlStateNormal];
    msgButton.titleLabel.font = MOL_MEDIUM_FONT(12);
    [msgButton setImage:[UIImage imageNamed:@"storyDetail_msg"] forState:UIControlStateNormal];
    [self addSubview:msgButton];
    
    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton = commentButton;
    [commentButton setTitle:@"评论" forState:UIControlStateNormal];
    [commentButton setTitleColor:HEX_COLOR(0x537A99) forState:UIControlStateNormal];
    commentButton.titleLabel.font = MOL_MEDIUM_FONT(12);
    [commentButton setImage:[UIImage imageNamed:@"storyDetail_comment"] forState:UIControlStateNormal];
    commentButton.hidden = YES;
    [self addSubview:commentButton];
    
    UIButton *likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    [likeButton setTitle:@"喜欢" forState:UIControlStateNormal];
    [likeButton setTitleColor:HEX_COLOR(0x537A99) forState:UIControlStateNormal];
    likeButton.titleLabel.font = MOL_MEDIUM_FONT(12);
    [likeButton setImage:[UIImage imageNamed:@"storyDetail_like"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"storyDetail_liked"] forState:UIControlStateSelected];
    [likeButton addTarget:self action:@selector(button_clickLikeButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:likeButton];
    
    UIButton *invalidButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _invalidButton = invalidButton;
    [invalidButton setTitle:@"互动关闭" forState:UIControlStateNormal];
    [invalidButton setTitleColor:HEX_COLOR(0x537A99) forState:UIControlStateNormal];
    invalidButton.titleLabel.font = MOL_MEDIUM_FONT(12);
    [invalidButton setImage:[UIImage imageNamed:@"storyDetail_invalidButton"] forState:UIControlStateNormal];
    invalidButton.hidden = YES;
    [self addSubview:invalidButton];
}

- (void)calculatorStoryDetailBottomToolViewFrame
{
    if (self.toolType == MOLStoryDetailBottomToolViewType_own) {
        self.msgButton.hidden = YES;
        self.commentButton.hidden = NO;
        self.likeButton.hidden = NO;
        self.invalidButton.hidden = YES;
        
        self.commentButton.width = self.width / 2;
        self.commentButton.height = 44;
        self.commentButton.x = 0;
        [self.commentButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
        
        self.likeButton.width = self.commentButton.width;
        self.likeButton.height = self.commentButton.height;
        self.likeButton.x = self.commentButton.right;
        [self.likeButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
        
    }else if (self.toolType == MOLStoryDetailBottomToolViewType_other){
        self.msgButton.hidden = NO;
        self.commentButton.hidden = NO;
        self.likeButton.hidden = NO;
        self.invalidButton.hidden = YES;
        
        self.msgButton.width = self.width / 3;
        self.msgButton.height = 44;
        self.msgButton.x = 0;
        [self.msgButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
        
        self.commentButton.width = self.msgButton.width;
        self.commentButton.height = self.msgButton.height;
        self.commentButton.x = self.msgButton.right;
        [self.commentButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
        
        self.likeButton.width = self.msgButton.width;
        self.likeButton.height = self.msgButton.height;
        self.likeButton.x = self.commentButton.right;
        [self.likeButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
        
    }else if (self.toolType == MOLStoryDetailBottomToolViewType_invalid){
        self.msgButton.hidden = YES;
        self.commentButton.hidden = YES;
        self.likeButton.hidden = NO;
        self.invalidButton.hidden = NO;
        
        self.invalidButton.width = self.width / 2;
        self.invalidButton.height = 44;
        self.invalidButton.x = 0;
        [self.invalidButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
        
        self.likeButton.width = self.invalidButton.width;
        self.likeButton.height = self.invalidButton.height;
        self.likeButton.x = self.invalidButton.right;
        [self.likeButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
    }else{
        self.msgButton.hidden = YES;
        self.commentButton.hidden = YES;
        self.likeButton.hidden = NO;
        self.invalidButton.hidden = YES;
        
        self.likeButton.width = self.width;
        self.likeButton.height = 44;
        self.likeButton.x = 0;
        [self.likeButton mol_setButtonImageTitleStyle:ButtonImageTitleStyleLeft padding:6];
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailBottomToolViewFrame];
}

@end
