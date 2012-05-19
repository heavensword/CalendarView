//
//  CalendarViewFooterView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "CalendarViewFooterView.h"

@implementation CalendarViewFooterView

@synthesize selectedButton = _selectedButton;
@synthesize delegate = _delegate;

- (void) dealloc
{
    _delegate = nil;
    [_selectedButton release];
    _selectedButton = nil;
    [super dealloc];
}
+ (CalendarViewFooterView*) viewFromNib
{
    return [[[[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0] retain] autorelease];
}
@end
