//
//  EDChatViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDChatViewController.h"
#import "MOLHead.h"
#import "EDChatService.h"
#import "EDBaseMessageModel.h"
#import "EDBaseChatCell.h"
#import "EDInputView.h"
#import "MOLMessageRequest.h"
#import "EDStoryMessageModel.h"
#import "MOLActionChatViewController.h"
#import "MOLChatViewModel.h"
#import "MOLChatFootView.h"
#import "MOLChatHeadView.h"
#import "MOLStoryDetailViewController.h"
@interface EDChatViewController ()<UITableViewDelegate, UITableViewDataSource,EDChatTableViewDelegate,EDInputViewDelegate,EDChatServiceDelegate,YYTextKeyboardObserver,EDBaseChatCellDelegate>
@property (nonatomic, strong) EDChatService *chatService;
@property (nonatomic, strong) MOLChatViewModel *chatViewModel;
@property (nonatomic, weak) EDInputView *inputView;
@property (nonatomic, strong) MOLChatFootView *footView;
@property (nonatomic, strong) MOLChatHeadView *headView;
/**
 * @brief 聊天界面的tableView
 */
@property (nonatomic, strong) EDChatTableView *chatTableView;
@property (nonatomic, assign) BOOL refreshData;

@property (nonatomic, strong) EDStoryMessageModel *storyChatModel; // 帖子会话信息

@property (nonatomic, strong) MOLLightUserModel *ownUser; // 我的信息

@property (nonatomic, strong) NSString *storyId;
@end

@implementation EDChatViewController

-(void)dealloc
{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 获取最后一条消息
    EDBaseMessageModel *last = self.chatService.cellModels.lastObject;
    
    if (self.refreshLastMessage) {
        self.refreshLastMessage(last.content, [NSString stringWithFormat:@"%ld",last.chatType], self.storyChatModel.isClose);
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatService = [[EDChatService alloc] init];
    self.chatViewModel = [[MOLChatViewModel alloc] init];
    self.chatService.ServiceDelegate = self;
    
    [self setupChatViewControllerUI];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
    
    [self bindingChatViewModel];
    
    // 获取历史数据 / 获取会话的帖子详情
    if (self.vcType == 0) {
        // 第一次聊天
        if (self.storyModel) {
            self.storyId = self.storyModel.storyId;
            // 设置导航条
            [self basevc_setCenterTitle:self.toUser.userName titleColor:HEX_COLOR(0xffffff)];
            // 设置tableview头部
            EDBaseMessageModel *msgM = [[EDBaseMessageModel alloc] init];
            msgM.storyVO = self.storyModel;
            self.headView.model = msgM;
            self.chatTableView.tableHeaderView = self.headView;
            
            [self.inputView inputBecomeFirstResponse];
            
        }else if(self.chatId.length){
            @weakify(self);
            [self request_getMessageStoryInfo:^{
                // 获取聊天记录
                @strongify(self);
                [self request_getMessageList];
            }];
            [self basevc_setCenterTitle:self.toUser.userName titleColor:HEX_COLOR(0xffffff)];
        }
    }else{
        if (self.chatId.integerValue > 0) {  // 给建议和申诉。只有有chatId的时候才拉取会话内容
            [self request_getMessageList];
        }
        [self basevc_setCenterTitle:self.toUser.userName titleColor:HEX_COLOR(0xffffff)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageArrive:) name:@"ALETTER_PUSH_MESSAGE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eDImageCellEvent:) name:@"EDImageCellTap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mOLChatHeadViewEvent:) name:@"MOLChatHeadViewTap" object:nil];
}

- (void)newMessageArrive:(NSNotification *)noti
{
    NSDictionary *chateXT = noti.object;
    NSInteger type = [chateXT[@"msgType"] integerValue];
//    NSString *subtype = chateXT[@"type"];
    NSString *chatId = chateXT[@"typeId"];
    if ([chatId isEqualToString:self.chatId]) {
        [self.chatService serviceGettingNewMessagesWithChatId:self.chatId];
        
        if (self.vcType == 0) {
            if (type == 5 || type == 6) {
                [self request_getMessageStoryInfo:nil];
            }
            if (type == 4) {
                self.storyChatModel.isClose = 0;
                self.inputView.hidden = NO;
                self.footView.footType = MOLChatFootViewType_normal;
                [self.chatTableView reloadData];
            }
        }
    }
}

