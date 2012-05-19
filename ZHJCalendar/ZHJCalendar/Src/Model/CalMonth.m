//
//  CalMonth.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "CalMonth.h"
#import "DateUtil.h"
#import "CalDay.h"

#define FIRST_MONTH_OF_YEAR  1
#define LAST_MONTH_OF_YEAR  12

@interface CalMonth()
- (void) caculateMonth;
@end

@implementation CalMonth

@synthesize days;

- (void) caculateMonth
{    
    mon.numberOfDays = [DateUtil numberOfDaysInMonth:[_today getMonth] year:[_today getYear]];
    mon.year = [_today getYear];
    mon.month = [_today getMonth];    
    daysOfMonth = [[NSMutableArray alloc] init];
    for (NSInteger day = 1; day <= mon.numberOfDays; day++)
    {
        CalDay *calDay = [[CalDay alloc] initWithYear:mon.year month:mon.month day:day];
        [daysOfMonth addObject:calDay];
        [calDay release];
    }
}
- (CalMonth*) nextMonth
{
    NSUInteger year = mon.year;
    NSUInteger month = mon.month + 1;
    NSUInteger day = 1;
    if (month > LAST_MONTH_OF_YEAR) 
    {
        year++;
        month = 1;
    }
    CalMonth *calMonth = [[CalMonth alloc] initWithMonth:month year:year day:day];
    return [calMonth autorelease];
}
- (CalMonth*) previousMonth
{
    NSUInteger year = mon.year;
    NSUInteger month = mon.month - 1;
    NSUInteger day = 1;
    if (month < FIRST_MONTH_OF_YEAR) 
    {
        year--;
        month = 12;
    }
    CalMonth *calMonth = [[CalMonth alloc] initWithMonth:month year:year day:day];
    return [calMonth autorelease];    
}
- (id) initWithMonth:(NSUInteger)month
{
    self = [super init];
    if (self)
    {
        _today = [[CalDay alloc] initWithYear:[DateUtil getCurrentYear] month:month day:1];
        [self caculateMonth];                
    }
    return self;    
}
- (id) initWithMonth:(NSUInteger)month year:(NSUInteger)year
{
    self = [super init];
    if (self)
    {
        _today = [[CalDay alloc] initWithYear:year month:month day:1];
        [self caculateMonth];                
    }
    return self;
}
- (id) initWithDate:(NSDate*)d
{
    self = [super init];
    if (self)
    {
        _today = [[CalDay alloc] initWithDate:d];
        [self caculateMonth];
    }
    return self;    
}
- (id) initWithMonth:(NSUInteger)month year:(NSUInteger)year day:(NSUInteger)day
{
    self = [super init];
    if (self)
    {
        _today = [[CalDay alloc] initWithYear:year month:month day:day];
        [self caculateMonth];        
    }
    return self;    
}
- (NSString*)description
{
    return [NSString stringWithFormat:@"year:%d month:%d number of days:%d", 
            mon.year, mon.month, mon.numberOfDays];
}
- (NSUInteger) days
{
    return mon.numberOfDays;
}
- (NSUInteger) getYear
{
    return mon.year;    
}
- (NSUInteger) getMonth
{
    return mon.month;
}
- (CalDay*) calDayAtDay:(NSUInteger) day
{
    NSInteger index = day - 1;
    NSAssert(!(index < 0||index > 31), @"invalid day index");
    return [daysOfMonth objectAtIndex:index];
}
- (CalDay*) firstDay
{
    return [daysOfMonth objectAtIndex:0];    
}
- (CalDay*) lastDay
{
    return [daysOfMonth objectAtIndex:mon.numberOfDays - 1];        
}
- (void) dealloc
{
    [daysOfMonth release];
    daysOfMonth = nil; 
    [super dealloc];
}
@end
