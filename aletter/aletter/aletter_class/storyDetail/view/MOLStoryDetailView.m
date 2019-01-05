//
//  MOLStoryDetailView.m
//  aletter
//
//  Created by moli-2017 on 2018/8/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLStoryDetailView.h"
#import "MOLStoryDetailCommentCell.h"
#import "MOLStoryDetailRichTextHeadView.h"
#import "MOLStoryDetailHeadTopView.h"
#import "MOLStoryDetailVoiceHeadView.h"
#import "MOLHead.h"
#import "MOLStoryDetailHeadBottomView.h"
#import "MOLStoryListRequest.h"
#import "MOLInputView.h"
#import "MOLALiyunManager.h"
#import "MOLStoryDetailViewModel.h"

#import "MOLInTitleViewController.h"
#import "MOLDeleteCommentViewController.h"
#import "MOLReportCommentViewController.h"
#import "MOLMailDetailViewController.h"
#import "MOLChatViewController.h"
#import "EDChatViewController.h"

@interface MOLStoryDetailView ()<UITableViewDelegate, UITableViewDataSource, MOLInputViewDelegate>
@property (nonatomic, strong) MOLStoryDetailRichTextHeadView *richTextHeadView; // 图文头
@property (nonatomic, strong) MOLStoryDetailVoiceHeadView *voiceHeadView;     // 音频头
@property (nonatomic, strong) YYLabel *nameLabel;  // 名字
@property (nonatomic, strong) UILabel *schoolLabel;  // 学校
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, weak) MOLStoryDetailHeadTopView *headTopView;    // 天气等信息view

@property (nonatomic, strong) MOLStoryDetailHeadBottomView *headBottomView; // 组头

@property (nonatomic, weak) MOLStoryDetailBottomToolView *toolView;  // 底部工具条

@property (nonatomic, weak) UILabel *privateLabel; // 私有label

@property (nonatomic, strong) MOLStoryDetailViewModel *storyDetailViewModel;
@property (nonatomic, strong) MOLInputView *keyBoardView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MOLALiyunManager *aliyun;
// 被回复的评论id
@property (nonatomic, strong) NSString *commentId;

@property (nonatomic, assign) NSInteger currentPage;

// 私聊对象名称
@property (nonatomic, strong) MOLLightUserModel *toUser;
@end

@implementation MOLStoryDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.aliyun = [MOLALiyunManager shareALiyunManager];
        self.storyDetailViewModel = [[MOLStoryDetailViewModel alloc] init];
        [self setupStoryDetailViewUI];
        self.dataSourceArray = [NSMutableArray array];
        [self bindingViewModel];
        
    }
    return self;
}

- (void)bindingViewModel
{
    // 发布评论
    @weakify(self);
    [self.storyDetailViewModel.publishCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self.hud hideAnimated:YES];
        MOLCommentModel *comment = (MOLCommentModel *)x;
        if (comment.code == MOL_SUCCESS_REQUEST) {
            [self.keyBoardView inputView_hidden];
            [self.keyBoardView resetRecordData];
            [self.dataSourceArray addObject:comment];
            
//            NSIndexPath *indexP = [NSIndexPath indexPathForRow:self.dataSourceArray.count - 1 inSection:0];
//            [self.tableView beginUpdates];
//            [self.tableView insertRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationNone];
//            [self.tableView endUpdates];
            [self.tableView reloadData];
    
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSIndexPath *scrollBottom = [NSIndexPath indexPathForRow:self.dataSourceArray.count - 1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:scrollBottom atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            });
            
            self.storyModel.commentCount = [NSString stringWithFormat:@"%ld",self.storyModel.commentCount.integerValue + 1];
    
        }else{
            [MOLToast toast_showWithWarning:YES title:comment.message];
        }
    }];
    
    // 是否有私聊
    [self.storyDetailViewModel.messageNameCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] > 0) {
            // 跳转消息聊天界面
//            MOLChatViewController *vc = [[MOLChatViewController alloc] init];
//            vc.chatId = [NSString stringWithFormat:@"%@",x];
//            vc.userModel = self.toUser;
//            [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
            
            EDChatViewController *vc = [[EDChatViewController alloc] init];
            vc.chatId = [NSString stringWithFormat:@"%@",x];
            vc.toUser = self.toUser;
            [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
        }else{
            MOLInTitleViewController *vc = [[MOLInTitleViewController alloc] init];
            vc.type = MOLInTitleViewControllerType_message;
            @weakify(self);
            vc.messageActionBlock = ^{
                @strongify(self);
                // 跳转消息聊天界面
//                MOLChatViewController *vc = [[MOLChatViewController alloc] init];
//                vc.storyModel = self.storyModel;
//                vc.userModel = self.toUser;
//                [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
                
                EDChatViewController *vc = [[EDChatViewController alloc] init];
                vc.storyModel = self.storyModel;
                vc.toUser = self.toUser;
                [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
            };
            [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
        }
    }];
}

