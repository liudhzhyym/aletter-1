//
//  MOLMailboxViewController.m
//  aletter
//
//  Created by xiaolong li on 2018/8/8.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//
//  投掷邮筒类，处理投掷信件业务功能

#import "MOLMailboxViewController.h"
#import "MOLMailboxTableViewProxy.h"
#import "MOLPostViewController.h"
#import "MOLChooseBoxModel.h"
#import "MOLChooseBoxCell.h"
#import "TZLocationManager.h"
#import "MOLHead.h"
#import "MOLMailModel.h"
#import "MOLPostRequest.h"
#import <UIImageView+WebCache.h>

@interface MOLMailboxViewController ()
{
    MOLChooseBoxModel *left_model;
}
@property(nonatomic,strong) UITableView *mailBoxTable;
@property(nonatomic,strong) UIButton *closeButton;
@property(nonatomic,strong) UIImageView *mailboxBgImgView;
@property(nonatomic,strong) UIImageView *mailBgImgView;
//@property(nonatomic,strong) UIImageView *mailImgView;
@property(nonatomic,strong) UILabel *mailLalbe;
@property(nonatomic,strong) MOLMailboxTableViewProxy *mailboxTableViewProxy;
@property(nonatomic,strong) UIView *tableHeaderView;
@property(nonatomic,strong) NSMutableArray *dataSourceArr;
@property(nonatomic,strong) NSMutableArray *titleArr;
@property (strong, nonatomic) CLLocation *location;

@end

@implementation MOLMailboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self layoutSubViews];
    
     if(self.mailModel && self.mailModel.channelId.length>0 && self.mailModel.question.length>0){
         
         [self reloadUI];
         
     }else{
         [self getChannelNetData];
     }
    
}

- (void)reloadUI{
    __weak __typeof(self) weakSelf = self;
    [self initData];
    self.mailboxTableViewProxy.dataArr=weakSelf.dataSourceArr;
    self.mailboxTableViewProxy.titleArr=weakSelf.titleArr;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url =[NSURL URLWithString:weakSelf.mailModel.image?weakSelf.mailModel.image:@""];
        [self.mailBgImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"卡通邮票默认"] options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                NSLog(@"下载失败%@",error);
            }
        }];
        
        [self.mailLalbe setText: [NSString stringWithFormat:@"%@",weakSelf.mailModel.channelName?weakSelf.mailModel.channelName:@"标签"]];
        [self.mailBoxTable reloadData];
    });
}

#pragma mark
#pragma mark
- (void)getChannelNetData{
    
    // 发送请求
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (self.mailModel && self.mailModel.channelId.length>0) {
        
        [dic setObject:[NSString stringWithFormat:@"%@",self.mailModel.channelId?self.mailModel.channelId:@""] forKey:@"channelId"];
        
        __weak __typeof(self) weakSelf = self;
        [[[MOLPostRequest alloc] initRequest_channelDetailsWithParameter:dic parameterId:self.mailModel.channelId] baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
            
            if (code == MOL_SUCCESS_REQUEST) {
                
                if(!weakSelf.mailModel){
                    weakSelf.mailModel =[MOLMailModel new];
                }
                
                if (responseModel) {
                    weakSelf.mailModel = (MOLMailModel *)responseModel;
                    [weakSelf reloadUI];
                }
                
            }else{
                [MOLToast toast_showWithWarning:YES title:message];
            }
            
        } failure:^(__kindof MOLBaseNetRequest *request) {
            
        }];
    
    }
}

- (void)initData{
    
    self.dataSourceArr =[NSMutableArray new];
    self.titleArr =[NSMutableArray new];
    
    if(self.mailModel && self.mailModel.channelId.length>0 && self.mailModel.question.length>0){ //表示数据模型存在
    
        NSArray *array = [self.mailModel.question componentsSeparatedByString:@"#"];
        if (array.count>1) {
            [self.titleArr addObject:array[1]];
            [self.titleArr addObject:@"我手滑了"];
           
            MOLChooseBoxModel *left_model = [[MOLChooseBoxModel alloc] init];
            left_model.modelType = MOLChooseBoxModelType_leftText;
            left_model.leftImageString = INTITLE_LEFT_Highlight;
            left_model.leftTitle =array[0];
            left_model.leftHighLight = YES;
            [self.dataSourceArr addObject:left_model];
        }
        else{
            [self.titleArr addObject:@"我手滑了"];
        }
        
    }
    
    for (NSInteger i = 0; i < self.titleArr.count; i++) {
        MOLChooseBoxModel *model = [[MOLChooseBoxModel alloc] init];
        model.modelType = MOLChooseBoxModelType_rightChooseButton;
        model.buttonTitle = self.titleArr[i];
        [self.dataSourceArr addObject:model];
    }
    
     

}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    __weak __typeof(self) weakSelf = self;
    [self.mailboxBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view).offset(MOL_SCREEN_ADAPTER(100));
        make.width.mas_equalTo(MOL_SCREEN_ADAPTER(200));
        make.height.mas_equalTo(MOL_SCREEN_ADAPTER(396));
        make.left.mas_equalTo((weakSelf.view.width-MOL_SCREEN_ADAPTER(200))/2.0);
    }];
    
    [self.mailBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(weakSelf.mailboxBgImgView).offset(MOL_SCREEN_ADAPTER(222));
        make.left.mas_equalTo(weakSelf.mailboxBgImgView).offset(62);
        make.right.mas_equalTo(weakSelf.mailboxBgImgView).offset(-58);
        make.height.mas_equalTo(MOL_SCREEN_ADAPTER(103));
    }];
    
