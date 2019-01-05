//
//  MOLSendPostViewController.m
//  aletter
//
//  Created by xujin on 2018/8/22.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSendPostViewController.h"
#import "MOLMailboxTableViewProxy.h"
#import "MOLChooseBoxCell.h"
#import "PostModel.h"
#import "MOLHead.h"
//#import "MOLInTitleViewController.h"
#import "MOLActionRequest.h"
//#import "MOLMailDetailViewController.h"
//#import "MOLHomeViewController.h"
#import "MOLSendEndPostViewController.h"
#import "MOLPostViewController.h"
#import "MOLMineViewController.h"
#import "LocationViewController.h"
#import "MOLOldNameView.h"

@interface MOLSendPostViewController ()<MOLOldNameViewDelegate,YYTextKeyboardObserver>
@property(nonatomic,strong) UITableView *mailBoxTable;
@property(nonatomic,strong) MOLMailboxTableViewProxy *mailboxTableViewProxy;
@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) NSMutableArray *dataSourceArr;
@property(nonatomic,strong) NSArray *titleArr;
@property(nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic, strong) MOLOldNameView *oldNameView;
@property (nonatomic, assign) CGFloat keyBoardHeight;
@property (nonatomic, strong) UIView *navGationView;
@property (nonatomic, assign) CGFloat bottomHeight;
@property (nonatomic, assign) CGSize originalSize;
@property (nonatomic, assign) BOOL isfirst;

@end

@implementation MOLSendPostViewController
- (void)dealloc
{
    [[YYTextKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutNavigationView];
    [self layoutSubViews];
    
    [self initData];
}


- (void)layoutNavigationView{
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[MOLPostViewController class]]) {
            [obj removeFromParentViewController];
        }
    }];
    
    UIButton *leftButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setFrame:CGRectMake(10, 20, 44, 44)];
    [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.navGationView addSubview:leftButton];
    
    UILabel *titleL =[UILabel new];
    [titleL setFrame:CGRectMake(0, 20, 100, 44)];
    titleL.centerX =self.navGationView.centerX;
    [titleL setTextColor:HEX_COLOR(0xffffff)];
    [titleL setText: @"取名字"];
    [titleL setTextAlignment:NSTextAlignmentCenter];
    [titleL setFont: MOL_REGULAR_FONT(18)];
    [self.navGationView addSubview:titleL];
    //[self basevc_setCenterTitle:@"取名字" titleColor:HEX_COLOR(0xffffff)];
    
    UIButton *rightButotn =[UIButton buttonWithType:UIButtonTypeCustom];
    [rightButotn setFrame:CGRectMake(MOL_SCREEN_WIDTH-10-60, 20, 60, 44)];
    [rightButotn setTitle:@"曾用名" forState:UIControlStateNormal];
    [rightButotn setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.7) forState:UIControlStateNormal];
    [rightButotn setTitleColor:HEX_COLOR_ALPHA(0xffffff, 1) forState:UIControlStateSelected];
    [rightButotn.titleLabel setFont:MOL_MEDIUM_FONT(14)];
    [rightButotn addTarget:self action:@selector(button_clickOldName) forControlEvents:UIControlEventTouchUpInside];
    [self.navGationView addSubview:rightButotn];
    
    
}

- (UIView *)navGationView{
    if (!_navGationView) {
        _navGationView =[UIView new];
        [_navGationView setBackgroundColor: [UIColor clearColor]];
        [_navGationView setFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH, 64)];
    }
    return _navGationView;
}


- (void)initData{
    self.isfirst =NO;
    self.bottomHeight =20.0;
    self.dataSourceArr =[NSMutableArray new];
    [self initUI];
   // [self refreshHeadHeight];
}

