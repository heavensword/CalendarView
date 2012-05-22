//
//  CalMonth.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NUMBER_OF_DAYS_IN_WEEK  7

@class CalDay;

@interface CalMonth : NSObject
{
@private
//    NSUInteger  _month;
    struct
    {
        unsigned int month : 4;
        unsigned int year : 15;
        unsigned int numberOfDays : 16; 
    } mon;
    CalDay         *_today;
    NSMutableArray *daysOfMonth;
}

@property (nonatomic, readonly) NSUInteger days;;

- (id) initWithDate:(NSDate*)date;
- (id) initWithMonth:(NSUInteger)month;
- (id) initWithMonth:(NSUInteger)month year:(NSUInteger)year;
- (id) initWithMonth:(NSUInteger)month year:(NSUInteger)year day:(NSUInteger)day;

- (CalDay*) calDayAtDay:(NSUInteger) day;
- (CalDay*) firstDay;
- (CalDay*) lastDay;
- (NSUInteger) getYear;
- (NSUInteger) getMonth;
- (CalMonth*) nextMonth;
- (CalMonth*) previousMonth;
@end
