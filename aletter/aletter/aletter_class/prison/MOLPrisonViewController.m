//
//  MOLPrisonViewController.m
//  aletter
//
//  Created by 徐天牧 on 2018/8/29.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPrisonViewController.h"
#import <Masonry.h>
#import "MOLConfig.h"
#import "MOLPrisonRequest.h"
#import "MOLPrisonModel.h"
#import "NSString+JACategory.h"

#import "MOLLightUserModel.h"
#import "EDChatViewController.h"
#import "MOLConstans.h"
#import "MOLMessageRequest.h"
#import "MOLHead.h"
//时间item
#define ITEM_HEIGHT 45 //item 高度
#define ITEM_WIDTH 23  //item 宽度
#define ITEM_DISTANCE 2//item 间距

@interface MOLPrisonViewController ()
@property(nonatomic,strong)UIImageView *topImageView;//头部
@property(nonatomic,strong)UIImageView *bottomImageView;//底部
@property(nonatomic,strong)UIView *timeView;//时间

@property(nonatomic,strong)UIButton *leaveButton;//申请释放

@property(nonatomic,strong)UILabel *titleLable;//打入地牢
@property(nonatomic,strong)UILabel *timeDetailLable;//距离刑满释放还有
@property(nonatomic,assign)BOOL isShowingPrison;
@end

@implementation MOLPrisonViewController

+ (instancetype)shared {
    static MOLPrisonViewController * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUIWith:nil];
    [self request_getPrisonData];
    
}
-(void)initUIWith:(NSString *)str{
    //顶部云彩
    _topImageView = [[UIImageView alloc] init];
    [self.view addSubview:_topImageView];
    [_topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@MOL_SCALEHeight(79));
    }];
    _topImageView.userInteractionEnabled = YES;
    _topImageView.image = [UIImage imageNamed:@"prison_topCloud"];
    
    
    //申请释放
    _leaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_topImageView addSubview:_leaveButton];
    _leaveButton.backgroundColor = HEX_COLOR(0x2D2439);
    [_leaveButton setTitleColor:RGB_COLOR(160, 160, 169) forState:UIControlStateNormal];
    _leaveButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _leaveButton.layer.cornerRadius = 5;
    _leaveButton.clipsToBounds = YES;
    [_leaveButton setTitle:@"申请释放" forState:UIControlStateNormal];
    [_leaveButton addTarget:self action:@selector(leaveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_leaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topImageView.mas_bottom).offset(-5);
        make.right.equalTo(self.topImageView.mas_right).offset(-10);
        make.height.equalTo(@26);
        make.width.equalTo(@80);
    }];
    
    
    //时间
    _timeView = [[UIView alloc] init];
    [self.view addSubview:_timeView];
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).mas_offset(@(-30));
        make.height.equalTo(@60);
        make.width.equalTo(@255);
    }];
    _timeView.backgroundColor = HEX_COLOR_ALPHA(0x1E1D27, 0.5);
    _timeView.layer.cornerRadius = 5;
    _timeView.clipsToBounds = YES;
    
    
    
    
   //时间item
    NSMutableArray *arry = [NSString convertToYMHWithTime:str];
    for (int i = 0 ; i < 10; i++) {
        NSInteger x = i * ITEM_WIDTH + (i+1) * ITEM_DISTANCE;
        NSInteger y = 7.5;
        // 圆角按钮
        UILabel *item = [[UILabel alloc] init];
        item.frame = CGRectMake(x, y, ITEM_WIDTH, ITEM_HEIGHT);
        item.textAlignment = NSTextAlignmentCenter;
        item.text = @"9";
        [_timeView addSubview:item];
        if (i==2 || i==6 || i==9 ) {
            item.textColor = HEX_COLOR(0x9B9B9B);
            item.font  =  [UIFont systemFontOfSize:14];
            item.text = @"年";
        }else{
            item.textColor = [UIColor whiteColor];
            item.font = [UIFont systemFontOfSize:32];
            item.backgroundColor = HEX_COLOR(0x1E1D27);
            item.layer.cornerRadius = 5;
            item.clipsToBounds = YES;
        }
        item.text = [NSString stringWithFormat:@"%@",arry[i]];
    }
    
    
    //距离刑满释放还有
    _timeDetailLable = [[UILabel alloc] init];
    [self.view addSubview:_timeDetailLable];
    _timeDetailLable.text = @"距离刑满释放还有";
    _timeDetailLable.font = [UIFont systemFontOfSize:14];
    _timeDetailLable.textColor = RGB_COLOR(160, 160, 169);
    [_timeDetailLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.timeView.mas_top).offset(-10);
        make.height.equalTo(@40);
    }];
    
    
    //做了坏事,打入地牢
    _titleLable = [[UILabel alloc] init];
    [self.view addSubview:_titleLable];
    _titleLable.text = @"做了坏事,打入地牢";
    _titleLable.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:24];
    _titleLable.textColor =[UIColor whiteColor];
    [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
       make.bottom.equalTo(self.timeDetailLable.mas_top).offset(-30) ;
        make.centerX.equalTo(self.view.mas_centerX);
        
    }];

    
    
    //底部监狱
    _bottomImageView = [[UIImageView alloc] init];
    [self.view addSubview:_bottomImageView];
    [_bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@MOL_SCALEHeight(274));
    }];
    _bottomImageView.image = [UIImage imageNamed:@"prison_tottomPrison"];
}

