//
//  NSString+MOLStringExtention.m
//  aletter
//
//  Created by moli-2017 on 2018/7/31.
//  Copyright © 2018年 aletter-2018. All rights reserved.
//

#import "NSString+MOLStringExtention.h"
#import <CommonCrypto/CommonDigest.h>

#define Md5SecretString      @"2CB3147B-D93C-964B-47AE-EEE448C84E3C"

@implementation NSString (MOLStringExtention)

+ (NSString*)mol_md5WithSalt:(NSString *)string
{
    NSString *md5Source = [string stringByAppendingFormat:@"%@",Md5SecretString];
    
    const char *cStr = [md5Source UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString * str = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    return [str lowercaseString];
}
-(NSString*)mol_md5WithSalt
{
    NSString *md5Source = [self stringByAppendingFormat:@"%@",Md5SecretString];
    
    const char *cStr = [md5Source UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString * str = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    return [str lowercaseString];
    
}

+ (NSString*)mol_md5WithOrigin:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString * str = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    
    return [str lowercaseString];
}
- (NSString *)mol_md5WithOrigin
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString * str = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    
    return [str lowercaseString];
}

// 时间戳
// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
+ (NSString *)mol_timeWithTimestampString:(NSString *)timestampString formatter:(NSString *)formatterString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formatterString];
    
    NSTimeInterval time=[timestampString doubleValue] / 1000; //传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    
    NSString *currentDateStr = [formatter stringFromDate:detailDate];
    return currentDateStr;
}


+ (NSInteger)mol_timeWithTimeString:(NSString *)timeString formatter:(NSString *)formatterString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formatterString]; //(@"YYYY-MM-dd hh:mm:ss")设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:timeString];
    
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return timeSp;
}

+ (NSInteger)mol_timeWithCurrentTimestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    return timeSp;
}

+ (NSString *)mol_timeWithCurrentTimeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间
    NSString *currentDateStr = [formatter stringFromDate:datenow];
    return currentDateStr;
}

// 消息的时间展示
+ (NSString *)moli_timeGetMessageTimeWithTimestamp:(NSString *)timestamp
{
    double beTime = [timestamp doubleValue]/1000.0;
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    NSString * timeStr = [df stringFromDate:beDate];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime < 60 || beTime <= 0){
        //小于一分钟
        distanceStr = @"刚刚";
    }else if (distanceTime <60*60){
        //时间小于一个小时
        distanceStr = [NSString stringWithFormat:@"%ld分钟前",(long)distanceTime/60];
    }else if(distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue]){
        //时间小于一天
        distanceStr = [NSString stringWithFormat:@"今天 %@",timeStr];
    }else if(distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]){
        if ([nowDay integerValue] - [lastDay integerValue] ==1 ||
            ([lastDay integerValue] - [nowDay integerValue] > 10 &&
             [nowDay integerValue] == 1)){
            distanceStr = [NSString stringWithFormat:@"昨天 %@",timeStr];
        }else{
            distanceStr = [NSString stringWithFormat:@"前天 %@",timeStr];
        }
    }else if(distanceTime<24*60*60*3 && [nowDay integerValue] != [lastDay integerValue]){
        if ([nowDay integerValue] - [lastDay integerValue] ==2 ||
            ([lastDay integerValue] - [nowDay integerValue] > 10 &&
             [nowDay integerValue] == 1)){
            distanceStr = [NSString stringWithFormat:@"前天 %@",timeStr];
        }else{
            [df setDateFormat:@"yyyy.MM.dd"];
            distanceStr = [df stringFromDate:beDate];
        }
    }else if(distanceTime <24*60*60*365){
        [df setDateFormat:@"yyyy.MM.dd"];
        distanceStr = [df stringFromDate:beDate];
    }else{
        [df setDateFormat:@"yyyy.MM.dd"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

// 互动通知的时间展示
+ (NSString *)moli_interactTimeGetMessageTimeWithTimestamp:(NSString *)timestamp
{
    double beTime = [timestamp doubleValue]/1000.0;
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime < 60 || beTime <= 0){
        //小于一分钟
        distanceStr = @"1分钟前";
    }else if (distanceTime <60*60){
        //时间小于一个小时
        distanceStr = [NSString stringWithFormat:@"%ld分钟前",(long)distanceTime/60];
    }else if(distanceTime <24*60*60 /*&& [nowDay integerValue] == [lastDay integerValue]*/){
        //时间小于一天
        distanceStr = [NSString stringWithFormat:@"%ld小时前",(long)distanceTime/60/60];
    }else if(distanceTime <24*60*60*30){
        distanceStr = [NSString stringWithFormat:@"%ld天前",(long)distanceTime/60/60/24];
    }else{
        [df setDateFormat:@"yyyy.MM.dd"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

// 文件目录
+ (NSString *)mol_homePath
{
    return NSHomeDirectory();
}

+ (NSString *)mol_appPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)mol_documentPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)mol_libraryPreferencesPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preferences"];
}

+ (NSString *)mol_libraryCachePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
}

+ (NSString *)mol_tmpPath
{
    return [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
}

/// 创建NSDocument的文件
+ (NSString *)mol_creatNSDocumentFileWithFileName:(NSString *)name
{
    name = [NSString stringWithFormat:@"%@.plist",name];
    NSString *cach_path = [self mol_documentPath];
    NSString *filename = [cach_path stringByAppendingPathComponent:name];
    
    return filename;
}

///// 判断MOLPLIST下文件是否存在
//+ (BOOL)mol_fileExistNSDocumentWithName:(NSString *)fileName
//{
//    fileName = [NSString stringWithFormat:@"%@.plist",fileName];
//    NSString *cach_path = [self mol_documentPath];
//    NSFileManager* fm = [NSFileManager defaultManager];
//    NSString *filename = [cach_path stringByAppendingPathComponent:fileName];
//    if ([fm fileExistsAtPath:filename]) {
//        return YES;
//    }
//    return NO;
//}

/// 创建MOLPLIST文件夹下的文件
+ (NSString *)mol_creatFileWithFileName:(NSString *)name
{
    name = [NSString stringWithFormat:@"%@.plist",name];
    NSString *cach_path = [self mol_libraryCachePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString *dic_path = [cach_path stringByAppendingPathComponent:@"MOLPLIST"];
    if (![fm fileExistsAtPath:dic_path]) {
        [fm createDirectoryAtPath:dic_path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filename = [dic_path stringByAppendingPathComponent:name];
    
    return filename;
}

/// 判断MOLPLIST下文件是否存在
+ (BOOL)mol_fileExistWithName:(NSString *)fileName
{
    fileName = [NSString stringWithFormat:@"%@.plist",fileName];
    NSString *cach_path = [self mol_libraryCachePath];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString *dic_path = [cach_path stringByAppendingPathComponent:@"MOLPLIST"];
    NSString *filename = [dic_path stringByAppendingPathComponent:fileName];
    if ([fm fileExistsAtPath:filename]) {
        return YES;
    }
    return NO;
}
@end