- (void)initUI{
    //self.mailBoxTable.contentSize =CGSizeZero;
    
    [self.dataSourceArr removeAllObjects];
    NSString *title = @"将信件投递到信箱中";
    self.titleArr =@[title,@"存为私密信件"];
    
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Highlight;
    left_model.leftTitle =@"把情绪装进了信封里…";
    left_model.leftHighLight = YES;
    [self.dataSourceArr addObject:left_model];
    
    MOLChooseBoxModel *center_model = [[MOLChooseBoxModel alloc] init];
    center_model.modelType = MOLChooseBoxModelType_middleEnvelopeImage;
    //center_model.middleImageString = self.postModel.mailModel.image;
    center_model.middleImageString = @"mine_mail";
    center_model.middleEnvelopeImageHighLight =YES;
    center_model.middleTitle =self.postModel.mailModel.channelName;
    
    [self.dataSourceArr addObject:center_model];
    
    
    for (NSInteger i = 0; i < self.titleArr.count; i++) {
        MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
        model.modelType = MOLChooseBoxModelType_rightChooseButton;
        model.buttonTitle = self.titleArr[i];
        [self.dataSourceArr addObject:model];
    }
    
    self.mailboxTableViewProxy.dataArr=self.dataSourceArr;
    self.mailboxTableViewProxy.titleArr=self.titleArr;
    
    [self.mailBoxTable reloadData];

    if (!self.isfirst) {
        self.isfirst =!self.isfirst;
        self.originalSize =self.mailBoxTable.contentSize;
    }
    
   
}

- (void)respondsUI{
    
    if (self.postModel) {
      //  self.mailBoxTable.contentSize =CGSizeZero;
       // [[YYTextKeyboardManager defaultManager] addObserver:self];
        [self.dataSourceArr removeAllObjects];
        MOLChooseBoxModel *model1 = [[MOLChooseBoxModel alloc] init];
        model1.modelType = MOLChooseBoxModelType_leftText;
        model1.leftImageString = INTITLE_LEFT_Normal;
        model1.leftTitle = @"把情绪装进了信封里…";
        [self request_getDataSourceWithModel:model1 index:self.dataSourceArr.count];
        
        MOLChooseBoxModel *model2 = [[MOLChooseBoxModel alloc] init];
        model2.modelType = MOLChooseBoxModelType_middleImage;
        //model2.middleImageString = self.postModel.mailModel.image;
        model2.modelType = MOLChooseBoxModelType_middleEnvelopeImage;
        model2.middleImageString = @"mine_mail";
        model2.middleEnvelopeImageHighLight =NO;
        model2.middleTitle = self.postModel.mailModel.channelName;
        [self request_getDataSourceWithModel:model2 index:self.dataSourceArr.count];
        
        MOLChooseBoxModel *model3 = [[MOLChooseBoxModel alloc] init];
        model3.modelType = MOLChooseBoxModelType_rightText;
        model3.rightImageString = INTITLE_RIGHT_Normal;
        model3.rightTitle = @"将信件投递到信箱中";
        [self request_getDataSourceWithModel:model3 index:self.dataSourceArr.count];
    }
    
    
    MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
    left_model.modelType = MOLChooseBoxModelType_leftText;
    left_model.leftImageString = INTITLE_LEFT_Highlight;
    left_model.leftTitle = @"为此刻的自己取一个名字，每次投递信件都可以换新名字";
    left_model.leftHighLight = YES;
    [self request_getDataSourceWithModel:left_model index:self.dataSourceArr.count];
    
    MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
    right_model.modelType = MOLChooseBoxModelType_rightTextView;
    right_model.rightImageString = INTITLE_RIGHT_Tick;
    right_model.rightHighLight = YES;
    
    right_model.rightTitle = [MOLUserManagerInstance user_getUserLastName];
    
    [self request_getDataSourceWithModel:right_model index:self.dataSourceArr.count];
    
   [self.mailBoxTable reloadData];
    

}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

- (void)layoutSubViews{
    [[YYTextKeyboardManager defaultManager] addObserver:self];
    [self.view addSubview:self.mailBoxTable];
    [self.view addSubview:self.navGationView];
}


#pragma mark-
#pragma mark 懒加载对象

