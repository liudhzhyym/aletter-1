//
//  MOLCommentModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/11.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLCommentModel.h"
#import "MOLHead.h"

@implementation MOLCommentModel

- (CGFloat)commentCellHeight
{
    if (_commentCellHeight == 0) {
        
        // 名字+间距
        _commentCellHeight = 20 + 10;
        
        if (self.audioUrl.length) {
            _commentCellHeight = _commentCellHeight + 40 + 10;  // 音频+间距
        }
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.content];
        text.yy_font = MOL_LIGHT_FONT(14);
        CGSize introSize = CGSizeMake(MOL_SCREEN_WIDTH-40-34-35, CGFLOAT_MAX);
        YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:introSize text:text];
        CGFloat textH = layout.textBoundingSize.height;
        
        _commentCellHeight = _commentCellHeight + textH + 12 + 20 + 30;// 内容+间距+底部条+底部间距
    }
    
    return _commentCellHeight;
}
@end