#pragma mark - 按钮的点击
- (void)button_rightButton
{
//    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    if (!self.storyChatModel.isClose) {
        
        // 弹出 关闭对话、举报对话
        MOLActionChatViewController *vc = [[MOLActionChatViewController alloc] init];
        vc.type = 1;
        @weakify(self);
        vc.closeChatBlock = ^{
            @strongify(self);
            [self.chatViewModel.closeChatCommand execute:self.chatId];
        };
        vc.reportChatBlock = ^(NSString *reason) {
            @strongify(self);
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"cause"] = reason;
            dic[@"reportType"] = @"2";
            dic[@"typeId"] = self.chatId;
            [self.chatViewModel.reportChatCommand execute:dic];
        };
        [self presentViewController:vc animated:YES completion:nil];
        
    }else{
        // 弹出 举报对话
        
        MOLActionChatViewController *vc = [[MOLActionChatViewController alloc] init];
        vc.type = 0;
        @weakify(self);
        vc.reportChatBlock = ^(NSString *reason) {
            @strongify(self);
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"cause"] = reason;
            dic[@"reportType"] = @"2";
            dic[@"typeId"] = self.chatId;
            [self.chatViewModel.reportChatCommand execute:dic];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
}
// 根据网络请求布局UI
- (void)setStoryChatModel:(EDStoryMessageModel *)storyChatModel
{
    MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
    
    _storyChatModel = storyChatModel;
    
    if ([user.userId isEqualToString:storyChatModel.ownUser.userId]) {
        self.ownUser = storyChatModel.ownUser;
    }else{
        self.ownUser = storyChatModel.toUser;
    }
    
    if (storyChatModel.isClose == 0) {
        // 如果关闭了，隐藏输入框
        self.inputView.hidden = NO;
        self.footView.footType = MOLChatFootViewType_normal;
        [self.chatTableView reloadData];
    }else{
        // 如果关闭了，隐藏输入框
        self.inputView.hidden = YES;
        if (storyChatModel.isClose == 1 && [storyChatModel.closeUserId isEqualToString:user.userId]) {
            // 展示重新开启对话
            self.footView.footType = MOLChatFootViewType_againChat;
            [self.chatTableView reloadData];
        }else if (storyChatModel.isClose == 2 && [storyChatModel.closeUserId isEqualToString:user.userId]){
            self.footView.footType = MOLChatFootViewType_requesting;
            [self.chatTableView reloadData];
        }else if (storyChatModel.isClose == 2 && ![storyChatModel.closeUserId isEqualToString:user.userId]){  // 收到请求
            self.footView.footType = MOLChatFootViewType_chatRequest;
            [self.chatTableView reloadData];
        }else if (storyChatModel.isClose == 3){
            self.footView.footType = MOLChatFootViewType_report;
            [self.chatTableView reloadData];
        }else{
            self.inputView.hidden = NO;
            self.footView.footType = MOLChatFootViewType_normal;
            [self.chatTableView reloadData];
        }
    }
    
    if (self.ownUser.canClose) {
        [self setupRightNavigationBarButton];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.inputView.placeholder = self.ownUser.userName;
}

#pragma mark - bindingViewModel
- (void)bindingChatViewModel
{
    @weakify(self);
    [self.chatViewModel.closeChatCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == MOL_SUCCESS_REQUEST) {
            self.inputView.hidden = YES;
            self.storyChatModel.isClose = 1;
            self.footView.footType = MOLChatFootViewType_againChat;
            [self.chatTableView reloadData];
            [self chatTableViewScrolledToBottom:YES];
        }
    }];
    
    [self.chatViewModel.openChatCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == MOL_SUCCESS_REQUEST) {
            self.inputView.hidden = YES;
            self.storyChatModel.isClose = 2;
            self.footView.footType = MOLChatFootViewType_requesting;
            [self.chatTableView reloadData];
            [self chatTableViewScrolledToBottom:YES];
        }
    }];
    
    [self.chatViewModel.agreeChatCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == MOL_SUCCESS_REQUEST) {
            self.inputView.hidden = NO;
            self.storyChatModel.isClose = 0;
            self.footView.footType = MOLChatFootViewType_normal;
            [self.chatTableView reloadData];
            [self chatTableViewScrolledToBottom:YES];
        }
    }];
    
    [self.chatViewModel.reportChatCommand.executionSignals.switchToLatest subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] == MOL_SUCCESS_REQUEST) {
            self.inputView.hidden = YES;
            self.storyChatModel.isClose = 3;
            self.footView.footType = MOLChatFootViewType_report;
            [self.chatTableView reloadData];
            [self chatTableViewScrolledToBottom:YES];
        }
    }];
}

