//
//  EDAudioMessageModel.m
//  aletter
//
//  Created by moli-2017 on 2018/8/28.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "EDAudioMessageModel.h"
#import "EDAudioCell.h"

@implementation EDAudioMessageModel

- (instancetype)initWithAudio:(NSString *)audio time:(NSString *)time
{
    if (self = [super init]) {
        self.content = audio;
//        self.chatType = 2;
//        self.time = time;
    }
    return self;
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        
        CGFloat h = 22;
        CGFloat w = 140;
        
        _cellHeight = h + 2 * kEDBubbleVerticalEdgeSpacing + 2 * kEDCellVerticalEdgeSpacing;
        
        if (self.fromType == MessageFromType_me) {
            self.bubbleImageFrame = CGRectMake(MOL_SCREEN_WIDTH - (w + 2 * kEDBubbleHorizontalEdgeSpacing) - kEDCellHorizontalEdgeSpacing, 10, w + 2 * kEDBubbleHorizontalEdgeSpacing, _cellHeight - 2 * kEDCellVerticalEdgeSpacing);
            
            self.audioViewFrame = CGRectMake(kEDBubbleHorizontalEdgeSpacing, kEDBubbleVerticalEdgeSpacing, w, h);
            self.audioAnimateFrame = CGRectMake(w - 11, (h - 11) * 0.5, 11, 15);
            self.audioTimeFrame = CGRectMake(0, 0, 22, 22);
            self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x - 10 - 2 * kEDCellVerticalEdgeSpacing, self.bubbleImageFrame.origin.y + (self.bubbleImageFrame.size.height * 0.5 - 20 * 0.5), 20, 20);
            self.redPointFrame = CGRectMake(self.bubbleImageFrame.origin.x - 6, self.bubbleImageFrame.origin.y, 6, 6);
        }else{
            self.bubbleImageFrame = CGRectMake(kEDCellHorizontalEdgeSpacing, 10, w + 2 * kEDBubbleHorizontalEdgeSpacing, _cellHeight - 2 * kEDCellVerticalEdgeSpacing);
            
            self.audioViewFrame = CGRectMake(kEDBubbleHorizontalEdgeSpacing, kEDBubbleVerticalEdgeSpacing, w, h);
            self.audioAnimateFrame = CGRectMake(0, (h - 11) * 0.5, 11, 15);
            self.audioTimeFrame = CGRectMake(w - 22, 0, 22, 22);
            self.redPointFrame = CGRectMake(self.bubbleImageFrame.origin.x + self.bubbleImageFrame.size.width, self.bubbleImageFrame.origin.y, 6, 6);
            self.sendingIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x + self.bubbleImageFrame.size.width + 10, self.bubbleImageFrame.origin.y + (self.bubbleImageFrame.size.height * 0.5 - 20 * 0.5), 20, 20);
        }
        
    }
    
    return _cellHeight;
}

- (EDBaseChatCell *)getCellWithReuseIdentifier:(NSString *)identifier
{
    return [[EDAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
}

- (CGFloat)getCellHeight
{
    return self.cellHeight;
}
@end
