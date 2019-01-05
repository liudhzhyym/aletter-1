//
//  MOLPhotosCell.m
//  aletter
//
//  Created by xiaolong li on 2018/8/14.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLPhotosCell.h"

@implementation MOLPhotosCell


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView.layer setMasksToBounds:YES];
        [_imageView.layer setCornerRadius:5];
        [self.contentView addSubview:_imageView];
        self.clipsToBounds = YES;
        
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"关闭添加的图片或声音"] forState:UIControlStateNormal];
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 5);
        [self.contentView addSubview:_deleteBtn];
    }
    
    return self;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _deleteBtn.frame = CGRectMake(self.frame.size.width - 19, 0, 19, 19);
}


@end
