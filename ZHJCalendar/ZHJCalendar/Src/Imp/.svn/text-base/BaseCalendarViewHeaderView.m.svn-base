//
//  BaseCalendarViewHeaderView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "BaseCalendarViewHeaderView.h"

@interface BaseCalendarViewHeaderView()

@property (retain, nonatomic) IBOutlet UILabel *monthLabel;

@end


@implementation BaseCalendarViewHeaderView
@synthesize monthLabel;

- (IBAction)onCancelChoseDateButtonTouched:(id)sender 
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewDidCancel:)])
    {
        [_delegate calendarViewHeaderViewDidCancel:self];
    }
}
- (IBAction)onChoseDateButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewDidSelection:)])
    {
        [_delegate calendarViewHeaderViewDidSelection:self];
    }    
}
- (IBAction)onPreviousMonthButtonTouched:(id)sender 
{    
    if (_delegate && [_delegate respondsToSelector:
                      @selector(calendarViewHeaderViewPreviousMonth:)]) 
    {
        [_delegate calendarViewHeaderViewPreviousMonth:self];
    }    
}
- (IBAction)onNextMonthButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewNextMonth:)]) 
    {
        [_delegate calendarViewHeaderViewNextMonth:self];
    }
}
- (void) setTitle:(NSString *)title
{
    if (_title)
    {
        [_title release];
        _title = nil;        
    }
    _title = [title retain];
    self.monthLabel.text = title;
}
- (void)dealloc 
{
    [monthLabel release];
    [super dealloc];
}
@end