#pragma mark - 获取数据
- (void)request_getMessageStoryInfo:(void(^)(void))successBlock
{
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_chatStoryInfoWithParameter:nil parameterId:self.chatId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
       
        EDStoryMessageModel *storyM = [EDStoryMessageModel mj_objectWithKeyValues:request.responseObject[@"resBody"]];
        self.storyChatModel = storyM;
        
        self.storyModel = storyM.storyVO;
        self.storyId = storyM.storyId;
        
        // 设置tableview头部
        self.headView.model = storyM;
        self.chatTableView.tableHeaderView = self.headView;
        
        if (code == MOL_SUCCESS_REQUEST) {
            if (successBlock) {
                successBlock();
            }
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}
- (void)request_getMessageList
{
    if (!self.chatId.length) {
        if (self.refreshData == YES) {
            self.refreshData = NO;
//            [MOLToast toast_showWithWarning:NO title:@"没有更多数据"];
            [self.chatTableView finishLoadingTopRefreshView];
        }
        return;
    }
    [self.chatService serviceStartGettingHistoryMessagesWithChatId:self.chatId];
    
}

// 滚动到底部
- (void)chatTableViewScrolledToBottom:(BOOL)animate
{
    if (self.chatService.cellModels.count) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatService.cellModels.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animate];
    }
}

#pragma mark - EDChatServiceDelegate

/**
 *  发送消息回调
 *
 */
- (void)service_sendMessageResultWithisResult:(BOOL)resultStatus messageId:(NSString *)messageId messageBody:(id)messageBody
{
    if (resultStatus) {
        
        EDBaseMessageModel *model = (EDBaseMessageModel *)messageBody;
        
        if (model.chatType == 0) {
            EDTextMessageModel *textM = (EDTextMessageModel *)messageBody;
            [self insertMessageToDataSource:textM type:0];
        }else if (model.chatType == 1){
            EDImageMessageModel *imageM = (EDImageMessageModel *)messageBody;
            [self insertMessageToDataSource:imageM type:1];
        }else if (model.chatType == 2){
            EDAudioMessageModel *audioM = (EDAudioMessageModel *)messageBody;
            [self insertMessageToDataSource:audioM type:2];
        }
        
        if (!self.chatId.length) {  // 接受到消息后，刷新一下该对话信息
            self.chatId = model.chatId;
            [self request_getMessageStoryInfo:nil];
        }
    }
}

/**
 *  获取到了更多历史消息
 */
- (void)service_didGetHistoryMessages
{
    // 结束下拉刷新
    if (self.refreshData == YES) {
        self.refreshData = NO;
        [self.chatTableView finishLoadingTopRefreshView];
        // 刷新列表
        [self.chatTableView reloadData];
    }else{
        // 刷新列表
        [self.chatTableView reloadData];
        
        [self chatTableViewScrolledToBottom:NO];
    }
}

/**
 *  通知viewController收到了消息
 */
- (void)service_didReceiveMessageWithMsg:(NSArray *)messageBody
{
    [self.chatTableView reloadData];
    [self chatTableViewScrolledToBottom:YES];
}

