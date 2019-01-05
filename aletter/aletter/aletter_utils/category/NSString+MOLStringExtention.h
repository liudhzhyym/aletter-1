//
//  NSString+MOLStringExtention.h
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MOLStringExtention)

/// MD5
+ (NSString*)mol_md5WithSalt:(NSString *)string;
+ (NSString*)mol_md5WithOrigin:(NSString *)string;
- (NSString*)mol_md5WithSalt;
- (NSString*)mol_md5WithOrigin;

/// 时间戳
/// 时间戳转时间
+ (NSInteger)mol_timeWithTimeString:(NSString *)timeString formatter:(NSString *)formatterString;
/// 时间转时间戳
+ (NSString *)mol_timeWithTimestampString:(NSString *)timestampString formatter:(NSString *)formatterString;
/// 获取当前时间戳
+ (NSInteger)mol_timeWithCurrentTimestamp;
/// 获取当前时间
+ (NSString *)mol_timeWithCurrentTimeString;
/// 获取消息列表展示时间
+ (NSString *)moli_timeGetMessageTimeWithTimestamp:(NSString *)timestamp;
/// 互动通知的时间展示
+ (NSString *)moli_interactTimeGetMessageTimeWithTimestamp:(NSString *)timestamp;

/// 文件目录
+ (NSString *)mol_homePath;
+ (NSString *)mol_appPath;
+ (NSString *)mol_documentPath;
+ (NSString *)mol_libraryPreferencesPath;
+ (NSString *)mol_libraryCachePath;
+ (NSString *)mol_tmpPath;

/// 创建MOLPLIST文件夹下的文件
+ (NSString *)mol_creatFileWithFileName:(NSString *)name;
/// 创建NSDocument的文件
+ (NSString *)mol_creatNSDocumentFileWithFileName:(NSString *)name;

/// 判断MOLPLIST下文件是否存在
+ (BOOL)mol_fileExistWithName:(NSString *)fileName;
@end