//离开事件
-(void)leaveButtonAction:(UIButton *)sender{
//    [self.view removeFromSuperview];
    
      @weakify(self);
    [self request_getChatId:^(NSString *chatId) {
        @strongify(self);
        MOLLightUserModel *user = [[MOLLightUserModel alloc] init];
        user.userId = MOL_OFFIC_USER;
        user.userName = @"申请解封";
        user.sex = 1;
        EDChatViewController *vc = [[EDChatViewController alloc] init];
        vc.toUser = user;
        vc.vcType = 2;
        if (chatId.length > 0) {
            vc.chatId = chatId;
        }
        UIViewController *currentVC = [self topViewController];
        [currentVC.navigationController pushViewController:vc animated:YES];
        
    }];
    
}
- (void)request_getChatId:(void(^)(NSString *chatId))successBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"storyId"] = @"-1";
    dic[@"userId"] = MOL_OFFIC_USER;
    MOLMessageRequest *r = [[MOLMessageRequest alloc] initRequest_checkChatWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        
        if (code == MOL_SUCCESS_REQUEST) {
            NSDictionary *dic = request.responseObject[@"resBody"];
            NSString *chatId = [dic mol_jsonString:@"chatId"];
            if (successBlock) {
                successBlock(chatId);
            }
        }
    } failure:^(__kindof MOLBaseNetRequest *request) {
        
    }];
}
+(void)show{
    
    
    MOLPrisonViewController *vc = [MOLPrisonViewController shared];
    if (vc.isShowingPrison) {
        return;
    }else{
        vc.isShowingPrison = YES;
    }
    
    MOLBaseNavigationController *nav = [[MOLBaseNavigationController alloc] initWithRootViewController:vc];
    UIApplication *app = [UIApplication sharedApplication];
    app.keyWindow.rootViewController = nav;
    [vc request_getPrisonData];
}

//网络请求
-(void)request_getPrisonData{
    MOLPrisonRequest  *r = [[MOLPrisonRequest alloc] initRequest_PrisonWithParameter:nil];
    [r baseNetwork_startRequestWithcompletion:^(__kindof MOLBaseNetRequest *request, MOLBaseModel *responseModel, NSInteger code, NSString *message) {
        MOLPrisonModel *model = (MOLPrisonModel *)responseModel;
        [self initUIWith:model.closureTime];
    } failure:^(__kindof MOLBaseNetRequest *request) {
        NSLog(@"封号时间请求失败");
    }];
}
- (void)showAnimation:(BOOL)isAnimation
{
    if (isAnimation) {
        //使用CAAnimationGroup
        //1.不透明度的变化
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @0.;
        opacityAnimation.toValue = @1.;
        opacityAnimation.duration = 0.5f;
        //2.大小的变化
        CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        //确定变化的情况
        CATransform3D startingScale = CATransform3DScale(self.view.layer.transform, 0, 0, 0);
        CATransform3D overshootScale = CATransform3DScale(self.view.layer.transform, 1.05, 1.05, 1.0);
        CATransform3D undershootScale = CATransform3DScale(self.view.layer.transform, 0.97, 0.97, 1.0);
        CATransform3D endingScale = self.view.layer.transform;
        
        NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
        //第二个动画的时间
        NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
        //添加到group里面
        NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
        //        时间累计
        [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
        //        可以为每个动画设置不同的动画方式
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        //        最后结束的情况
        [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
        [keyTimes addObject:@1.0f];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        //        赋值
        scaleAnimation.values = scaleValues;
        //        注意keytimes时间差
        scaleAnimation.keyTimes = keyTimes;
        scaleAnimation.timingFunctions = timingFunctions;
        //        CAAnimationGroup
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        animationGroup.duration = 0.6;
        [self.view.layer addAnimation:animationGroup forKey:nil];
    }
}

// 获取当前最上层的控制器
-(UIViewController *)topViewController {
    UIViewController *resultVC;
    
    
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

-(UIViewController *)_topViewController:(UIViewController *)vc{
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
@end
