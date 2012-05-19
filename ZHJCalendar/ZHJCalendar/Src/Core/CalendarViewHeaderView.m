//
//  CalendarViewHeaderView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "CalendarViewHeaderView.h"

@implementation CalendarViewHeaderView

@synthesize title = _title;
@synthesize delegate = _delegate;

- (void) dealloc
{
    _delegate = nil;
    [_title release];
    _title = nil;
    [super dealloc];
}
+ (CalendarViewHeaderView*) viewFromNib
{
    return [[[[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0] retain] autorelease];
}
@end