#pragma mark - 网络请求
- (void)request_commentList:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
    }
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(MOL_REQUEST_COMMENT);
    
    MOLStoryListRequest *r = [[MOLStoryListRequest alloc] initRequest_storyCommentListWithParameter:para parameterId:self.storyModel.storyId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        [self.tableView.mj_footer endRefreshing];
        MOLCommentGroupModel *groupModel = (MOLCommentGroupModel *)responseModel;
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        [self.dataSourceArray addObjectsFromArray:groupModel.commentList];
        
        [self.tableView reloadData];
        
        if (self.dataSourceArray.count >= groupModel.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
       [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - 赋值
- (void)setStoryModel:(MOLStoryModel *)storyModel
{
    _storyModel  = storyModel;
    
    if (self.storyModel.channelVO.isPublish == 1 || self.storyModel.channelVO.isPublish == 0) {
        [self.keyBoardView inputView_hiddenSwitch:NO];
    }else{
        [self.keyBoardView inputView_hiddenSwitch:YES];
    }
    
    [_headView removeFromSuperview];
    _headView = nil;
    [_richTextHeadView removeFromSuperview];
    _richTextHeadView = nil;
    [_voiceHeadView removeFromSuperview];
    _voiceHeadView = nil;
    
    self.tableView.tableHeaderView = self.headView;
    if (storyModel.privateSign == 2) {
        self.privateLabel.hidden = YES;
    }else{
        self.privateLabel.hidden = NO;
    }
    self.privateLabel.y = self.headView.height + 15;
    
    if (storyModel.audioUrl.length) {  // 0 音频
        self.richTextHeadView.hidden = YES;
        self.voiceHeadView.hidden = NO;
        self.voiceHeadView.storyModel = storyModel;
    }else{   // 1 图文
        self.richTextHeadView.hidden = NO;
        self.voiceHeadView.hidden = YES;
        self.richTextHeadView.storyModel = storyModel;
    }
    
    // 赋值
    NSString *sex = storyModel.user.sex == 1 ? @"他":@"她";
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if ([storyModel.user.userId isEqualToString:user.userId]) {
        sex = @"我";
    }
    NSString *name = [NSString stringWithFormat:@"%@：%@",sex,storyModel.user.userName];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:name];
    text.yy_color = HEX_COLOR(0x074D81);
    text.yy_font = MOL_MEDIUM_FONT(14);
    NSRange range = [name rangeOfString:name];
    [text yy_setTextHighlightRange:range color:HEX_COLOR(0x074D81) backgroundColor:[UIColor clearColor] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [MOLToast toast_showWithWarning:YES title:@"在隐秘世界里，你无法浏览别人的主页"];
    }];
    self.nameLabel.attributedText = text;
    
    CGSize introSize = CGSizeMake(self.width - 30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:text];
    self.nameLabel.width = layout.textBoundingSize.width;
    
    self.schoolLabel.text = storyModel.user.school;
    [self.schoolLabel sizeToFit];
    self.schoolLabel.width += 14;
    if (self.schoolLabel.width > self.width - 10 - self.nameLabel.right - 5) {
        self.schoolLabel.width = self.width - 10 - self.nameLabel.right - 5;
    }
    self.schoolLabel.height = 16;
    self.schoolLabel.right = self.width - 10;
    self.schoolLabel.centerY = self.nameLabel.centerY;
    
    self.headBottomView.storyModel = storyModel;
    
    self.headTopView.model = storyModel;
    
    self.toolView.storyModel = storyModel;
    
    // 请求评论数据
    [self request_commentList:NO];
}

#pragma mark - 按钮的点击
- (void)button_clickCommentButton  // 点击评论
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
    
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if (!user.commentName.length) {
        // 起名字
        MOLInTitleViewController *vc = [[MOLInTitleViewController alloc] init];
        vc.type = MOLInTitleViewControllerType_comment;
        [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
        return;
    }
    self.commentId = nil;
//    [self.keyBoardView inputView_showSuperView:MOLAppDelegateWindow placeHolder:@"回复楼主"];
    UIView *v = [[MOLGlobalManager shareGlobalManager] global_currentViewControl].view;
    [self.keyBoardView inputView_showSuperView:v placeHolder:@"回复楼主"];
}

- (void)button_clickMsgButton // 点击私信
{
    [self beginChatWithUser:self.storyModel.user.userId toUserName:self.storyModel.user.userName sex:self.storyModel.user.sex];
}

- (void)beginChatWithUser:(NSString *)userId toUserName:(NSString *)toUserName sex:(NSInteger)sex
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
    
    MOLLightUserModel *user = [[MOLLightUserModel alloc] init];
    user.userId = userId;
    user.userName = toUserName;
    user.sex = sex;
    self.toUser = user;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"storyId"] = self.storyModel.storyId;
    dic[@"userId"] = userId;
    [self.storyDetailViewModel.messageNameCommand execute:dic];
}

