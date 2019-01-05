//
//  MOLMineViewController.m
//  aletter
//
//  Created by moli-2017 on 2018/8/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMineViewController.h"
#import "MOLMineMessageViewController.h"
#import "MOLMineMailViewController.h"
#import "MOLMineSettingViewController.h"
#import "MOLHead.h"

@interface MOLMineViewController () <JAHorizontalPageViewDelegate,SPPageMenuDelegate>
@property (nonatomic, strong) JAHorizontalPageView *pageView;
@property (nonatomic, strong) UIImageView *headView;

@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIButton *refreshButton;

@property (nonatomic, weak) MOLMineMessageViewController *msgVc;
@property (nonatomic, weak) MOLMineMailViewController *mailVc;

@property (nonatomic, assign) BOOL hiddenStatus;
@end

@implementation MOLMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.pageView reloadPage];
    
    if ([MOLSwitchManager shareSwitchManager].normalStatus) {
        [self.pageMenu setItems:@[@"消息",@"信件",@"设置"] selectedItemIndex:self.index];
    }else{
        [self.pageMenu setItems:@[@"设置"] selectedItemIndex:self.index];
    }
    self.pageMenu.bridgeScrollView = (UIScrollView *)_pageView.horizontalCollectionView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hiddenStatus = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.hiddenStatus = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - 页面delegate
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    if ([MOLSwitchManager shareSwitchManager].normalStatus) {
        return 3;
    }else{
        return 1;
    }
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if ([MOLSwitchManager shareSwitchManager].normalStatus) {
        if (index == 0) {
            MOLMineMessageViewController *vc = [[MOLMineMessageViewController alloc] init];
            _msgVc = vc;
            vc.view.backgroundColor = [UIColor clearColor];
            [self addChildViewController:vc];
            return (UIScrollView *)vc.messageView.tableView;
        }else if (index == 1){
            MOLMineMailViewController *vc = [[MOLMineMailViewController alloc] init];
            _mailVc = vc;
            vc.view.backgroundColor = [UIColor clearColor];
            [self addChildViewController:vc];
            return (UIScrollView *)vc.mineMailView.collectionView;
        }else{
            MOLMineSettingViewController *vc = [[MOLMineSettingViewController alloc] init];
            vc.view.backgroundColor = [UIColor clearColor];
            [self addChildViewController:vc];
            return (UIScrollView *)vc.tableView;
        }
    }else{
        MOLMineSettingViewController *vc = [[MOLMineSettingViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        [self addChildViewController:vc];
        return (UIScrollView *)vc.tableView;
    }
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    return self.headView;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return 100 + MOL_StatusBarHeight;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView   // 控制在什么地方悬停
{
    return 100 + MOL_StatusBarHeight;
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{
    if (offset > 0) {
        self.headView.image = [UIImage imageNamed:@"mine_back_top"];
    }else{
        self.headView.image = nil;
    }
}

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    [_pageView scrollToIndex:toIndex];
}

#pragma mark - 按钮的点击
- (void)button_clickCloseButton
{
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

- (void)button_clickRefreshButton
{
    if (self.pageMenu.selectedItemIndex == 0) {   // 刷新消息
        [self.msgVc request_mineMsg];
    }else if (self.pageMenu.selectedItemIndex == 1){ // 刷新信封
        [self.mailVc request_mineMail];
    }
}


#pragma mark - 懒加载
- (UIView *)headView
{
    if (_headView == nil) {
        
        _headView = [[UIImageView alloc] init];
        _headView.userInteractionEnabled = YES;
        _headView.width = MOL_SCREEN_WIDTH;
        _headView.height = 100 + MOL_StatusBarHeight;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton = closeButton;
        closeButton.width = 32;
        closeButton.height = 30;
        closeButton.centerX = _headView.width * 0.5;
        closeButton.y = MOL_StatusBarHeight - 10;
        closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
        [closeButton setImage:[UIImage imageNamed:@"mine_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(button_clickCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:closeButton];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshButton = refreshButton;
        refreshButton.width = 18;
        refreshButton.height = 18;
        refreshButton.y = MOL_StatusBarHeight;
        refreshButton.right = _headView.width - 20;
        closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
        [refreshButton setImage:[UIImage imageNamed:@"mine_refresh"] forState:UIControlStateNormal];
        [refreshButton addTarget:self action:@selector(button_clickRefreshButton) forControlEvents:UIControlEventTouchUpInside];
        [_headView addSubview:refreshButton];
        
        SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(MOL_SCREEN_ADAPTER(50), closeButton.bottom + 30, MOL_SCREEN_WIDTH - MOL_SCREEN_ADAPTER(100), 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        _pageMenu = pageMenu;
        _pageMenu.backgroundColor = [UIColor clearColor];
        _pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollEqualWidths;
        _pageMenu.itemTitleFont = MOL_MEDIUM_FONT(18);
        _pageMenu.selectedItemTitleColor = HEX_COLOR(0xffffff);
        _pageMenu.unSelectedItemTitleColor = HEX_COLOR_ALPHA(0xffffff, 0.4);
        _pageMenu.trackerWidth = 5;
        [_pageMenu setTrackerHeight:5 cornerRadius:2.5];
        _pageMenu.tracker.backgroundColor = HEX_COLOR(0xffffff);
        _pageMenu.needTextColorGradients = NO;
        _pageMenu.dividingLine.hidden = YES;
        _pageMenu.closeTrackerFollowingMode = YES;
        _pageMenu.itemPadding = 20;
        _pageMenu.delegate = self;
        [_headView addSubview:_pageMenu];
    }
    
    return _headView;
}
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        _pageView.needHeadGestures = NO;
        [self.view addSubview:_pageView];
    }
    return _pageView;
}

- (BOOL)prefersStatusBarHidden {
    return self.hiddenStatus;
}

@end
