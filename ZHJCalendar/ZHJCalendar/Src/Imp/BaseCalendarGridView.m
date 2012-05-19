//
//  BaseCalendarGridView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "BaseCalendarGridView.h"

@interface BaseCalendarGridView()

@property (retain, nonatomic) IBOutlet UIButton *gridButton;

@end

@implementation BaseCalendarGridView

@synthesize gridButton;

- (IBAction)onGridButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarGridViewDidSelectGrid:)]) 
    {
        [_delegate calendarGridViewDidSelectGrid:self];
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
    self.gridButton.userInteractionEnabled = FALSE;
}
- (void) deselect
{
    self.selected = FALSE;
    self.gridButton.selected = FALSE;
    self.gridButton.userInteractionEnabled = TRUE;    
}
- (void) layoutSubviews
{
    NSString *title = [NSString stringWithFormat:@"%d", [_calDay getDay]];
    self.gridButton.selected = self.selected;      
    self.gridButton.userInteractionEnabled = !self.selected;        
    self.gridButton.userInteractionEnabled = _selectedEanable;      
    if (_selectedEanable) 
    {
        [self.gridButton setTitleColor:RGBCOLOR(122, 119, 122) forState:UIControlStateNormal];   
    }
    else 
    {
        [self.gridButton setTitleColor:RGBCOLOR(233, 232, 231) forState:UIControlStateNormal];             
    }
    [self.gridButton setTitle:title forState:UIControlStateNormal];
}
- (void)dealloc {
    [gridButton release];
    [super dealloc];
}
@end
