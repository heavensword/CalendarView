//
//  CalendarDataSource.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CalendarViewHeaderView;
@class CalendarViewFooterView;
@class CalendarGridView;
@class CalendarView;
@class CalMonth;
@class CalDay;

@protocol CalendarViewDataSource <NSObject>
@optional
- (NSArray*) weekTitlesForCalendarView:(CalendarView*)calendarView;
//- (NSString*) calendarView:(CalendarView*)calendarView titleForCellAtRow:(NSInteger)row column:(NSInteger)column calDay:(CalDay*)calDay;

- (NSString*) calendarView:(CalendarView*)calendarView titleForMonth:(CalMonth*)calMonth;

- (CalendarGridView*) calendarView:(CalendarView*)calendarView calendarGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(CalDay*)calDay;

- (CalendarGridView*) calendarView:(CalendarView*)calendarView calendarDisableGridViewForRow:(NSInteger)row column:(NSInteger)column calDay:(CalDay*)calDay;

- (CalendarViewHeaderView*) headerViewForCalendarView:(CalendarView*)calendarView;
- (CalendarViewFooterView*) footerViewForCalendarView:(CalendarView*)calendarView;

@end