#pragma mark - EDInputViewDelegate
- (void)input_sendTextMessage:(NSString *)message  // 发送文本
{
    if (self.storyChatModel.isClose) {
        [MOLToast toast_showWithWarning:YES title:@"对方已关闭对话"];
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.vcType == 1) {
        dic[@"storyId"] = @"0";
        dic[@"userName"] = [MOLUserManagerInstance user_getUserInfo].userId;
    }else if (self.vcType == 2){
        dic[@"storyId"] = @"-1";
        dic[@"userName"] = [MOLUserManagerInstance user_getUserInfo].userId;
    }else{
        dic[@"storyId"] = self.storyModel.storyId.length ? self.storyModel.storyId : self.storyId;
        if (self.chatId.length) {
            dic[@"userName"] = self.ownUser.userName;
        }else{
            dic[@"userName"] = [MOLUserManagerInstance user_getUserLastName];
        }
    }
    dic[@"toUserId"] = self.toUser.userId;
    dic[@"toUserName"] = self.toUser.userName;
    [self.chatService serviceSendTextMessageWithContent:message user:dic];
    
    [self.inputView inputResetText];
    
}
- (void)input_sendAudioMessage:(NSString *)message time:(NSInteger)time results:(id)result
{
    if (self.storyChatModel.isClose) {
        [MOLToast toast_showWithWarning:YES title:@"对方已关闭对话"];
        return;
    }
    NSMutableDictionary *audioBody = [NSMutableDictionary dictionary];
    audioBody[@"audioUrl"] = message;
    audioBody[@"audioTime"] = [NSString stringWithFormat:@"%ld",time];
    audioBody[@"audioText"] = result;
    NSString *jsonS = [self dictionaryToJSONString:audioBody];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.vcType == 1) {
        dic[@"storyId"] = @"0";
        dic[@"userName"] = [MOLUserManagerInstance user_getUserInfo].userId;
    }else if (self.vcType == 2){
        dic[@"storyId"] = @"-1";
        dic[@"userName"] = [MOLUserManagerInstance user_getUserInfo].userId;
    }else{
        dic[@"storyId"] = self.storyModel.storyId.length ? self.storyModel.storyId : self.storyId;
//        dic[@"userName"] = [MOLUserManagerInstance user_getUserLastName];
        if (self.chatId.length) {
            dic[@"userName"] = self.ownUser.userName;
        }else{
            dic[@"userName"] = [MOLUserManagerInstance user_getUserLastName];
        }
    }
    dic[@"toUserId"] = self.toUser.userId;
    dic[@"toUserName"] = self.toUser.userName;
    [self.chatService serviceSendVoiceMessageWithAMRFilePath:jsonS user:dic];
}
- (void)input_sendImageMessage:(NSString *)message  // 发送图片
{
    if (self.storyChatModel.isClose) {
        [MOLToast toast_showWithWarning:YES title:@"对方已关闭对话"];
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.vcType == 1) {
        dic[@"storyId"] = @"0";
        dic[@"userName"] = [MOLUserManagerInstance user_getUserInfo].userId;
    }else if (self.vcType == 2){
        dic[@"storyId"] = @"-1";
        dic[@"userName"] = [MOLUserManagerInstance user_getUserInfo].userId;
    }else{
        dic[@"storyId"] = self.storyModel.storyId.length ? self.storyModel.storyId : self.storyId;
//        dic[@"userName"] = [MOLUserManagerInstance user_getUserLastName];
        if (self.chatId.length) {
            dic[@"userName"] = self.ownUser.userName;
        }else{
            dic[@"userName"] = [MOLUserManagerInstance user_getUserLastName];
        }
    }
    dic[@"toUserId"] = self.toUser.userId;
    dic[@"toUserName"] = self.toUser.userName;
    [self.chatService serviceSendImageMessageWithImage:message user:dic];
}

- (void)insertMessageToDataSource:(id)messageBody type:(NSInteger)type  // 0 文本 1图片 2语音
{
    [self insertMessageTimeSource:messageBody];
    
     [self.chatService.cellModels addObject:messageBody];
    
    [self.chatTableView reloadData];
    [self chatTableViewScrolledToBottom:YES];
}

// 判断是否插入时间
- (void)insertMessageTimeSource:(id)messageBody
{
    // 该条的时间
    EDBaseMessageModel *msg = (EDBaseMessageModel *)messageBody;
    
    // 获取最后一条消息的时间
    EDBaseMessageModel *lastM = self.chatService.cellModels.lastObject;
    
    if (!lastM || (msg.createTime.integerValue - lastM.createTime.integerValue > MOL_TIME_MARGIN * 1000)) {
        // 插入时间
        NSString *t = msg.createTime;
        EDTimeMessageModel *timeMsg = [[EDTimeMessageModel alloc] initWithTime:[NSString moli_timeGetMessageTimeWithTimestamp:t]];
        [self.chatService.cellModels addObject:timeMsg];
    }
}

#pragma mark - EDChatTableViewDelegate
- (void)didTapChatTableView:(UITableView *)tableView {
    [self.view endEditing:true];
}

// 开始下拉刷新
- (void)startLoadingTopMessagesInTableView:(UITableView *)tableView {
    self.refreshData = YES;
    [self request_getMessageList];
}

