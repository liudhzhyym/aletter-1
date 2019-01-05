//
//  MOLBaseViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/7/30.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"
#import "MOLHead.h"
#import "MOLSpringTrasitionAnimation.h"
#import "MOLPostViewController.h"
#import "RecordVoiceViewController.h"
#import "LocationViewController.h"

@interface MOLBaseViewController ()
@property (nonatomic, weak) UIImageView *imageView;

// loading动画
@property (nonatomic, weak) UIImageView *loadingImageView;
// 网络请求失败view
@property (nonatomic, weak) UIImageView *errorImageView;
// 空白页面view
@property (nonatomic, weak) UIImageView *blankImageView;

@end

@implementation MOLBaseViewController

//- (void)loadView
//{
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.frame = CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT);
//    imageView.image = [UIImage imageNamed:@"home_backImage"];
//    imageView.userInteractionEnabled = YES;
//    self.view = imageView;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackImageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self base_setNavigationBar];
}

- (void)setBackImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    imageView.frame = CGRectMake(0, 0, MOL_SCREEN_WIDTH, MOL_SCREEN_HEIGHT);
    imageView.image = [UIImage imageNamed:@"home_backImage"];
    [self.view addSubview:imageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.needStar) {
        for (NSInteger i = 0; i < 12; i++) {
            [self setupStar:i*0.1];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    for (UIView *v in self.imageView.subviews) {
        [v.layer removeAllAnimations];
    }
     [self.imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)setupStar:(NSTimeInterval)delay
{
//    home_star
    //产生随机数【10，40)
    int a = (arc4random()%40);
    UIImageView * view = [[UIImageView alloc]initWithFrame:CGRectMake(arc4random()%((NSInteger)MOL_SCREEN_WIDTH), arc4random()%((NSInteger)MOL_SCREEN_HEIGHT), a, a)];
    view.image = [UIImage imageNamed:@"home_star"];
    view.alpha = 0.0;
    [self.imageView addSubview:view];
    
    [UIView animateWithDuration:1 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:3 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            if (finished) {
                [self setupStar:delay];
            }
        }];
    }];
}

#pragma mark - 设置导航条
- (void)base_setNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.childViewControllers.count > 1) {
        [self basevc_setNavLeftItemWithTitle:nil titleColor:nil];
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        if ([self.navigationController.visibleViewController isKindOfClass:[MOLPostViewController class]] || [self.navigationController.visibleViewController isKindOfClass:[RecordVoiceViewController class]] ||
            [self.navigationController.visibleViewController isKindOfClass:[LocationViewController class]]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
        else{
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }

    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)basevc_setNavLeftItemWithTitle:(NSString *)title titleColor:(UIColor *)color
{
    if (title.length) {
        UIBarButtonItem *backItem = [UIBarButtonItem mol_barButtonItemWithTitleName:title targat:self action:@selector(leftBackAction)];
        backItem.tintColor = color;
        self.navigationItem.leftBarButtonItem = backItem;
    }else{
        
        UIBarButtonItem *backItem = [UIBarButtonItem mol_barButtonItemWithImageName:@"back" highlightImageName:@"back" targat:self action:@selector(leftBackAction)];
        self.navigationItem.leftBarButtonItem = backItem;
    }
}

- (void)basevc_setCenterTitle:(NSString *)title titleColor:(UIColor *)color
{
    self.navigationItem.title = title;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:MOL_REGULAR_FONT(18)}];

}

- (void)leftBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [MOLSpringTrasitionAnimation new];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [MOLSpringTrasitionAnimation new];
}

- (BOOL)needStar
{
    return YES;
}

// 显示loading
- (void)basevc_showLoading
{
    [self.blankImageView removeFromSuperview];
    [self.errorImageView removeFromSuperview];
    [self.loadingImageView.layer removeAllAnimations];
    [self.loadingImageView removeFromSuperview];
    
    UIImageView *loadingImageView = [[UIImageView alloc] init];
    _loadingImageView = loadingImageView;
    loadingImageView.width = 18;
    loadingImageView.height = 18;
    loadingImageView.centerX = self.view.width * 0.5;
    loadingImageView.centerY = self.view.height * 0.5;
    loadingImageView.image = [UIImage imageNamed:@"mine_loading"];
    loadingImageView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:loadingImageView];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat: M_PI *2];
    animation.duration = 1;
    animation.autoreverses = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [loadingImageView.layer addAnimation:animation forKey:nil];
}
// 隐藏loading
- (void)basevc_hiddenLoading
{
    [self.loadingImageView removeFromSuperview];
}
// 展示空白页
- (void)basevc_showBlankPageWithY:(CGFloat)localY image:(NSString *)image title:(NSString *)title superView:(UIView *)view
{
    UIImageView *blankView = [[UIImageView alloc] init];
    _blankImageView = blankView;
    blankView.userInteractionEnabled = YES;
//    blankView.image = [UIImage imageNamed:@"home_backImage"];
    blankView.y = localY < 0 ? 0 : localY;
    blankView.width = view.width;
    blankView.height = view.height - fabs(localY);
    [view addSubview:blankView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    btn.width = blankView.width;
    btn.height = 250;
    btn.y = blankView.height - btn.height;
    [btn mol_setButtonImageTitleStyle:ButtonImageTitleStyleBottom padding:20];
    [blankView addSubview:btn];
}
// 网络请求失败
- (void)basevc_showErrorPageWithY:(CGFloat)localY select:(SEL)select superView:(UIView *)view
{
    UIImageView *errorView = [[UIImageView alloc] init];
    _errorImageView = errorView;
    errorView.userInteractionEnabled = YES;
//    errorView.image = [UIImage imageNamed:@"home_backImage"];
    errorView.y = localY;
    errorView.width = view.width;
    errorView.height = view.height - localY;
    [view addSubview:errorView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"点击刷新" forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"mine_refresh_faile"] forState:UIControlStateNormal];
    [btn addTarget:self action:select forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = MOL_REGULAR_FONT(10);
    [btn setTitleColor:HEX_COLOR_ALPHA(0xffffff, 0.7) forState:UIControlStateNormal];
    btn.width = 100;
    btn.height = 50;
    btn.centerX = errorView.width * 0.5;
    btn.centerY = errorView.height * 0.5;
    [btn mol_setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    [errorView addSubview:btn];
}
@end
