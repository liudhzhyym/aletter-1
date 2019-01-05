//
//  NSDate+NSDateUtils.m
//  Jingoal
//
//  Created by kaiser on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDateUtils.h"

#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)

@implementation NSDate (NSDateUtils)

- (NSDate *)gmt_dateAtMidnight {
  static NSDateFormatter *formatter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
  });

  NSString *formattedTime = [formatter stringFromDate:self];
  NSDate *date = [formatter dateFromString:formattedTime];

  return date;
}



- (NSString *)dateWithString {
	NSString *retVal = [self dateWithSecond:NO];
	
	return retVal;
}

- (NSString *)dateWithSecond:(BOOL)second {
  // 现在时间都以服务器时间为准
  NSTimeZone *zone = [NSTimeZone systemTimeZone];
  NSInteger interval = [zone secondsFromGMTForDate:[NSDate date]];
    
    // 服务器时间
  NSDate *currentServerSyncDate =[NSDate date];
  NSDate *dateAtMidnight = [currentServerSyncDate gmt_dateAtMidnight];
    
  NSDate *localDate = [self dateByAddingTimeInterval:interval];
  NSTimeInterval diff = [localDate timeIntervalSinceDate:dateAtMidnight];
  if (diff >= 0) {
    // 当天的不显示年-月
      return [self applicationLocalizedDescriptionWithDateStyle:NSDateFormatterShortStyle];
    
  } else if (diff > -(1 * TT_DAY)) {
    // 昨天的显示 昨天+小时
    NSString *string = nil;
    
      string = [self applicationLocalizedDescriptionWithDateStyle:NSDateFormatterShortStyle];
      
    return [NSString stringWithFormat:@"昨天 %@", string];
  } else {
    // 今天的年份
    int localCurrentYear = [[dateAtMidnight description] substringWithRange:NSMakeRange(0, 4)].intValue;
    // 待显示的年份
    int displayYear = [[self description] substringWithRange:NSMakeRange(0, 4)].intValue;

    // 是今年不需要显示年份
    if (localCurrentYear == displayYear) {
        return [self applicationLocalizedDescriptionWithDateFormatTemplate:@"dMMM hh:mm"];
    }
    // 不是今年的都需要显示年
    else {
      NSString *string = nil;
      
        string = [self applicationLocalizedDescriptionWithDateFormatTemplate:@"dMMMYYYY hh:mm"];
      return string;
    }
  }
}

- (NSString *)applicationLocalizedDescriptionWithDateFormatTemplate:(NSString *)dateformatTemplate {
    
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    formatter.dateFormat = dateformatTemplate;
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.locale =[NSLocale currentLocale];
    return [formatter stringFromDate:self];
}

- (NSString *)applicationLocalizedDescriptionWithDateStyle:(NSDateFormatterStyle)dstyle {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });
    formatter.timeStyle = dstyle;
    
   // formatter.locale =[NSLocale currentLocale];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    return [formatter stringFromDate:self];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) timeInterval
{
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    return newDate;
}


@end
