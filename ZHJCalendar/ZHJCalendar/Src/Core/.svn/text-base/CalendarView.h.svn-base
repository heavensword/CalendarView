//
//  CalendarView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"
#import "CalendarViewDataSource.h"
#import "CalendarViewDelegate.h"
#import "CalendarGridView.h"
#import "CalendarViewHeaderView.h"
#import "CalendarViewFooterView.h"

#define CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW 251
#define CALENDAR_VIEW_HEIGHT                     301

@class CalDay;
@class CalMonth;

@interface CalendarView : UIView<CalendarGridViewDelegate, 
CalendarViewHeaderViewDelegate, CalendarViewFooterViewDelegate>
{
    BOOL                    _firstLayout;
    PeriodType              _selectedPeriod;    
    
    CGSize                  _gridSize;
    
    NSDate                  *_date;
    NSDate                  *_minimumDate;
    NSDate                  *_maximumDate;
    
    CalDay                  *_minimumDay;    
    CalDay                  *_maximumDay;     
    CalDay                  *_selectedDay;
    
    CalMonth                *_calMonth;
    
    CalendarViewHeaderView  *_calendarHeaderView;  
    CalendarViewFooterView  *_calendarFooterView;
    
    CalendarGridView        *_selectedGridView;
    
    UIView                  *_parentView;
    
    NSMutableArray          *_gridViewsArray;
    NSMutableArray          *_monthGridViewsArray;
    NSMutableDictionary     *_recyledGridSetDic;    
    
    id<CalendarViewDataSource>  _dataSource;
    id<CalendarViewDelegate>    _delegate;
}
@property (nonatomic, retain) id<CalendarViewDataSource> dataSource;
@property (nonatomic, assign) id<CalendarViewDelegate>   delegate;

@property (nonatomic, assign) PeriodType selectedPeriod;    
@property (nonatomic, assign) BOOL appear;
@property (nonatomic, assign) CGSize gridSize;

/*
 * default date is current date
 */
@property (nonatomic, retain) NSDate *date;              
/*
 * The minimum date that a date calendar view can show
 */
@property (nonatomic, retain) NSDate *minimumDate;          
/*
 * The maximum date that a date calendar view can show
 */
@property (nonatomic, retain) NSDate *maximumDate;
/*
 * The selected calyday on calendar view
 */
@property (retain, nonatomic, readonly) CalDay *selectedDay;
/*
 * The selected date on calendar view
 */
@property (retain, nonatomic, readonly) NSDate *selectedDate;

- (void) nextMonth;
- (void) previousMonth;
- (void) showInView:(UIView*)view;
- (void) hide;

- (CalendarGridView*) dequeueCalendarGridViewWithIdentifier:(NSString*)identifier;

+ (id) viewFromNib;

@end
