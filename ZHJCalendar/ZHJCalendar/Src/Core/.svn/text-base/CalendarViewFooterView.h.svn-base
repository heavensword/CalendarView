//
//  CalendarViewFooterView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enum.h"

@protocol CalendarViewFooterViewDelegate;

@interface CalendarViewFooterView : UIView
{
    UIButton *_selectedButton;   
    id<CalendarViewFooterViewDelegate> _delegate;
}

@property (nonatomic, assign) id<CalendarViewFooterViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIButton *selectedButton;

+ (CalendarViewFooterView*) viewFromNib;

@end

@protocol CalendarViewFooterViewDelegate <NSObject>
@optional
- (void) calendarViewFooterViewDidSelectPeriod:(CalendarViewFooterView*)footerView periodType:(PeriodType)type;
@end

