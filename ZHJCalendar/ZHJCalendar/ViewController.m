//
//  ViewController.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ViewController.h"
#import "BaseDataSourceImp.h"

@interface ViewController ()

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
- (void) calendarViewDidSelectDay:(CalendarView*)calendarView calDay:(CalDay*)calDay
{
    ITTDINFO(@"selected day %@", calDay);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _calendarView = [CalendarView viewFromNib];
    BaseDataSourceImp *dataSource = [[BaseDataSourceImp alloc] init];
//    _calendarView.date = [NSDate dateWithTimeIntervalSinceNow:2*24*60*60];    
    _calendarView.dataSource = dataSource;
    _calendarView.delegate = self;
    _calendarView.frame = CGRectMake(8, 40, 309, 301);
    [_calendarView showInView:self.view];
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
