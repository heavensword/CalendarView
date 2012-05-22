//
//  BaseCalendarViewFooterView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-13.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "BaseCalendarViewFooterView.h"
#import "CalendarView.h"

@implementation BaseCalendarViewFooterView

- (IBAction) onPeriodButtonTouched:(id)sender
{
    if (_selectedButton) 
    {
        _selectedButton.userInteractionEnabled = TRUE;
        _selectedButton.selected = FALSE;
    }
    _selectedButton = sender;
    _selectedButton.selected = TRUE;
    _selectedButton.userInteractionEnabled = FALSE;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewFooterViewDidSelectPeriod:periodType:)]) 
    {
        [_delegate calendarViewFooterViewDidSelectPeriod:self periodType:_selectedButton.tag];
    }
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];

//    PeriodType tag = PeriodTypeAllDay;
//    for (UIView *subview in self.subviews) 
//    {
//        if ([subview isKindOfClass:[UIButton class]]) 
//        {
//            UIButton *button = (UIButton*)subview;
//            button.tag = tag++;
//            [button addTarget:self action:@selector(onPeriodButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
//            if (!_selectedButton) 
//            {
//                _selectedButton = button;
//            }
//        }
//    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
