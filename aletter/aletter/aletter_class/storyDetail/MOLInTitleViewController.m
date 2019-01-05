//
//  MOLInTitleViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/10.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLInTitleViewController.h"
#import "MOLHead.h"
#import "MOLChooseBoxCell.h"
#import "MOLOldNameView.h"
#import "MOLActionRequest.h"

@interface MOLInTitleViewController ()<UITableViewDelegate, UITableViewDataSource,YYTextKeyboardObserver, MOLOldNameViewDelegate, MOLChooseBoxCellDelegate>
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datasourceArray;

@property (nonatomic, assign) CGFloat headHeight;

@property (nonatomic, strong) MOLOldNameView *oldNameView;

@property (nonatomic, assign) CGFloat keyBoardHeight;

@property (nonatomic, strong) NSString *deafaultName;

@end

@implementation MOLInTitleViewController
- (void)dealloc
{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[YYTextKeyboardManager defaultManager] addObserver:self];
    _datasourceArray = [NSMutableArray array];
    [self setupInTitleViewControllerUI];
    
    if (self.type == MOLInTitleViewControllerType_comment) {
        self.deafaultName = @"为 [评论] 专门取一个名字…";
    }else if (self.type == MOLInTitleViewControllerType_story){
        self.deafaultName = @"为此刻的自己取一个名字，每次投递信件都可以换新名字";
    }else if (self.type == MOLInTitleViewControllerType_message){
        self.deafaultName = @"为自己去取一个名字，每次对话都可以换新名字";
    }
    
    if (self.type == MOLInTitleViewControllerType_story && self.mailModel) {
        MOLChooseBoxModel *model1 = [[MOLChooseBoxModel alloc] init];
        model1.modelType = MOLChooseBoxModelType_leftText;
        model1.leftImageString = INTITLE_LEFT_Normal;
        model1.leftTitle = @"把情绪装进了信封里…";
        [self request_getDataSourceWithModel:model1 index:self.datasourceArray.count];
        
        MOLChooseBoxModel *model2 = [[MOLChooseBoxModel alloc] init];
        model2.modelType = MOLChooseBoxModelType_middleImage;
        model2.middleImageString = self.mailModel.image;
        model2.middleTitle = self.mailModel.channelName;
        [self request_getDataSourceWithModel:model2 index:self.datasourceArray.count];
        
        MOLChooseBoxModel *model3 = [[MOLChooseBoxModel alloc] init];
        model3.modelType = MOLChooseBoxModelType_rightText;
        model3.rightImageString = INTITLE_RIGHT_Normal;
        model3.rightTitle = @"将信件投递到信箱中";
        [self request_getDataSourceWithModel:model3 index:self.datasourceArray.count];
    }
    
    
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Highlight;
    left_model.leftTitle = self.deafaultName;
    left_model.leftHighLight = YES;
    [self request_getDataSourceWithModel:left_model index:self.datasourceArray.count];
    
    MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
    right_model.modelType = MOLChooseBoxModelType_rightTextView;
    right_model.rightImageString = INTITLE_RIGHT_Tick;
    right_model.rightHighLight = YES;
    if (self.type != MOLInTitleViewControllerType_comment) {
        right_model.rightTitle = [MOLUserManagerInstance user_getUserLastName];
    }else{
        MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
        right_model.rightTitle = user.commentName;
    }
    [self request_getDataSourceWithModel:right_model index:self.datasourceArray.count];
    
    [self.tableView reloadData];
}

#pragma mark - MOLOldNameViewDelegate
- (void)oldNameView_clickCloseButtonOrOldName:(NSString *)name
{
    if (name.length) {
        [self.datasourceArray removeLastObject]; // 移除最后一个
        MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
        right_model.modelType = MOLChooseBoxModelType_rightTextView;
        right_model.rightImageString = INTITLE_RIGHT_Tick;
        right_model.rightTitle = name;
        right_model.rightHighLight = YES;
        [self request_getDataSourceWithModel:right_model index:self.datasourceArray.count];
        [self.tableView reloadData];
    }
    
    NSIndexPath *indeP = [NSIndexPath indexPathForRow:self.datasourceArray.count-1 inSection:0];
    MOLChooseBoxCell *cell = [self.tableView cellForRowAtIndexPath:indeP];
    [cell chooseBoxCell_keyBoardShow:YES];
}

