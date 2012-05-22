//
//  DateUtil.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil
+ (BOOL) isLeapYear:(NSInteger)year
{
    NSAssert(!(year < 1), @"invalid year number");
    BOOL leap = FALSE;
    if ((0 == (year % 400))) 
    {
        leap = TRUE;
    }
    else if((0 == (year%4)) && (0 != (year % 100)))
    {
        leap = TRUE;
    }
    return leap;
}
+ (NSInteger) numberOfDaysInMonth:(NSInteger)month
{
    return [DateUtil numberOfDaysInMonth:month year:[DateUtil getCurrentYear]];
}
+ (NSInteger) getCurrentYear
{
    time_t ct = time(NULL);
	struct tm *dt = localtime(&ct);
	int year = dt->tm_year + 1900;
    return year;
}
+ (NSInteger) getCurrentMonth
{
    time_t ct = time(NULL);
	struct tm *dt = localtime(&ct);
	int month = dt->tm_mon + 1;
    return month;
}
+ (NSInteger) getCurrentDay
{
    time_t ct = time(NULL);
	struct tm *dt = localtime(&ct);
	int day = dt->tm_mday;
    return day;    
}
+ (NSInteger) getMonthWithDate:(NSDate*)date
{
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
    NSInteger month = comps.month;
    return month;
}
+ (NSInteger) getDayWithDate:(NSDate*)date
{
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];
    NSInteger day = comps.day;
    return day;
}
+ (NSInteger) numberOfDaysInMonth:(NSInteger)month year:(NSInteger) year
{
    NSAssert(!(month < 1||month > 12), @"invalid month number");    
    NSAssert(!(year < 1), @"invalid year number");    
    month = month - 1;
    static int daysOfMonth[12] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    NSInteger days = daysOfMonth[month];
    /*
     * feb
     */
    if (month == 1) 
    {        
        if ([DateUtil isLeapYear:year]) 
        {            
            days = 29;
        }
        else
        {            
            days = 28;            
        }
    }
    return days;
}
+ (NSDate*) dateSinceNowWithInterval:(NSInteger)dayInterval
{
    return [NSDate dateWithTimeIntervalSinceNow:dayInterval*24*60*60];
}
@end
