//
//  MOLMineMessageViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/17.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineMessageViewController.h"
#import "MOLSystemNotiViewController.h"
#import "MOLInteractNotiViewController.h"
#import "MOLDeleteChatViewController.h"
#import "MOLChatViewController.h"
#import "MOLHead.h"
#import "MOLMessageListCell.h"
#import "MOLMineMessageViewModel.h"

#import "MOLChatGroupModel.h"
#import "MOLSystemGroupModel.h"

#import "EDChatViewController.h"

@interface MOLMineMessageViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) MOLMineMessageViewModel *messageViewModel;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) BOOL endDrag;

@property (nonatomic, assign) BOOL refreshing;  // 正在刷新

// 通知、互动消息模型
@property (nonatomic, strong) MOLChatGroupModel *topMsgModel;

@end

@implementation MOLMineMessageViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.messageViewModel = [[MOLMineMessageViewModel alloc] init];
    [self setupMineMessageViewControllerUI];
    [self bindingMineMessageViewModel];
    
    @weakify(self);
    self.messageView.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getChatList:YES];
    }];
    self.messageView.tableView.mj_footer.hidden = YES;
    
    // 头部刷新的时候刷新该方法即可
    [self request_mineMsg];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageArrive:) name:@"ALETTER_PUSH_MESSAGE" object:nil];
}

- (void)newMessageArrive:(NSNotification *)noti
{
    if (self.refreshing) {
        return;
    }
    self.refreshing = YES;
    [self.messageViewModel.notiListCommand execute:nil];
}

- (void)request_mineMsg;
{
    // 头部刷新的时候刷新该方法即可
    if (self.refreshing) {
        return;
    }
    self.refreshing = YES;
    [self.messageViewModel.notiListCommand execute:nil];
    [self basevc_showLoading];
}

#pragma mark - 网络请求
- (void)request_getChatList:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
    }
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"pageNum"] = @(self.currentPage);
    para[@"pageSize"] = @(MOL_REQUEST_OTHER);
    
    [self.messageViewModel.messageListCommand execute:para];
}

#pragma mark - viewModel
- (void)bindingMineMessageViewModel
{
    // 消息list
    @weakify(self);
    [self.messageViewModel.messageListCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        
        self.refreshing = NO;
        
        [self.messageView.tableView.mj_footer endRefreshing];
        MOLChatGroupModel *groupModel = (MOLChatGroupModel *)x;
        
        /* 1.0.3 */
        if (self.topMsgModel) {  // 添加互动、通知消息
            [self.messageView.dataSourceArray removeAllObjects];
            if (self.topMsgModel.resBody.count) {
                NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange: NSMakeRange(0, self.topMsgModel.resBody.count)];
                [self.messageView.dataSourceArray insertObjects:self.topMsgModel.resBody atIndexes:set];
            }
            self.topMsgModel = nil;
        }
        /* 1.0.3 */
        
        
  
        [self.messageView.dataSourceArray addObjectsFromArray:groupModel.resBody];
        
        [self.messageView.tableView reloadData];
        
        if (!groupModel.resBody.count || groupModel.total < MOL_REQUEST_OTHER) {
            self.messageView.tableView.mj_footer.hidden = YES;
        }else{
            self.messageView.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        if (!self.messageView.dataSourceArray.count) {
            [self basevc_showBlankPageWithY:-(100 + MOL_StatusBarHeight) image:@"mine_noData" title:nil superView:self.messageView.tableView];
        }
        
    }];
    
    // 通知最新、互动
    [self.messageViewModel.notiListCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        [self basevc_hiddenLoading];
//        [self.messageView.dataSourceArray removeAllObjects];
//        [self.messageView.tableView reloadData];
//        if (x) {
//            MOLChatGroupModel *groupModel = (MOLChatGroupModel *)x;
//            if (groupModel.resBody.count) {
//                NSIndexSet *set = [[NSIndexSet alloc] initWithIndexesInRange: NSMakeRange(0, groupModel.resBody.count)];
//                [self.messageView.dataSourceArray insertObjects:groupModel.resBody atIndexes:set];
//                [self.messageView.tableView reloadData];
//            }
//        }
        /* 1.0.3 */
        if (x) {
            self.topMsgModel = (MOLChatGroupModel *)x;
        }
        /* 1.0.3 */
        // 请求会话列表
        [self request_getChatList:NO];
        
    }];
}

