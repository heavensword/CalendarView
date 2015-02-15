//
//  ViewController.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "ViewController.h"
#import "BaseDataSourceImp.h"

@interface ViewController ()
{
    BOOL    _viewIsFirstAppear;
}
@end

@implementation ViewController
- (IBAction)showCalendar:(id)sender 
{
    if (_calendarView.appear) 
    {
        [_calendarView hide];        
    }
    else
    {
        [_calendarView showInView:self.view];
    }
}
- (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*) formate 
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:formate];
	NSString *str = [formatter stringFromDate:date];
	[formatter release];
	return str;
}
- (void) calendarViewDidSelectDay:(CalendarView*)calendarView calDay:(CalDay*)calDay
{
    NSArray *selectedDates = calendarView.selectedDateArray;
    if (calendarView.allowsMultipleSelection) 
    {
        for (NSDate *date in selectedDates) 
        {
            NSLog(@"selected date %@", [self stringFromFomate:date formate:@"yyyy-MM-dd"]);
        }        
    }
    else
    {
        ITTDINFO(@"selected date %@", [self stringFromFomate:calendarView.selectedDate formate:@"yyyy-MM-dd"]);        
    }
}
- (NSDate *)theDateRelativeTodayWithInterval:(NSInteger)interval
{
    return [NSDate dateWithTimeIntervalSinceNow:(24*60*60*interval)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _viewIsFirstAppear = TRUE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_viewIsFirstAppear) {
        _viewIsFirstAppear = FALSE;
        NSLog(@"different ^ %d", FALSE^FALSE);
        CGFloat height = 301;
        CGFloat marginY = (CGRectGetHeight(self.view.bounds) - height) / 2;
        _calendarView = [CalendarView viewFromNib];
        BaseDataSourceImp *dataSource = [[BaseDataSourceImp alloc] init];
        _calendarView.dataSource = dataSource;
        _calendarView.delegate = self;
        _calendarView.frame = CGRectMake(8, marginY, 309, height);
        _calendarView.allowsMultipleSelection = TRUE;
//        _calendarView.maximumDate = [self theDateRelativeTodayWithInterval:20];
        [_calendarView showInView:self.view];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
