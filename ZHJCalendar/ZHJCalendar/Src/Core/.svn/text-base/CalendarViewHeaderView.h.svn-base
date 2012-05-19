//
//  CalendarViewHeaderView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CalendarViewHeaderViewDelegate;

@interface CalendarViewHeaderView : UIView
{
    NSString        *_title;
    id<CalendarViewHeaderViewDelegate> _delegate;
}

@property (nonatomic, retain) id<CalendarViewHeaderViewDelegate> delegate;

@property (nonatomic, retain) NSString *title;

+ (CalendarViewHeaderView*) viewFromNib;

@end

@protocol CalendarViewHeaderViewDelegate <NSObject>
@optional
- (void) calendarViewHeaderViewNextMonth:(CalendarViewHeaderView*)calendarHeaderView;
- (void) calendarViewHeaderViewPreviousMonth:(CalendarViewHeaderView*)calendarHeaderView;
- (void) calendarViewHeaderViewDidCancel:(CalendarViewHeaderView*)calendarHeaderView;
- (void) calendarViewHeaderViewDidSelection:(CalendarViewHeaderView*)calendarHeaderView;
@end