- (UITableView *)mailBoxTable{
    if (!_mailBoxTable) {
        _mailBoxTable =[[UITableView alloc] initWithFrame:CGRectMake(0, 64,MOL_SCREEN_WIDTH,MOL_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        [_mailBoxTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_mailBoxTable setBackgroundColor: [UIColor clearColor]];
        [_mailBoxTable setDelegate:self.mailboxTableViewProxy];
        [_mailBoxTable setDataSource:self.mailboxTableViewProxy];
        
        if (@available(iOS 11.0, *)) {
            _mailBoxTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _mailBoxTable.estimatedRowHeight = 0;
        _mailBoxTable.estimatedSectionHeaderHeight = 0;
        _mailBoxTable.estimatedSectionFooterHeight = 0;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        [_mailBoxTable registerClass:[MOLChooseBoxCell class] forCellReuseIdentifier:@"MOLChooseBoxCellID"];
    
    }
    return _mailBoxTable;
}


- (MOLMailboxTableViewProxy *)mailboxTableViewProxy {
    if (_mailboxTableViewProxy == nil){
        _mailboxTableViewProxy = [[MOLMailboxTableViewProxy alloc] init];
        @weakify(self);
        _mailboxTableViewProxy.mailboxTableViewProxyUserNameBlock = ^(NSString *name) {
            [MobClick event:@"_c_finish_name"];
             @strongify(self);
            NSInteger num = [self caculaterName:name];
            if (num > 16) {
                MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
                right_model.modelType = MOLChooseBoxModelType_rightText;
                right_model.rightImageString = INTITLE_RIGHT_Normal;
                right_model.rightTitle = name;
                right_model.rightHighLight = YES;
                [self request_getDataSourceWithModel:right_model index:self.dataSourceArr.count-1];
                
                MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
                left_model.modelType = MOLChooseBoxModelType_leftText;
                left_model.leftImageString = INTITLE_LEFT_Highlight;
                left_model.leftTitle = @"名字最多8个字，请再输入一次";
                left_model.leftHighLight = YES;
                [self request_getDataSourceWithModel:left_model index:self.dataSourceArr.count-1];
                [self.mailBoxTable reloadData];
                
                NSIndexPath *indxP = [NSIndexPath indexPathForRow:self.dataSourceArr.count-1 inSection:0];
                [self.mailBoxTable scrollToRowAtIndexPath:indxP atScrollPosition:UITableViewScrollPositionNone animated:YES];
                return;
            }
            
            // 将最近使用的名字存到本地
            [MOLUserManagerInstance user_saveUserLastNameWithName:name];
            self.postModel.name =name;
            self.dataArr =[NSMutableArray arrayWithArray:self.dataSourceArr];
            [self.dataArr removeLastObject];
            MOLChooseBoxModel *last = self.dataSourceArr.lastObject;
            MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
            model.modelType = MOLChooseBoxModelType_rightText;
            model.rightImageString = INTITLE_RIGHT_Normal;
            model.rightTitle =last.rightTitle;
            model.rightHighLight = NO;
            [self.dataArr addObject:model];
            [self storePrivateEnvelopePublicUploadingDataToNet];
            
        };
        _mailboxTableViewProxy.MailboxTableViewProxyWriteBlock = ^(NSIndexPath *indexPath) {
            //触发该事件
            @strongify(self);
            //dispatch_async(dispatch_get_main_queue(), ^{
                [self respondsUI];
            [MobClick event:@"_c_delivery_letter"];
            //});
            
        };
        
        
        _mailboxTableViewProxy.mailboxTableViewProxyCloseBlock = ^(NSIndexPath *indexPath) {
            @strongify(self);
            [MobClick event:@"_c_save_as_private"];
            [self.navigationController popToRootViewControllerAnimated:NO];
            MOLMineViewController *mineVc = [[MOLMineViewController alloc] init];
            mineVc.index = 1;
            MOLBaseNavigationController *nav = [[MOLBaseNavigationController alloc] initWithRootViewController:mineVc];
            [[[MOLGlobalManager shareGlobalManager] global_rootViewControl] presentViewController:nav animated:NO completion:nil];
        };
        
    }
    return _mailboxTableViewProxy;
}


- (void)storePrivateEnvelopePublicUploadingDataToNet{// 公开
    // 发送请求
    __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *dic =[NSMutableDictionary new];
    [dic setObject:self.postModel.storyId?self.postModel.storyId:@"" forKey:@"storyId"];
    [dic setObject:self.postModel.name?self.postModel.name:@"" forKey:@"name"];
    [[[MOLActionRequest alloc] initRequest_publsihPrivateStoryWithParameter:dic parameterId:self.postModel.storyId] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        if (code == MOL_SUCCESS_REQUEST) {
            ///如果是第一次安装，则显示定位页面，否则跳转到完成页面
            if (![[NSUserDefaults standardUserDefaults] objectForKey: @"isFirstLocation"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLocation"];
                LocationViewController *locationController =[LocationViewController new];
                locationController.postModel =weakSelf.postModel;
                locationController.dataArray =weakSelf.dataArr;
                [weakSelf.navigationController pushViewController:locationController animated:NO];
                
            }else{
                MOLSendEndPostViewController *sendEndPost=[MOLSendEndPostViewController new];
                sendEndPost.postModel =weakSelf.postModel;
                sendEndPost.dataArray = weakSelf.dataArr;
                [weakSelf.navigationController pushViewController:sendEndPost animated:NO];
            }
            
            [MOLToast toast_showWithWarning:YES title:[NSString stringWithFormat:@"信件已投递到%@の信箱",weakSelf.postModel.mailModel.channelName?weakSelf.postModel.mailModel.channelName:@""]];
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];

}

#pragma mark - MOLOldNameViewDelegate
- (void)oldNameView_clickCloseButtonOrOldName:(NSString *)name
{
    if (name.length) {
        [self.dataSourceArr removeLastObject]; // 移除最后一个
        MOLChooseBoxModel *right_model = [[MOLChooseBoxModel alloc] init];
        right_model.modelType = MOLChooseBoxModelType_rightTextView;
        right_model.rightImageString = INTITLE_RIGHT_Tick;
        right_model.rightTitle = name;
        right_model.rightHighLight = YES;
        [self request_getDataSourceWithModel:right_model index:self.dataSourceArr.count];
        [self.mailBoxTable reloadData];
    }
    
    NSIndexPath *indeP = [NSIndexPath indexPathForRow:self.dataSourceArr.count-1 inSection:0];
    MOLChooseBoxCell *cell = [self.mailBoxTable cellForRowAtIndexPath:indeP];
    [cell chooseBoxCell_keyBoardShow:YES];
}

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

#pragma mark - 按钮点击
- (void)button_clickOldName  // 曾用名
{
    // 获取cell
    NSIndexPath *indeP = [NSIndexPath indexPathForRow:self.dataSourceArr.count - 1 inSection:0];
    MOLChooseBoxCell *cell = [self.mailBoxTable cellForRowAtIndexPath:indeP];
    if (cell) {
        [cell chooseBoxCell_keyBoardShow:NO];
    }else{
        [self.view endEditing:YES];
    }
    
    [MOLAppDelegateWindow addSubview:self.oldNameView];
}

- (void)request_getDataSourceWithModel:(MOLChooseBoxModel *)model index:(NSInteger)index
{
    if (index == 0) {
        
    }else if (index == self.dataSourceArr.count){
        
    }else{
        NSInteger num = index - 1;
        if (num < self.dataSourceArr.count) {
            MOLChooseBoxModel *box = self.dataSourceArr[num];
            box.leftHighLight = NO;
            box.leftImageString = INTITLE_LEFT_Normal;
            box.rightHighLight = NO;
        }
    }
    
    [self.dataSourceArr insertObject:model atIndex:index];
   
}

#pragma mark - YYTextKeyboardObserver
- (void)keyboardChangedWithTransition:(YYTextKeyboardTransition)transition
{
    NSTimeInterval duration = transition.animationDuration;
    UIViewAnimationCurve curve = transition.animationCurve;
    ///用此方法获取键盘的rect
    CGRect kbFrame = [[YYTextKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    ///从新计算view的位置并赋值
    
    self.keyBoardHeight = self.view.height- fabs(kbFrame.origin.y);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    
    [UIView commitAnimations];
    if (self.keyBoardHeight <=0) { //键盘隐藏
        [self.navGationView setAlpha:0];
        self.bottomHeight =20.0;
        
    }else{//键盘显示
        [self.navGationView setAlpha:1];
        self.bottomHeight =0.0;
    }
    [self refreshHeadHeight];
}

- (void)refreshHeadHeight
{
    
    CGFloat height = 0;
    height = self.mailBoxTable.height - self.mailBoxTable.contentSize.height - self.keyBoardHeight-self.bottomHeight;
    if (height<=0) {
        height =0;
    }else{
        
    }
    self.mailBoxTable.contentInset = UIEdgeInsetsMake(height, 0, self.keyBoardHeight, 0);
    
   // NSLog(@"mailBoxTable--->%lf  contentSize--->%lf keyBoardHeight---%lf  top---%lf",self.mailBoxTable.height,self.mailBoxTable.contentSize.height,self.keyBoardHeight,height);

}

- (void)leftButtonEvent:(UIButton *)sender{
    
        self.keyBoardHeight =0.0;
        [self.navGationView setAlpha:0];
        [self.mailBoxTable setContentSize:self.originalSize];
        [self initUI];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
