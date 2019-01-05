//
//  PrecautionsViewController.m
//  aletter
//
//  Created by xujin on 2018/9/6.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "PrecautionsViewController.h"
#import "MOLHead.h"
#import "PrecautionsCell.h"
#import "MOLSheildModel.h"
#import "MOLSheildRequest.h"
#import "PrecautionsView.h"
#import "MOLSheildGroupModel.h"

@interface PrecautionsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UILabel *tipLable;

//++++++++++++++++++++++++++/
@property (nonatomic,strong)UIButton *addButton;
@property (nonatomic,strong)UILabel *tipCountLable;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong)PrecautionsView *precautionsView;


@end

@implementation PrecautionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self layoutNav];
    [self lauoutUI];
    [self networkData];
}

- (void)networkData{
    MOLSheildRequest *r = [[MOLSheildRequest alloc] initRequest_sheildListWithParameter:nil];
    __weak __typeof(self) weakSelf = self;
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        MOLSheildGroupModel *groupM = (MOLSheildGroupModel *)responseModel;
        weakSelf.listArr =[NSMutableArray new];
        [weakSelf.listArr addObjectsFromArray:groupM.resBody];
        
        if (weakSelf.listArr.count>0) {
          weakSelf.dataArr  =(NSMutableArray *)[[weakSelf.listArr reverseObjectEnumerator] allObjects];
            [weakSelf.tableView reloadData];
        }
        
        if (self.dataArr.count<=0) {
            [self.tipLable setHidden:NO];
        }else{
            [self.tipLable setHidden:YES];
        }
        
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

- (void)initData{
    self.dataArr =NSMutableArray.new;
    
}

#pragma mark -
#pragma mark 导航条设置
- (void)layoutNav{
    [self basevc_setCenterTitle:@"设置屏蔽内容" titleColor:HEX_COLOR(0xffffff)];
}

#pragma mark -
#pragma mark UI设置
- (void)lauoutUI{
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.precautionsView];
    
    [self.precautionsView setFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH,56)];
    [self.precautionsView precautionsView:0 count:self.listArr.count];
    
    
    
    [self.view addSubview:self.tipLable];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    __weak __typeof(self) weakSelf = self;
    [self.tipLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(28);
        make.bottom.mas_equalTo(weakSelf.view).offset(-60);
    }];
}

#pragma mark-
#pragma mark 懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 56, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT-56) style:UITableViewStylePlain];
        
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UILabel *)tipLable{
    if (!_tipLable) {
        _tipLable =UILabel.new;
        [_tipLable setText: @"空空如也"];
        [_tipLable setTextAlignment:NSTextAlignmentCenter];
        [_tipLable setTextColor:HEX_COLOR_ALPHA(0xffffff, 0.5)];
        [_tipLable setFont:MOL_MEDIUM_FONT(20)];
    }
    return _tipLable;
}

- (PrecautionsView *)precautionsView{
    if (!_precautionsView) {
        _precautionsView =PrecautionsView.new;
        __weak __typeof(self) weakSelf = self;
        _precautionsView.precautionsAddWordBlock = ^(MOLSheildModel *model) {
          //添加屏蔽内容
            [weakSelf addWordNetworkData: model];
        };
    }
    return _precautionsView;
}



#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const kPrecautionsCellReuseIdentifier = @"kPrecautionsCellReuseIdentifier";
    PrecautionsCell *cell = [tableView dequeueReusableCellWithIdentifier:kPrecautionsCellReuseIdentifier];
    if (!cell) {
        cell =[[PrecautionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPrecautionsCellReuseIdentifier];
    }
    
    MOLSheildModel *model =[MOLSheildModel new];
    if (self.dataArr.count>indexPath.row) {
        model =self.dataArr[indexPath.row];
    }
    [cell precautionsCell:model indexPath:indexPath];
    
    __weak __typeof(self) weakSelf = self;
    cell.cellDeleteBlock = ^(NSIndexPath *index, MOLSheildModel *dto) {
        NSLog(@"删除事件触发");

        if (weakSelf.dataArr.count>index.row) {
            [weakSelf deleteNetwork:index model:dto];
        }
    };
   
    return cell;
}

#pragma mark-
#pragma mark 网络删除事件
- (void)deleteNetwork:(NSIndexPath *)index model:(MOLSheildModel *)dto{
    
    NSMutableDictionary *dic =[NSMutableDictionary new];
    if (dto) {
        [dic setObject:dto.name?dto.name:@"" forKey:@"name"];
    }else{
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [[[MOLSheildRequest alloc] initRequest_deleteSheildWithParameter:dic] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        if (code == MOL_SUCCESS_REQUEST) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf.dataArr removeObjectAtIndex:index.row];
                [weakSelf.precautionsView precautionsViewShowTopEvent:weakSelf.dataArr.count];
                if (weakSelf.dataArr.count<=0) {
                    [weakSelf.tipLable setHidden:NO];
                }else{
                    [weakSelf.tipLable setHidden:YES];
                }
                [weakSelf.tableView reloadData];
            });
            
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

#pragma mark-
#pragma mark 网络添加事件
- (void)addWordNetworkData:(MOLSheildModel *)model{
    NSMutableDictionary *dic =[NSMutableDictionary new];
    if (model && model.name && model.name.length>0) {
        [dic setObject:model.name forKey:@"name"];
    }else{
        return;
    }
    
    __block MOLSheildModel *dto;
    dto =model;
    __weak __typeof(self) weakSelf = self;
    [[[MOLSheildRequest alloc] initRequest_addSheildWithParameter:dic] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        if (code == MOL_SUCCESS_REQUEST) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                MOLSheildModel *model=dto;
                if (model&&model.name&&model.name.length>0) {
                    
                    [weakSelf.dataArr insertObject:model atIndex:0];
                    
                    [weakSelf.precautionsView precautionsViewShowTopEvent:weakSelf.dataArr.count];
                    if (weakSelf.dataArr.count<=0) {
                        [weakSelf.tipLable setHidden:NO];
                    }else{
                        [weakSelf.tipLable setHidden:YES];
                    }
                    [weakSelf.tableView reloadData];
                }
            });
            
        }else{
            [MOLToast toast_showWithWarning:YES title:message];
        }
        
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging");
    [self.precautionsView precautionsViewShowTopEvent:self.dataArr.count];
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