#pragma mark - MOLChooseBoxCellDelegate
- (void)chooseBoxCell_shouldReturnWithName:(NSString *)name   // 点击键盘完成
{
    NSInteger num = [self caculaterName:name];
    if (num > 16) {
        MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
        right_model.modelType = MOLChooseBoxModelType_rightText;
        right_model.rightImageString = INTITLE_RIGHT_Normal;
        right_model.rightTitle = name;
        right_model.rightHighLight = YES;
        [self request_getDataSourceWithModel:right_model index:self.datasourceArray.count-1];
        
        MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
        left_model.modelType = MOLChooseBoxModelType_leftText;
        left_model.leftImageString = INTITLE_LEFT_Highlight;
        left_model.leftTitle = @"名字最多8个字，请再输入一次";
        left_model.leftHighLight = YES;
        [self request_getDataSourceWithModel:left_model index:self.datasourceArray.count-1];
        [self.tableView reloadData];
        
        NSIndexPath *indxP = [NSIndexPath indexPathForRow:self.datasourceArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indxP atScrollPosition:UITableViewScrollPositionNone animated:YES];
        return;
    }
    
    // 只有取评论名字的时候调用 取私信名字、取发帖名字不用发送请求
    if (self.type != MOLInTitleViewControllerType_comment) {
        
        // 将最近使用的名字存到本地
        [MOLUserManagerInstance user_saveUserLastNameWithName:name];
        if (self.type == MOLInTitleViewControllerType_message) {
            [self.view endEditing:YES];
            [self.navigationController popViewControllerAnimated:NO];
            if (self.messageActionBlock) {
                self.messageActionBlock();
            }
        }else{
//            [self.navigationController popViewControllerAnimated:NO];
            if (self.storyActionBlock) {
                self.storyActionBlock(self.datasourceArray);
            }
        }
        return;
    }
    
    // 发送请求
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"commentName"] = name;
    MOLActionRequest *r = [[MOLActionRequest alloc] initRequest_changeCommentNameActionCommentWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            // 跟新用户信息
            MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
            user.commentName = name;
            [MOLUserManagerInstance user_saveUserInfoWithModel:user];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            
            // 获取新数据源，展示
            MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
            right_model.modelType = MOLChooseBoxModelType_rightText;
            right_model.rightImageString = INTITLE_RIGHT_Normal;
            right_model.rightTitle = name;
            right_model.rightHighLight = YES;
            [self request_getDataSourceWithModel:right_model index:self.datasourceArray.count-1];
            
            MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
            left_model.modelType = MOLChooseBoxModelType_leftText;
            left_model.leftImageString = INTITLE_LEFT_Highlight;
            left_model.leftTitle = message;
            left_model.leftHighLight = YES;
            [self request_getDataSourceWithModel:left_model index:self.datasourceArray.count-1];
            [self.tableView reloadData];
            
            NSIndexPath *indxP = [NSIndexPath indexPathForRow:self.datasourceArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indxP atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

- (void)refreshHeadHeight
{
    CGFloat height = 0;
    if (self.tableView.contentSize.height < self.tableView.height) {
        height = self.tableView.height - self.tableView.contentSize.height - self.keyBoardHeight;
    }else{
        height = 0;
    }
    self.tableView.contentInset = UIEdgeInsetsMake(height, 0, self.keyBoardHeight, 0);
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition
{
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        ///用此方法获取键盘的rect
        CGRect kbFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
        ///从新计算view的位置并赋值
        self.keyBoardHeight = self.view.height - fabs(kbFrame.origin.y);
        [self refreshHeadHeight];
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - 网络请求
- (void)request_getDataSourceWithModel:(MOLChooseBoxModel *)model index:(NSInteger)index
{
    if (index == 0) {
        
    }else if (index == self.datasourceArray.count){
        
    }else{
        NSInteger num = index - 1;
        if (num < self.datasourceArray.count) {
            MOLChooseBoxModel *box = self.datasourceArray[num];
            box.leftHighLight = NO;
            box.leftImageString = INTITLE_LEFT_Normal;
            box.rightHighLight = NO;
        }
    }
    
    [self.datasourceArray insertObject:model atIndex:index];
    
//    if (self.datasourceArray.count > 2) {
//        MOLChooseBoxModel *box = self.datasourceArray.lastObject;
//        box.rightTitle = nil;
//    }
}

#pragma mark - 按钮点击
- (void)button_clickOldName  // 曾用名
{
    // 获取cell
    NSIndexPath *indeP = [NSIndexPath indexPathForRow:self.datasourceArray.count - 1 inSection:0];
    MOLChooseBoxCell *cell = [self.tableView cellForRowAtIndexPath:indeP];
    if (cell) {
        [cell chooseBoxCell_keyBoardShow:NO];
    }else{
        [self.view endEditing:YES];
    }
    
    [MOLAppDelegateWindow addSubview:self.oldNameView];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    return model.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLChooseBoxModel *model = self.datasourceArray[indexPath.row];
    MOLChooseBoxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOLChooseBoxCell_id"];
    cell.delegate = self;
    cell.boxModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MOLChooseBoxCell *boxCell = (MOLChooseBoxCell *)cell;
        [boxCell chooseBoxCell_keyBoardShow:YES];
    });
}

#pragma mark - UI
- (void)setupInTitleViewControllerUI
{
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[MOLChooseBoxCell class] forCellReuseIdentifier:@"MOLChooseBoxCell_id"];
    tableView.contentInset = UIEdgeInsetsMake(MOL_SCREEN_HEIGHT - 95 - MOL_TabbarSafeBottomMargin, 0, 0, 0);
    [self.view addSubview:tableView];
    
    [self basevc_setCenterTitle:@"取名字" titleColor:HEX_COLOR(0xffffff)];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem mol_barButtonItemWithTitleName:@"曾用名" targat:self action:@selector(button_clickOldName)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)calculatorInTitleViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorInTitleViewControllerFrame];
}

#pragma mark - 懒加载
- (MOLOldNameView *)oldNameView
{
    if (_oldNameView == nil) {
        _oldNameView = [[MOLOldNameView alloc] init];
        _oldNameView.width = MOL_SCREEN_WIDTH;
        _oldNameView.height = MOL_SCREEN_HEIGHT;
        _oldNameView.delegate = self;
    }
    
    return _oldNameView;
}

#pragma mark - 计算名字的长度（一个汉字占两个字符）
- (NSInteger)caculaterName:(NSString *)name
{
    NSInteger length = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    length -= (length - name.length) / 2;
    //    length = (length +1) / 2;
    return length;
}
@end
