//
//  MOLMailboxTableViewProxy.h
//  aletter
//
//  Created by xiaolong li on 2018/8/9.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
typedef void(^MailboxTableViewProxyWriteBlock)(NSIndexPath *indexPath);
typedef void(^MailboxTableViewProxyCloseBlock)(NSIndexPath *indexPath);
typedef void(^MailboxTableViewProxyUserNameBlock)(NSString *userName);


@interface MOLMailboxTableViewProxy : NSObject<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) NSMutableArray *dataArr;
@property(nonatomic,strong) NSArray *titleArr;
@property (nonatomic, copy) MailboxTableViewProxyWriteBlock MailboxTableViewProxyWriteBlock;
@property (nonatomic, copy) MailboxTableViewProxyCloseBlock mailboxTableViewProxyCloseBlock;
@property (nonatomic, copy) MailboxTableViewProxyUserNameBlock mailboxTableViewProxyUserNameBlock;

@end
