//
//  LocationViewController.m
//  aletter
//
//  Created by xujin on 2018/9/4.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "LocationViewController.h"
#import "MOLMailboxTableViewProxy.h"
#import "MOLChooseBoxCell.h"
#import "MOLHead.h"
#import "MOLSendEndPostViewController.h"
#import "TZLocationManager.h"
#import "PostModel.h"

@interface LocationViewController ()
@property(nonatomic,strong) UITableView *mailBoxTable;
@property(nonatomic,strong) MOLMailboxTableViewProxy *mailboxTableViewProxy;
@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) NSMutableArray *dataSourceArr;
@property(nonatomic,strong) NSArray *titleArr;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutSubViews];
    [self initData];
}

- (void)initData{
    
    self.dataSourceArr =[NSMutableArray new];
    
    self.titleArr =@[@"打开定位权限",@"我拒绝"];
    
    
    
    MOLChooseBoxModel *left_model3 = [[MOLChooseBoxModel alloc] init];
    left_model3.modelType = MOLChooseBoxModelType_leftText;
    left_model3.leftImageString = INTITLE_LEFT_Highlight;
    left_model3.leftTitle =@"请允许我们读取你的定位信息，用于匹配同一个城市的人";
    left_model3.leftHighLight = YES;
    [self.dataSourceArr addObject:left_model3];
    
    for (NSInteger i = 0; i < self.titleArr.count; i++) {
        MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
        model.modelType = MOLChooseBoxModelType_rightChooseButton;
        model.buttonTitle = self.titleArr[i];
        [self.dataSourceArr addObject:model];
    }
    
    self.mailboxTableViewProxy.dataArr=self.dataSourceArr;
    self.mailboxTableViewProxy.titleArr=self.titleArr;
    [self.mailBoxTable reloadData];
    [self JGScrollToBottom:YES];
    
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    __weak __typeof(self) weakSelf = self;
    [self.mailBoxTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.view);
        make.width.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(weakSelf.view);
    }];
    
    
    
}

#pragma mark-
#pragma mark 懒加载对象

- (UITableView *)mailBoxTable{
    if (!_mailBoxTable) {
        _mailBoxTable =[[UITableView alloc] initWithFrame:CGRectMake(0, 0,MOL_SCREEN_WIDTH,MOL_SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        [_mailBoxTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_mailBoxTable setBackgroundColor: [UIColor clearColor]];
        [_mailBoxTable setDelegate:self.mailboxTableViewProxy];
        [_mailBoxTable setDataSource:self.mailboxTableViewProxy];
        
        [_mailBoxTable registerClass:[MOLChooseBoxCell class] forCellReuseIdentifier:@"MOLChooseBoxCellID"];
        [_mailBoxTable setTableHeaderView:self.tableHeaderView];
        [_mailBoxTable.tableHeaderView setUserInteractionEnabled:NO];
        
    }
    return _mailBoxTable;
}

- (MOLMailboxTableViewProxy *)mailboxTableViewProxy {
    if (_mailboxTableViewProxy == nil){
        _mailboxTableViewProxy = [[MOLMailboxTableViewProxy alloc] init];
        __weak __typeof(self) weakSelf = self;
        _mailboxTableViewProxy.MailboxTableViewProxyWriteBlock = ^(NSIndexPath *indexPath) { //打开定位信息
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (kCLAuthorizationStatusNotDetermined == status) {
                [[TZLocationManager manager] startLocation];
            }
            else {
                [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
                    MOLSendEndPostViewController *sendEndPost=[MOLSendEndPostViewController new];
                    weakSelf.postModel.location =locations.firstObject;
                    sendEndPost.postModel =weakSelf.postModel;
                    sendEndPost.dataArray = weakSelf.dataArray;
                    
                    [weakSelf.navigationController pushViewController:sendEndPost animated:NO];
                } failureBlock:^(NSError *error) {
                    MOLSendEndPostViewController *sendEndPost=[MOLSendEndPostViewController new];
                    sendEndPost.postModel =weakSelf.postModel;
                    sendEndPost.dataArray = weakSelf.dataArray;
                    [weakSelf.navigationController pushViewController:sendEndPost animated:NO];
                }];
                
            }
        };
    
        _mailboxTableViewProxy.mailboxTableViewProxyCloseBlock = ^(NSIndexPath *indexPath) { //我手滑信息
            MOLSendEndPostViewController *sendEndPost=[MOLSendEndPostViewController new];
            sendEndPost.postModel =weakSelf.postModel;
            sendEndPost.dataArray = weakSelf.dataArray;
            [weakSelf.navigationController pushViewController:sendEndPost animated:NO];
        };
        
    }
    return _mailboxTableViewProxy;
}


- (UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView =[UIView new];
        [_tableHeaderView setBackgroundColor: [UIColor clearColor]];
        [_tableHeaderView setFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH,  MOL_SCREEN_HEIGHT-30-40-40-20-20-20)];
    }
    return _tableHeaderView;
}

- (void)layoutSubViews{
    [self.view addSubview:self.mailBoxTable];
}

- (void)JGScrollToBottom:(BOOL)animated {
    CGSize contentSize = self.mailBoxTable.contentSize;
    CGFloat height = CGRectGetHeight(self.mailBoxTable.bounds);
    CGFloat edgeBottom = self.mailBoxTable.contentInset.bottom;
    if (contentSize.height > (height - edgeBottom)) {
        CGFloat deltaOffsetY = contentSize.height - height + edgeBottom;
        CGPoint offset = self.mailBoxTable.contentOffset;
        offset.y = deltaOffsetY;
        [self.mailBoxTable setContentOffset:offset animated:animated];
    }
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