#pragma mark - 长按手势
- (void)longPressGesture:(UIGestureRecognizer *)longGesture
{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        
        // 获取用户信息 判断是否跳转起名字的界面
        if (![MOLUserManagerInstance user_isLogin]) {
            [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
            return;
        }
        
        if ([MOLUserManagerInstance user_needCompleteInfo]) {
            [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
            return;
        }
        
        CGPoint location = [longGesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        if (!indexPath) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MOLCommentModel *model = self.dataSourceArray[indexPath.row];
            MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
            if ([user.userId isEqualToString:model.commentUserId]) {
                MOLDeleteCommentViewController *vc = [[MOLDeleteCommentViewController alloc] init];
                vc.commentModel = model;
                @weakify(self);
                vc.deleteCommentBlock = ^{
                    @strongify(self);
                    [self.dataSourceArray removeObject:model];
                    [self.tableView reloadData];
                };
                [[[MOLGlobalManager shareGlobalManager] global_currentViewControl] presentViewController:vc animated:YES completion:nil];
            }else{
                
                if ([MOLUserManagerInstance user_isPower]) {
                    MOLDeleteCommentViewController *vc = [[MOLDeleteCommentViewController alloc] init];
                    vc.commentModel = model;
                    @weakify(self);
                    vc.deleteCommentBlock = ^{
                        @strongify(self);
                        [self.dataSourceArray removeObject:model];
                        [self.tableView reloadData];
                    };
                    [[[MOLGlobalManager shareGlobalManager] global_currentViewControl] presentViewController:vc animated:YES completion:nil];
                }else{
                    
                    MOLReportCommentViewController *vc = [[MOLReportCommentViewController alloc] init];
                    vc.commentModel = model;
                    [[[MOLGlobalManager shareGlobalManager] global_currentViewControl] presentViewController:vc animated:YES completion:nil];
                }
            }
        });
        
    }
}

#pragma mark - MOLInputViewDelegate
/// 点击发送
- (void)inputView_sendStoryInfoWithText:(NSString *)text voiceString:(NSString *)voice parameter:(NSDictionary *)para
{
    self.hud = [MBProgressHUD showMessage:@"正在发布" toView:self];
    
    if (voice.length) {
        // 上传阿里云
        @weakify(self);
        [self.aliyun aLiyun_uploadVoiceFile:voice fileType:@"mp3" complete:^(NSString *filePath) {
            @strongify(self);
            
            if (filePath.length) {
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"audioUrl"] = filePath;
                if (self.commentId.length) {
                    dic[@"commentId"] = self.commentId;
                }
                dic[@"content"] = text;
                dic[@"storyId"] = self.storyModel.storyId;
                dic[@"time"] = @([para mol_jsonInteger:@"time"]);
                dic[@"audioText"] = [para mol_jsonString:@"text"];
                [self.storyDetailViewModel.publishCommand execute:dic];
                
            }else{
                [MOLToast toast_showWithWarning:YES title:@"文件上传失败,请重试"];
            }
            
        }];
    }else{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if (self.commentId.length) {
            dic[@"commentId"] = self.commentId;
        }
        dic[@"content"] = text;
        dic[@"storyId"] = self.storyModel.storyId;
        [self.storyDetailViewModel.publishCommand execute:dic];
    }
}