//    [self.mailImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(weakSelf.mailBgImgView).offset(7);
//        make.left.mas_equalTo(weakSelf.mailBgImgView).offset(5);
//        make.right.mas_equalTo(weakSelf.mailBgImgView).offset(-5);
//        make.height.mas_equalTo(70);
//    }];
    
    [self.mailLalbe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.mailBgImgView.mas_bottom);
        make.left.mas_equalTo(weakSelf.mailBgImgView).offset(5);
        make.right.mas_equalTo(weakSelf.mailBgImgView).offset(-5);
        make.height.mas_equalTo(26);
    }];
    
    [self.mailBoxTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.view);
        make.width.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(weakSelf.view);
    }];
    
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.view).offset(20);
        make.top.mas_equalTo(weakSelf.view).offset(34);
        make.width.height.mas_equalTo(CGSizeMake(24, 24));
    }];
    
//    [self.tableHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.mailBoxTable);
//        make.height.mas_equalTo(self.mailBoxTable).offset(300);
//        make.width.mas_equalTo(self.mailBoxTable);
//    }];
    
    
}

- (void)layoutSubViews{
    [self.view addSubview:self.mailboxBgImgView];
    [self.mailboxBgImgView addSubview:self.mailBgImgView];
//    [self.mailBgImgView addSubview:self.mailImgView];
    [self.mailBgImgView addSubview:self.mailLalbe];
    [self.view addSubview:self.mailBoxTable];
    [self.view addSubview:self.closeButton];
}


#pragma mark-
#pragma mark 懒加载对象
- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundColor: [UIColor clearColor]];
        [_closeButton setImage:[UIImage imageNamed:@"common_close"] forState:(UIControlStateNormal)];
        [_closeButton addTarget:self action:@selector(closeControllerEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView *)mailboxBgImgView{
    if (!_mailboxBgImgView) {
        _mailboxBgImgView=[UIImageView new];
        [_mailboxBgImgView setImage: [UIImage imageNamed:@"邮筒"]];
    }
    return _mailboxBgImgView;
}

- (UIImageView *)mailBgImgView{
    if (!_mailBgImgView) {
        _mailBgImgView=[UIImageView new];
        [_mailBgImgView setImage:[UIImage imageNamed:@"home_stamp_1"]];
    }
    return _mailBgImgView;
}

//- (UIImageView *)mailImgView{
//    if (!_mailImgView) {
//        _mailImgView=[UIImageView new];
//        [_mailImgView setImage:[UIImage imageNamed:@"home_stamp_1"]];
//    }
//    return _mailImgView;
//}

- (UILabel *)mailLalbe{
    if (!_mailLalbe) {
        _mailLalbe =[UILabel new];
        _mailLalbe.text = @"标签";
        _mailLalbe.textColor = HEX_COLOR(0x3A384D);
        _mailLalbe.font = MOL_MEDIUM_FONT(14);
        _mailLalbe.textAlignment = NSTextAlignmentCenter;
    }
    return _mailLalbe;
}

- (UITableView *)mailBoxTable{
    if (!_mailBoxTable) {
        _mailBoxTable =[[UITableView alloc] initWithFrame:CGRectMake(0, 0,MOL_SCREEN_WIDTH,MOL_SCREEN_HEIGHT) style:UITableViewStylePlain];
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
        
        //__block BOOL isExist =NO;
        _mailboxTableViewProxy.MailboxTableViewProxyWriteBlock = ^(NSIndexPath *indexPath) {
            [MobClick event:@"_c_put_into_envelope"];
            if (![[NSUserDefaults standardUserDefaults] objectForKey: @"isFirstLocation"]) { //定位是否授权过，授权过获取定位信息，否则直接跳转到下个控制器
                MOLPostViewController *postViewController =[MOLPostViewController new];
                postViewController.location= weakSelf.location;
                postViewController.mailModel =weakSelf.mailModel;
                [weakSelf.navigationController pushViewController:postViewController animated:YES];
                
            }else{
                
                CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
                if (kCLAuthorizationStatusNotDetermined == status) {
                    
                    [[TZLocationManager manager] startLocation];
                    
                }else {
                    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
                        weakSelf.location = [locations firstObject];
                        
                        
                            MOLPostViewController *postViewController =[MOLPostViewController new];
                            postViewController.location= weakSelf.location;
                            postViewController.mailModel =weakSelf.mailModel;
                            [weakSelf.navigationController pushViewController:postViewController animated:YES];

                    } failureBlock:^(NSError *error) {
                        
                        weakSelf.location = nil;
                        
                            MOLPostViewController *postViewController =[MOLPostViewController new];
                            postViewController.location= weakSelf.location;
                            postViewController.mailModel =weakSelf.mailModel;
                            [weakSelf.navigationController pushViewController:postViewController animated:YES];
                    }];
                }
            }
        };
        
        _mailboxTableViewProxy.mailboxTableViewProxyCloseBlock = ^(NSIndexPath *indexPath) {
            [weakSelf closeControllerEvent];
        };

    }
    return _mailboxTableViewProxy;
}

- (UIView *)tableHeaderView{
    if (!_tableHeaderView) {
        _tableHeaderView =[UIView new];
        [_tableHeaderView setBackgroundColor: [UIColor clearColor]];
        
        
        
        CGFloat waveHeigh = 20;
        if (iPhone4) {
            waveHeigh = 140;
        }else if (iPhoneX){
            waveHeigh =44+20;
        }
        
        [_tableHeaderView setFrame:CGRectMake(0, 0, MOL_SCREEN_WIDTH,  MOL_SCALEHeight(MOL_SCREEN_HEIGHT-30-40-40-20-20-waveHeigh))];
    }
    return _tableHeaderView;
}

- (void)closeControllerEvent:(UIButton *)sender{
    [self closeControllerEvent];
}

- (void)closeControllerEvent{
    [self.navigationController popViewControllerAnimated:YES];
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
