//
//  BaseCalendarDisableGridView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "BaseCalendarDisableGridView.h"

@interface BaseCalendarDisableGridView()

@property (retain, nonatomic) IBOutlet UIButton *gridButton;

@end

@implementation BaseCalendarDisableGridView

@synthesize gridButton;

- (IBAction)onGridButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarGridViewDidSelectGrid:)]) 
    {
//        [_delegate calendarGridViewDidSelectGrid:self];
    }
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.gridButton.userInteractionEnabled = NO;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (void) select
{
    self.selected = TRUE;
    self.gridButton.selected = TRUE;    
}
- (void) deselect
{
    self.selected = FALSE;
    self.gridButton.selected = FALSE;
}
- (void) layoutSubviews
{
    NSString *title = [NSString stringWithFormat:@"%d", [_calDay getDay]];
    [self.gridButton setTitle:title forState:UIControlStateNormal];
    self.gridButton.selected = self.selected;    
}
- (void)dealloc 
{
    [gridButton release];
    [super dealloc];
}
@end
