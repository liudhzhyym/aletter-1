//
//  MOLChooseBoxModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/1.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLChooseBoxModel.h"
#import "MOLHead.h"

@implementation MOLChooseBoxModel

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        if (self.modelType == MOLChooseBoxModelType_leftText) {
            // 计算文字高度
            CGSize maxS = CGSizeMake(MOL_SCREEN_WIDTH - 20 - 14 - 5 - 28, MAXFLOAT);
            CGFloat h = [self.leftTitle boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)} context:nil].size.height;
            
            _cellHeight = h + 15;
        }else if (self.modelType == MOLChooseBoxModelType_middleImage){
            _cellHeight = 105 + 20;
        }else if (self.modelType == MOLChooseBoxModelType_middleEnvelopeImage){
            _cellHeight = 105 + 20;
        }
        else if (self.modelType == MOLChooseBoxModelType_rightText){
            // 计算文字高度
            CGSize maxS = CGSizeMake(MOL_SCREEN_WIDTH - 20 - 14 - 28, MAXFLOAT);
            CGFloat h = [self.rightTitle boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)} context:nil].size.height;
            
            _cellHeight = h + 15;
        }else if (self.modelType == MOLChooseBoxModelType_rightTextView){
            _cellHeight = 30 + 15;
        }else if (self.modelType == MOLChooseBoxModelType_rightChooseButton){
           _cellHeight = 40;
        }else if (self.modelType == MOLChooseBoxModelType_card){
            CGSize maxS = CGSizeMake(MOL_SCREEN_WIDTH - 40 - 34 - 20, MAXFLOAT);
            CGFloat h = [self.cardModel.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : MOL_LIGHT_FONT(14)} context:nil].size.height;
            _cellHeight = self.cardModel.cardType == 2 ? (h+55+15) : (120 + 15);
        }else{
            _cellHeight = 0;
        }
    }
    return _cellHeight;
}

@end
