//
//  NSDate+NSDateUtils.h
//  Jingoal
//
//  Created by kaiser on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateUtils)

/*!
 *	@brief	按照需求，在消息列表中显示的时间
 */
- (NSString *)dateWithString;

- (NSDate *) dateByAddingMinutes: (NSInteger) timeInterval;

- (NSString *)applicationLocalizedDescriptionWithDateFormatTemplate:(NSString *)dateformatTemplate ;

@end