//- (void)hiddenMsgRecordInput
//{
//     [self.view endEditing:true];
//}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 获取数据

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatService.cellModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取model
    EDBaseMessageModel *model = self.chatService.cellModels[indexPath.row];
    NSString *cellModelName = NSStringFromClass([model class]);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellModelName];
    
    if (!cell) {
        cell = [model getCellWithReuseIdentifier:cellModelName];
    }
    

    // 刷新数据
    [(EDBaseChatCell *)cell updateCellWithCellModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EDBaseMessageModel *model = self.chatService.cellModels[indexPath.row];
    return [model getCellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.footView.height;
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.chatTableView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition
{
    CGRect kbFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        ///用此方法获取键盘的rect
        if (kbFrame.origin.y < self.view.height) {   // 键盘上
            
            self.chatTableView.contentInset = UIEdgeInsetsMake(self.chatTableView.contentInset.top, self.chatTableView.contentInset.left, self.inputView.height + kbFrame.size.height, self.chatTableView.contentInset.right);
        }else{   // 键盘下
            self.chatTableView.contentInset = UIEdgeInsetsMake(self.chatTableView.contentInset.top, self.chatTableView.contentInset.left, 0, self.chatTableView.contentInset.right);
        }
        
    } completion:^(BOOL finished) {
        [self chatTableViewScrolledToBottom:YES];
    }];
}

#pragma mark - UI
- (void)setupRightNavigationBarButton
{
    UIBarButtonItem *rightB = [UIBarButtonItem mol_barButtonItemWithImageName:@"msg_point" highlightImageName:@"msg_point" targat:self action:@selector(button_rightButton)];
    self.navigationItem.rightBarButtonItem = rightB;
}

- (void)setupChatViewControllerUI
{
    EDChatTableView *tableView = [[EDChatTableView alloc] initWithFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _chatTableView = tableView;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.chatTableViewDelegate = self;
    [self.view addSubview:tableView];
    
    EDInputView *inputView = [[EDInputView alloc] init];
    _inputView = inputView;
    self.inputView.width = MOL_SCREEN_WIDTH;
    self.inputView.height = 44 + MOL_TabbarSafeBottomMargin;
    self.inputView.y = self.view.height - MOL_StatusBarAndNavigationBarHeight - self.inputView.height;
    self.inputView.delegate = self;
//    self.inputView.placeholder =[MOLUserManagerInstance user_getUserLastName];
    if (self.chatId.length) {
        self.inputView.placeholder = self.ownUser.userName;
    }else{
        self.inputView.placeholder = [MOLUserManagerInstance user_getUserLastName];
    }
    [self.view addSubview:inputView];
    
}

- (void)calculatorChatViewControllerFrame
{
    self.chatTableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.inputView.height);
    [self.chatTableView updateFrame:self.chatTableView.frame];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorChatViewControllerFrame];
}


-(NSString *)dictionaryToJSONString:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

#pragma mark - 懒加载
- (MOLChatFootView *)footView
{
    if (_footView == nil) {
        
        _footView = [[MOLChatFootView alloc] init];
        _footView.width = MOL_SCREEN_WIDTH;
        _footView.height = 0.01;
        _footView.footType = MOLChatFootViewType_normal;
        @weakify(self);
        _footView.actionFootBlock = ^(MOLChatFootViewType type) {
            @strongify(self);
            if (type == MOLChatFootViewType_againChat) {
                [self.chatViewModel.openChatCommand execute:self.chatId];
            }else if (type == MOLChatFootViewType_chatRequest){
                [self.chatViewModel.agreeChatCommand execute:self.chatId];
            }
        };
    }
    
    return _footView;
}

- (MOLChatHeadView *)headView
{
    if (_headView == nil) {
        _headView = [[MOLChatHeadView alloc] init];
        _headView.width = MOL_SCREEN_WIDTH;
        _headView.height = 200;
    }
    
    return _headView;
}

#pragma mark-
#pragma mark EDImageCell
-(void)eDImageCellEvent:(NSNotification *)notif{
    if (notif) {
        
        [self.inputView inputRegist];
        
        NSString *urlStr =(NSString *)notif.object;
        HZPhotoBrowser *browser = [[HZPhotoBrowser alloc] init];
        browser.isNeedLandscape = NO;
       
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject: urlStr?urlStr:@""];
        browser.imageArray = arr;
        [browser show];
    }
}

- (void)mOLChatHeadViewEvent:(NSNotification *)notif{
    if (notif) {
        EDBaseMessageModel *msgDto =(EDBaseMessageModel *)notif.object;
        MOLStoryDetailViewController *vc = [[MOLStoryDetailViewController alloc] init];
        vc.storyId = msgDto.storyVO.storyId;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
@end
