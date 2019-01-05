//
//  MOLChooseBoxModel.h
//  aletter
//
//  Created by moli-2017 on 2018/8/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOLCardModel.h"

typedef NS_ENUM(NSUInteger, MOLChooseBoxModelType) {
    MOLChooseBoxModelType_leftText,      // 左边展示文字
    MOLChooseBoxModelType_middleImage,   // 中间展示图片 中间网络图片展示
    MOLChooseBoxModelType_rightText,     // 右边展示文字
    MOLChooseBoxModelType_rightTextView,    // 右边可输入文字（如：取名字）
    MOLChooseBoxModelType_rightChooseButton,   // 右边选择按钮（如：男，女）
    MOLChooseBoxModelType_card,   // 卡片
    MOLChooseBoxModelType_middleEnvelopeImage,       //中间信封展示
};

@interface MOLChooseBoxModel : NSObject

@property (nonatomic, assign) MOLChooseBoxModelType modelType;  // 类型

@property (nonatomic, strong) NSString *leftImageString;  // 左边图标
@property (nonatomic, strong) NSString *leftTitle;  // 左边文字
@property (nonatomic, strong) NSString *leftLevelTitle;  // 左边等级
@property (nonatomic, assign) BOOL leftHighLight;     // 左边是否高亮

@property (nonatomic, strong) NSString *middleImageString; // 中间
@property (nonatomic, strong) NSString *middleTitle; // 中间

@property (nonatomic, strong) NSString *rightImageString;  // 右边图标
@property (nonatomic, strong) NSString *rightTitle;  // 右边文字
@property (nonatomic, assign) BOOL rightHighLight;     // 右边是否高亮

@property (nonatomic, strong) NSString *buttonTitle;  // 按钮文字

@property (nonatomic, strong) MOLCardModel *cardModel;  // 卡片model

@property (nonatomic, assign) CGFloat cellHeight;  // 计算高度
@property (nonatomic, assign) BOOL middleEnvelopeImageHighLight; //新需求-邮票高亮
@end