#pragma mark - 长按手势
- (void)longPressGesture:(UIGestureRecognizer *)longGesture
{
    if (longGesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [longGesture locationInView:self.messageView.tableView];
        NSIndexPath *indexPath = [self.messageView.tableView indexPathForRowAtPoint:location];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            id model = self.messageView.dataSourceArray[indexPath.row];
            if ([model isKindOfClass:[MOLChatModel class]]) {  // 删除聊天
                MOLChatModel *chat = (MOLChatModel *)model;
                MOLDeleteChatViewController *vc = [[MOLDeleteChatViewController alloc] init];
                vc.chatModel = chat;
                @weakify(self);
                vc.deleteChatBlock = ^{
                    @strongify(self);
                    [self.messageView.dataSourceArray removeObject:model];
                    [self.messageView.tableView reloadData];
                };
                [self presentViewController:vc animated:YES completion:nil];
            }
        });
     
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MOLMessageListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id model = self.messageView.dataSourceArray[indexPath.row];
    if ([model isKindOfClass:[MOLChatModel class]]) {  // 跳转聊天
        MOLChatModel *chat = (MOLChatModel *)model;
        chat.unReadNum = @"0";
        cell.chatModel = chat;
        
//        MOLChatViewController *vc = [[MOLChatViewController alloc] init];
//        vc.chatId = chat.chatId;
//        vc.userModel = chat.toUser;
//        [self.navigationController pushViewController:vc animated:YES];
        
        EDChatViewController *vc = [[EDChatViewController alloc] init];
        vc.chatId = chat.chatId;
        vc.toUser = chat.toUser;
        @weakify(self);
        vc.refreshLastMessage = ^(NSString *message,NSString *type,BOOL isClose) {
            @strongify(self);
            MOLLightChatLogModel *vo = [MOLLightChatLogModel new];
            vo.content = message;
            vo.chatType = type;
            cell.chatModel.isClose = isClose;
            cell.chatModel.chatLogVO = vo;
            [self.messageView.tableView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        MOLSystemModel *sys = (MOLSystemModel *)model;
        sys.unReadNum = @"0";
        cell.systemModel = sys;
        if (sys.msgType.integerValue == 1) {  // 跳转系统通知
            MOLSystemNotiViewController *vc = [[MOLSystemNotiViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else{ // 跳转互动通知
            MOLInteractNotiViewController *vc = [[MOLInteractNotiViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageView.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id model = self.messageView.dataSourceArray[indexPath.row];
    MOLMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLMessageListCell_id"];
    if ([model isKindOfClass:[MOLChatModel class]]) {
        MOLChatModel *chat = (MOLChatModel *)model;
        cell.chatModel = chat;
    }else{
        MOLSystemModel *sys = (MOLSystemModel *)model;
        cell.systemModel = sys;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.endDrag = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.endDrag = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.endDrag && (scrollView.contentOffset.y >= MOL_MINE_MINPOP && scrollView.contentOffset.y <= MOL_MINE_MAXPOP)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *animation = [CATransition animation];
            animation.duration = 0.35;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromBottom;
            [self.view.window.layer addAnimation:animation forKey:@"CATransition_FromTop"];
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    }
}

#pragma mark - UI
- (void)setupMineMessageViewControllerUI
{
    MOLMineMessageView *messageView = [[MOLMineMessageView alloc] init];
    _messageView = messageView;
    [self.view addSubview:messageView ];
    messageView.tableView.delegate = self;
    messageView.tableView.dataSource = self;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longGesture.minimumPressDuration = 1;
    [self.messageView.tableView addGestureRecognizer:longGesture];
}

- (void)calculatorMineMessageViewControllerFrame
{
    self.messageView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorMineMessageViewControllerFrame];
}

@end
