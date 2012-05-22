//
//  ViewController.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarView.h"


@interface ViewController : UIViewController<CalendarViewDelegate>
{
    CalendarView *_calendarView;
}
@end
