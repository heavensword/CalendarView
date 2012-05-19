//
//  CalendarGridView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalDay.h"

@protocol CalendarGridViewDelegate;

@interface CalendarGridView : UIView
{
    BOOL        _selected;
    BOOL        _selectedEanable;
    NSString    *_identifier;
    CalDay      *_calDay;
    
    id<CalendarGridViewDelegate> _delegate;
}

@property (nonatomic, assign) id<CalendarGridViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL selectedEanable;
/*
 * coming soon
 */
@property (nonatomic, assign) BOOL multipleSelection;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) CalDay *calDay;

- (void) select;
- (void) deselect;

+ (CalendarGridView*) viewFromNib; 

+ (CalendarGridView*) viewFromNibWithIdentifier:(NSString*)identifier; 

@end

@protocol CalendarGridViewDelegate <NSObject>
@optional
- (void) calendarGridViewDidSelectGrid:(CalendarGridView*) gridView;
@end
