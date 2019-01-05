//
//  MOLSearchSchoolViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/9/27.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLSearchSchoolViewController.h"
#import "MOLHead.h"
#import "MOLLoginRequest.h"
#import "MOLSureSchoolViewController.h"

@interface MOLSearchSchoolViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, weak) UILabel *noDataLabel;
@property (nonatomic, strong) MOLLoginRequest *searchRequest;

@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation MOLSearchSchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSourceArray = [NSMutableArray array];
    [self setNavigation];
    
    [self setupSearchSchoolViewControllerUI];
    
    @weakify(self);
    self.tableView.mj_footer = [MOLDIYRefreshFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self request_getSchoolList:YES];
    }];
    
    [self request_getSchoolList:NO];
}

- (void)request_getSchoolList:(BOOL)isMore
{
    self.tableView.mj_footer.hidden = NO;
    if (!isMore) {
        self.currentPage = 1;
        [self.dataSourceArray removeAllObjects];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(50);
    
    MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_schoolListWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        [self.tableView.mj_footer endRefreshing];
        MOLSchoolGroupModel *group = (MOLSchoolGroupModel *)responseModel;
        
        [self.dataSourceArray addObjectsFromArray:group.resBody];
        
        if (group.resBody) {
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
    } failure:^(__kindof MOLBaseNetRequest *request) {
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)request_getSchool:(NSString *)keyWord
{
    self.tableView.mj_footer.hidden = YES;
    if (self.searchRequest) {
        [self.searchRequest stop];
    }
    
    [self.dataSourceArray removeAllObjects];
    [self.tableView reloadData];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = keyWord;
    
    MOLLoginRequest *r = [[MOLLoginRequest alloc] initRequest_searchSchoolWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        self.searchRequest = nil;
        
        MOLSchoolGroupModel *group = (MOLSchoolGroupModel *)responseModel;

        [self.dataSourceArray addObjectsFromArray:group.resBody];
        
        [self.tableView reloadData];
    } failure:^(__kindof MOLBaseNetRequest *request) {
        self.searchRequest = nil;
    }];
    
    self.searchRequest = r;
}

#pragma mark - 按钮点击
- (void)button_searchSchool:(UITextField *)textField
{
    if (textField.text.length) {
        [self request_getSchool:textField.text];
    }else{
        [self.dataSourceArray removeAllObjects];
        [self.tableView reloadData];
        
        [self request_getSchoolList:NO];
    }
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLSchoolModel *model = self.dataSourceArray[indexPath.row];
    
    if (self.enterType) {
        
        MOLUserModel *user = [MOLUserManagerInstance user_getUserInfo];
        MOLSureSchoolViewController *vc = [[MOLSureSchoolViewController alloc] init];
        vc.school = model.name;
        vc.changeNum = user.schoolNum;
        dispatch_async(dispatch_get_main_queue(), ^{
           [self presentViewController:vc animated:YES completion:nil];
        });
        
    }else{
        if (self.schoolBlock) {
            self.schoolBlock(model.name);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSourceArray.count) {
        self.noDataLabel.hidden = YES;
    }else{
        self.noDataLabel.hidden = NO;
    }
    
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MOLSchoolModel *model = self.dataSourceArray[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell_id"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell_id"];
        cell.textLabel.textColor = HEX_COLOR(0xffffff);
        cell.textLabel.font = MOL_LIGHT_FONT(14);
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = model.name;
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - 导航条
- (void)setNavigation
{
    [self basevc_setCenterTitle:@"添加学校" titleColor:HEX_COLOR(0xffffff)];
}

#pragma mark - UI
- (void)setupSearchSchoolViewControllerUI
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_school_search"]];
    imageView.contentMode = UIViewContentModeCenter;
    _imageView = imageView;
    imageView.width = 35;
    imageView.height = 30;
    
    UITextField *textField = [[UITextField alloc] init];
    _textField = textField;
    textField.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:@"搜索学校" attributes:@{NSForegroundColorAttributeName : HEX_COLOR_ALPHA(0xE6E7EC, 0.5)}];
    [textField setAttributedPlaceholder:att];
    textField.font = MOL_REGULAR_FONT(13);
    textField.textColor = HEX_COLOR(0xffffff);
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [[textField valueForKey:@"_clearButton"] setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
    [textField addTarget:self action:@selector(button_searchSchool:) forControlEvents:UIControlEventEditingChanged];
    textField.layer.cornerRadius = 5;
    textField.clipsToBounds = YES;
    [self.view addSubview:textField];
    
    UILabel *noDataLabel = [[UILabel alloc] init];
    _noDataLabel = noDataLabel;
    noDataLabel.text = @"未找到相关学校";
    noDataLabel.textColor = HEX_COLOR_ALPHA(0xffffff, 0.6);
    noDataLabel.font = MOL_MEDIUM_FONT(14);
    [self.view addSubview:noDataLabel];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
}

- (void)calculatorSearchSchoolViewControllerFrame
{
    self.textField.width = MOL_SCREEN_WIDTH - 30;
    self.textField.height = 30;
    self.textField.x = 15;
    self.textField.y = 0;
    self.textField.leftView = self.imageView;
    
    [self.noDataLabel sizeToFit];
    self.noDataLabel.centerX = self.view.width * 0.5;
    self.noDataLabel.y = self.textField.bottom + 50;
    
    self.tableView.frame = self.view.bounds;
    self.tableView.y = self.textField.bottom;
    self.tableView.height = self.view.height - self.tableView.y;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorSearchSchoolViewControllerFrame];
}
@end
