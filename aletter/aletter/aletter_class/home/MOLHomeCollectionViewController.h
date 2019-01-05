//
//  MOLHomeCollectionViewController.h
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLBaseViewController.h"

@interface MOLHomeCollectionViewController : MOLBaseViewController
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger catogeryId;  // 类别
@property (nonatomic, strong) NSString *catogeryName;  // 类别名
@end
