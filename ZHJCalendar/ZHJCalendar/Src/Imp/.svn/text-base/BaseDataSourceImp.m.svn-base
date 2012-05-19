//
//  BaseDataSourceImp.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "BaseDataSourceImp.h"
#import "BaseCalendarGridView.h"
#import "BaseCalendarDisableGridView.h"
#import "BaseCalendarViewHeaderView.h"
#import "BaseCalendarViewFooterView.h"
#import "CalMonth.h"

@implementation BaseDataSourceImp
- (CalendarGridView*) calendarView:(CalendarView*)calendarView calendarGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(CalDay*)calDay
{
    static NSString *identifier = @"BaseCalendarGridView";
    CalendarGridView *gridView = [calendarView dequeueCalendarGridViewWithIdentifier:identifier];
    if (!gridView) 
    {
        gridView = [BaseCalendarGridView viewFromNibWithIdentifier:identifier];        
    }
    return gridView;
}
- (CalendarGridView*) calendarView:(CalendarView*)calendarView calendarDisableGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(CalDay*)calDay
{
    static NSString *identifier = @"BaseCalendarDisableGridView";    
    CalendarGridView *gridView = [calendarView dequeueCalendarGridViewWithIdentifier:identifier];
    if (!gridView) 
    {
        gridView = [BaseCalendarDisableGridView viewFromNibWithIdentifier:identifier];
    }
    return gridView;
}
- (CalendarViewHeaderView*) headerViewForCalendarView:(CalendarView*)calendarView
{
    return [BaseCalendarViewHeaderView viewFromNib];
}
- (CalendarViewFooterView*) footerViewForCalendarView:(CalendarView*)calendarView
{
    return [BaseCalendarViewFooterView viewFromNib];
}
//- (NSArray*) weekTitlesForCalendarView:(CalendarView*)calendarView
//{
//    return [NSArray arrayWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
//}
//- (NSString*) calendarView:(CalendarView*)calendarView titleForMonth:(CalMonth*)calMonth
//{
//    NSString *title = [NSString stringWithFormat:@"%d年-%d月", [calMonth getYear], [calMonth getMonth]];
//    return title;
//}
@end
