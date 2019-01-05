//
//  MOLMailboxTableViewProxy.m
//  aletter
//
//  Created by xiaolong li on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "MOLMailboxTableViewProxy.h"
#import "MOLChooseBoxModel.h"
#import "MOLChooseBoxCell.h"
@interface MOLMailboxTableViewProxy()<MOLChooseBoxCellDelegate>

@end

@implementation MOLMailboxTableViewProxy

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOLChooseBoxModel *model = self.dataArr[indexPath.row];
    
    static NSString * const cellID =@"MOLChooseBoxCellID";
    MOLChooseBoxCell *cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cellID) {
        cell =[[MOLChooseBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
    }
    cell.delegate=self;
    
    cell.boxModel = model;
    if (model.modelType == MOLChooseBoxModelType_rightChooseButton) {
        if ([model.buttonTitle isEqualToString:self.titleArr.firstObject]) {
            [cell chooseBoxCell_drawRadius:2 backgroundColor:nil];
        }else if ([model.buttonTitle isEqualToString:self.titleArr.lastObject]){
            [cell chooseBoxCell_drawRadius:1 backgroundColor:nil];
        }else{
            [cell chooseBoxCell_drawRadius:0 backgroundColor:nil];
        }
    }else{
        [cell chooseBoxCell_drawRadius:0 backgroundColor:nil];
    }
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MOLChooseBoxModel *model = self.dataArr[indexPath.row];
    return model.cellHeight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MOLChooseBoxModel *model = self.dataArr[indexPath.row];

    if (model.modelType == MOLChooseBoxModelType_rightChooseButton) {
        if ([model.buttonTitle isEqualToString:self.titleArr.firstObject]) {
            //写邮件事件
            self.MailboxTableViewProxyWriteBlock(indexPath);
           
        }else if ([model.buttonTitle isEqualToString:self.titleArr[1]]) {
            //手滑事件
            self.mailboxTableViewProxyCloseBlock(indexPath);
           
        }
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        MOLChooseBoxCell *boxCell = (MOLChooseBoxCell *)cell;
        [boxCell chooseBoxCell_keyBoardShow:YES];
    });
}


#pragma mark - MOLChooseBoxCellDelegate
- (void)chooseBoxCell_shouldReturnWithName:(NSString *)name   // 点击键盘完成
{
    self.mailboxTableViewProxyUserNameBlock(name);
    
}


@end