/// 开始录音
- (void)inputView_beginRecord{}
/// 结束录音
- (void)inputView_endRecord{}
/// 重新录音
- (void)inputView_againRecord{}
/// 开始试听
- (void)inputView_beginListen{}
/// 结束试听
- (void)inputView_endListen{}
- (void)inputView_keyboardShowWithHeight:(CGFloat)height{}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 获取用户信息 判断是否跳转起名字的界面
    if (![MOLUserManagerInstance user_isLogin]) {
        [[MOLGlobalManager shareGlobalManager] global_modalChooseViewController];
        return;
    }
    
    if ([MOLUserManagerInstance user_needCompleteInfo]) {
        [[MOLGlobalManager shareGlobalManager] global_modalInfoCheckViewControllerWithAnimated:YES];
        return;
    }
    
    MOLCommentModel *model = self.dataSourceArray[indexPath.row];
    self.commentId = model.commentId;
    NSString *name = [NSString stringWithFormat:@"回复%@",model.commentUserName];
    if ([model.commentUserId isEqualToString:self.storyModel.user.userId]) {
        name = @"回复楼主";
    }
//    [self.keyBoardView inputView_showSuperView:MOLAppDelegateWindow placeHolder:name];
    UIView *v = [[MOLGlobalManager shareGlobalManager] global_currentViewControl].view;
    [self.keyBoardView inputView_showSuperView:v placeHolder:name];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (self.dataSourceArray.count && [MOLSwitchManager shareSwitchManager].normalStatus) {
//        return 1;
//    }else{
//        return 0;
//    }
    
    if (![MOLSwitchManager shareSwitchManager].normalStatus) {
        return 0;
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLCommentModel *model = self.dataSourceArray[indexPath.row];
    return model.commentCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLCommentModel *model = self.dataSourceArray[indexPath.row];
    MOLStoryDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLStoryDetailCommentCell_id"];
    cell.storyUserId = self.storyModel.user.userId;
    cell.commentModel = model;
    @weakify(self);
    cell.clickMsgButtonBlock = ^{
        @strongify(self);
        if ([model.commentUserId isEqualToString:self.storyModel.user.userId]) {
            [self beginChatWithUser:self.storyModel.user.userId toUserName:self.storyModel.user.userName sex:self.storyModel.user.sex];
        }else{
            [self beginChatWithUser:model.commentUserId toUserName:model.commentUserName sex:model.commentUserSex];
        }
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.headBottomView.storyModel = self.storyModel;
    return self.headBottomView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.transform = CATransform3DIdentity;
}

#pragma mark - 懒加载
- (MOLStoryDetailRichTextHeadView *)richTextHeadView
{
    if (_richTextHeadView == nil) {
        _richTextHeadView = [[MOLStoryDetailRichTextHeadView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        @weakify(self);
        _richTextHeadView.resetTableHeadViewBlock = ^(CGFloat height) {
            @strongify(self);
            self.headView.height = height + self.nameLabel.height + 10;
            self.tableView.tableHeaderView = self.headView;
            self.privateLabel.y = self.headView.height + 15;
        };
        
        _richTextHeadView.clickHighText = ^(MOLStoryModel *model) {
            @strongify(self);
//            [self.textSubject sendNext:model];
            MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
            vc.topicId = model.topicVO.topicId;
            [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
        };
    }
    
    return _richTextHeadView;
}

- (MOLStoryDetailVoiceHeadView *)voiceHeadView
{
    if (_voiceHeadView == nil) {
        
        _voiceHeadView = [[MOLStoryDetailVoiceHeadView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _voiceHeadView.needPlay = self.needPlay;
        @weakify(self);
        _voiceHeadView.resetTableHeadViewBlock = ^(CGFloat height) {
            @strongify(self);
            self.headView.height = height + self.nameLabel.height + 10;
            self.tableView.tableHeaderView = self.headView;
            self.privateLabel.y = self.headView.height + 15;
        };
        
        _voiceHeadView.clickHighText = ^(MOLStoryModel *model) {
            @strongify(self);
//            [self.textSubject sendNext:model];
            MOLMailDetailViewController *vc = [[MOLMailDetailViewController alloc] init];
            vc.topicId = model.topicVO.topicId;
            [[[MOLGlobalManager shareGlobalManager] global_currentNavigationViewControl] pushViewController:vc animated:YES];
        };
    }
    
    return _voiceHeadView;
}

- (YYLabel *)nameLabel
{
    if (_nameLabel == nil) {
        
        _nameLabel = [[YYLabel alloc] init];
        _nameLabel.width = self.width - 30;
        _nameLabel.height = 25;
        _nameLabel.x = 15;
        
        _schoolLabel = [[UILabel alloc] init];
        _schoolLabel.text = @" ";
        _schoolLabel.textColor = HEX_COLOR(0x809FC2);
        _schoolLabel.font = MOL_MEDIUM_FONT(11);
//        _schoolLabel.backgroundColor = HEX_COLOR_ALPHA(0xF4F4F4, 1);
        _schoolLabel.textAlignment = NSTextAlignmentRight;
        _schoolLabel.layer.cornerRadius = 16 * 0.5;
        _schoolLabel.clipsToBounds = YES;
    }
    
    return _nameLabel;
}

- (UIView *)headView
{
    if (_headView == nil) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        [_headView addSubview:self.nameLabel];
        [_headView addSubview:self.schoolLabel];
        if (self.storyModel.audioUrl.length) {  // 音频
            [_headView addSubview:self.voiceHeadView];
            self.voiceHeadView.y = self.nameLabel.bottom + 10;
        }else{
            [_headView addSubview:self.richTextHeadView];
            self.richTextHeadView.y = self.nameLabel.bottom + 10;
        }
    }
    return _headView;
}

- (MOLStoryDetailHeadBottomView *)headBottomView
{
    if (_headBottomView == nil) {
        
        _headBottomView = [[MOLStoryDetailHeadBottomView alloc] init];
    }
    
    return _headBottomView;
}

- (MOLInputView *)keyBoardView
{
    if (_keyBoardView == nil) {
        UIView *v = [[MOLGlobalManager shareGlobalManager] global_currentViewControl].view;
        _keyBoardView = [[MOLInputView alloc] initWithFrame:v.bounds];
        _keyBoardView.delegate = self;
    }
    
    return _keyBoardView;
}

#pragma mark - UI
- (void)setupStoryDetailViewUI
{
    MOLStoryDetailHeadTopView *headTopView = [[MOLStoryDetailHeadTopView alloc] init];
    _headTopView = headTopView;
    [self addSubview:headTopView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MOLStoryDetailCommentCell class] forCellReuseIdentifier:@"MOLStoryDetailCommentCell_id"];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self addSubview:tableView];
    
    MOLStoryDetailBottomToolView *toolView = [[MOLStoryDetailBottomToolView alloc] init];
    _toolView = toolView;
    [toolView.msgButton addTarget:self action:@selector(button_clickMsgButton) forControlEvents:UIControlEventTouchUpInside];
    [toolView.commentButton addTarget:self action:@selector(button_clickCommentButton) forControlEvents:UIControlEventTouchDown];
    toolView.hidden = ![MOLSwitchManager shareSwitchManager].normalStatus;
    [self addSubview:toolView];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longGesture.minimumPressDuration = 1;
    [self.tableView addGestureRecognizer:longGesture];
    
    @weakify(self);
    self.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_commentList:YES];
    }];
    self.tableView.mj_footer.hidden = YES;

    UILabel *privateLabel = [[UILabel alloc] init];
    _privateLabel = privateLabel;
    privateLabel.text = @"私密";
    privateLabel.hidden = YES;
    privateLabel.textColor = HEX_COLOR(0xEE7159);
    privateLabel.font = MOL_MEDIUM_FONT(12);
    [self.tableView addSubview:privateLabel];
}

- (void)calculatorStoryDetailViewFrame
{
    self.headTopView.width = self.width;
    self.headTopView.height = 90;
    
    self.tableView.frame = self.bounds;
    self.tableView.height = self.height - MOL_TabbarSafeBottomMargin - self.headTopView.height - (self.toolView.hidden ? 0 : 44);
    self.tableView.y = self.headTopView.bottom;
    
    self.toolView.width = self.width;
    self.toolView.height = 44 + MOL_TabbarSafeBottomMargin;
    self.toolView.y = self.tableView.bottom;
    
    [self.privateLabel sizeToFit];
    self.privateLabel.right = self.width - 15;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryDetailViewFrame];
}

@end
