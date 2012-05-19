//
//  CalendarView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CalendarView.h"
#import "CalMonth.h"
#import "CalDay.h"
#import "CalendarGridView.h"
#import "CalendarViewHeaderView.h"

#define MARGIN_LEFT                              5
#define MARGIN_TOP                               9
#define PADDING_VERTICAL                         5
#define PADDING_HORIZONTAL                       3

@interface CalendarView()

@property (retain, nonatomic) CalMonth *calMonth;
@property (retain, nonatomic) IBOutlet UIView *weekHintView;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet UIScrollView *gridScrollView;

- (void) initParameters;
- (void) layoutGridCells;
- (void) recyleAllGridViews;
- (NSString*) findMonthDescription;
- (NSArray*) findWeekTitles;
- (CalendarViewHeaderView*) findHeaderView;
- (CalendarViewFooterView*) findFooterview;
- (CalendarGridView*) gridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay;
- (CalendarGridView*) disableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay;
- (CGRect) getFrameForRow:(NSUInteger)row column:(NSUInteger)column;

@end

@implementation CalendarView

@synthesize appear;
@synthesize selectedDate;
@synthesize selectedPeriod = _selectedPeriod;
@synthesize calMonth = _calMonth;
@synthesize weekHintView = _weekHintView;
@synthesize selectedDay = _selectedDay;
@synthesize date = _date;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize gridScrollView = _gridScrollView;

@synthesize gridSize;
- (void) initParameters
{
    _gridSize = CGSizeMake(39, 31);    
    _date = [[NSDate date] retain];    
    _calMonth = [[CalMonth alloc] initWithDate:_date];            
    _selectedDay = [[_calMonth firstDay] retain];
    _gridViewsArray = [[NSMutableArray alloc] init];  
    _monthGridViewsArray = [[NSMutableArray alloc] init];  
    _recyledGridSetDic = [[NSMutableDictionary alloc] init];
    self.gridScrollView.backgroundColor = [UIColor whiteColor];
}
- (void) setDate:(NSDate *)date
{
    if (_date)
    {
        [_date release];
        _date = nil;        
    }
    _date = [date retain];    
    CalMonth *cm = [[CalMonth alloc] initWithDate:_date];
    self.calMonth = cm;
    [cm release];
}
- (void) setMaximumDate:(NSDate *)maximumDate
{
    if (_maximumDate) 
    {
        [_maximumDate release];
        _maximumDate = nil;
    }
    _maximumDate = [maximumDate retain];
    if (_maximumDay) 
    {
        [_maximumDay release];
        _maximumDay = nil;
    }    
    _maximumDay = [[CalDay alloc] initWithDate:_maximumDate];
    
    _firstLayout = TRUE;    
    [self recyleAllGridViews];  
    [self setNeedsLayout];
}
- (void) setCalMonth:(CalMonth *)calMonth
{
    [self recyleAllGridViews];      
    if (_calMonth)
    {
        [_calMonth release];
        _calMonth = nil;
    }
    _calMonth = [calMonth retain];
    if (_date)
    {
        _selectedDay = [[CalDay alloc] initWithDate:_date];
    }
    else
    {
        _selectedDay = [[_calMonth firstDay] retain];
    }
    _firstLayout = TRUE;    
    [self setNeedsLayout];
}
- (NSString*) findMonthDescription
{
    NSString *title = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:titleForMonth:)]) 
    {
        title = [_dataSource calendarView:self titleForMonth:_calMonth];
    }
    if (!title||![title length]) 
    {        
        title = [NSString stringWithFormat:@"%d年%d月", [_calMonth getYear], [_calMonth getMonth]];        
    }
    return title;
}
- (NSArray*) findWeekTitles
{
    NSArray *titles = nil; 
    if (_dataSource && [_dataSource respondsToSelector:@selector(weekTitlesForCalendarView:)]) 
    {
        titles = [_dataSource weekTitlesForCalendarView:self];
    }
    if (!titles||![titles count]) 
    {
        titles = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
    }
    return titles;
}
- (void) recyleAllGridViews
{
    /*
     * recyled all grid views
     */    
    NSMutableSet *recyledGridSet;
    for (CalendarGridView *gridView in _gridViewsArray) 
    {
        recyledGridSet = [_recyledGridSetDic objectForKey:gridView.identifier];
        if (!recyledGridSet) 
        {    
            recyledGridSet = [[NSMutableSet alloc] init];
            [_recyledGridSetDic setObject:recyledGridSet forKey:gridView.identifier];
            [recyledGridSet release];
        }
        gridView.selected = FALSE;
        [gridView removeFromSuperview];
        [recyledGridSet addObject:gridView];
    }
    [_gridViewsArray removeAllObjects];    
    [_monthGridViewsArray removeAllObjects];
}
- (BOOL) isEarlyerMinimumDay:(CalDay*) calDay
{
    BOOL early = FALSE;
    if (_minimumDate) 
    {        
        if (NSOrderedAscending == [calDay compare:_minimumDay]) 
        {
            early = TRUE;
        }
    }
    return early;
}
- (BOOL) isAfterMaximumDay:(CalDay*) calDay
{
    BOOL after = FALSE;
    if (_maximumDate) 
    {        
        if (NSOrderedDescending == [calDay compare:_maximumDay]) 
        {
            after = TRUE;
        }
    }
    ITTDINFO(@"calday %@ is after maximuday %@ %d", calDay, _maximumDay, after);
    return after;
    
}
- (void) layoutGridCells
{
    BOOL hasSelectedDay = FALSE;    
    NSInteger count;
    NSInteger row = 0;
    NSInteger column = 0;
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;    
    CGRect frame;
    CalDay *calDay;
    CalendarGridView *gridView = nil;
    /*
     * layout grid view before selected month on calendar view
     */
    calDay = [_calMonth firstDay];
    if ([calDay getWeekDay] > 1) 
    {
        count = [calDay getWeekDay];
        CalMonth *previousMonth = [_calMonth previousMonth];
        row = 0;
        for (NSInteger day = previousMonth.days; count > 0 && day >= 1; day--) 
        {
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;                        
            gridView = [self disableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [_gridViewsArray addObject:gridView];                   
            count--;
        }
    }    
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    for (NSInteger day = 1; day <= _calMonth.days; day++)
    {
        calDay = [_calMonth calDayAtDay:day];
        row = (offsetRow + day - 1)/NUMBER_OF_DAYS_IN_WEEK;
        column = [calDay getWeekDay] - 1;
        gridView = [self gridViewAtRow:row column:column calDay:calDay];
        gridView.delegate = self;
        gridView.calDay = calDay;
        gridView.selectedEanable = (![self isEarlyerMinimumDay:calDay] && ![self isAfterMaximumDay:calDay]);
        if ([calDay isEqualToDay:self.selectedDay]) 
        {
            hasSelectedDay = TRUE;
            gridView.selected = TRUE;
            _selectedGridView = gridView;
            ITTDINFO(@"selected day %@", calDay);
        }
        frame = [self getFrameForRow:row column:column];        
        gridView.frame = frame;
        [gridView setNeedsLayout];
        [self.gridScrollView addSubview:gridView];   
        [_monthGridViewsArray addObject:gridView];
        [_gridViewsArray addObject:gridView];       
        if (CGRectGetMaxX(frame) > maxWidth) 
        {
            maxWidth = CGRectGetMaxX(frame);
        }
        if (CGRectGetMaxY(frame) > maxHeight) 
        {
            maxHeight = CGRectGetMaxY(frame);
        }        
    }
    if (!hasSelectedDay) 
    {
        _selectedGridView = [_monthGridViewsArray objectAtIndex:0];        
    }
    self.gridScrollView.contentSize = CGSizeMake(maxWidth, maxHeight + 5);    
    
    /*
     * layout grid view after selected month on calendar view
     */
    calDay = [_calMonth lastDay];
    if ([calDay getWeekDay] < NUMBER_OF_DAYS_IN_WEEK) 
    {
        NSUInteger days = NUMBER_OF_DAYS_IN_WEEK - [calDay getWeekDay];
        CalMonth *previousMonth = [_calMonth nextMonth];
        for (NSInteger day = 1; day <= days; day++) 
        {
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;                        
            gridView = [self disableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [_gridViewsArray addObject:gridView];                   
        }
    }    
}
- (CGRect) getFrameForRow:(NSUInteger)row column:(NSUInteger)column
{
    CGFloat x = MARGIN_LEFT + (column - 1)*PADDING_HORIZONTAL + column*_gridSize.width;
    CGFloat y = MARGIN_TOP + (row - 1)*PADDING_VERTICAL + row*_gridSize.height;
    CGRect frame = CGRectMake(x, y, _gridSize.width, _gridSize.height);
    return frame;
}
- (CalendarViewHeaderView*) findHeaderView
{
    CalendarViewHeaderView *headerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(headerViewForCalendarView:)]) 
    {
        headerView = [_dataSource headerViewForCalendarView:self];
    }
    return headerView;
}
- (CalendarViewFooterView*) findFooterview
{
    CalendarViewFooterView *footerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(footerViewForCalendarView:)]) 
    {
        footerView = [_dataSource footerViewForCalendarView:self];
    }
    return footerView;    
}
- (CalendarGridView*) gridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay
{
    CalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarGridViewForRow:column:calDay:)]) 
    {
        gridView = [_dataSource calendarView:self calendarGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;
}
- (CalendarGridView*) disableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay
{
    CalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarDisableGridViewForRow:column:calDay:)]) 
    {
        gridView = [_dataSource calendarView:self calendarDisableGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (CalendarGridView*) dequeueCalendarGridViewWithIdentifier:(NSString*)identifier
{
    CalendarGridView *gridView = nil;
    NSMutableSet *recyledGridSet = [_recyledGridSetDic objectForKey:identifier];
    if (recyledGridSet) 
    {
        gridView = [recyledGridSet anyObject];
        if (gridView) 
        {        
            [[gridView retain] autorelease];
            [recyledGridSet removeObject:gridView];
        }
    }
    return gridView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (BOOL) appear
{
    return (self.alpha > 0);
}
- (void) animationChangeMonth:(BOOL)next
{
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionPush;
//    if (next)
//    {
//        animation.subtype = kCATransitionFromLeft;
//        [self.gridScrollView.layer addAnimation:animation forKey:@"NextMonth"];        
//    }
//    else
//    {
//        animation.subtype = kCATransitionFromRight;
//        [self.gridScrollView.layer addAnimation:animation forKey:@"PreviousMonth"];                
//    }
    UIViewAnimationTransition options;
    if (next)    
    {
        options = UIViewAnimationTransitionCurlUp;          
    }
    else
    {      
        options = UIViewAnimationTransitionCurlDown;        
    }
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationTransition:options forView:self.gridScrollView cache:TRUE]; 
        if (next) 
        {
            self.calMonth = [_calMonth nextMonth];     
            ITTDINFO(@"self.calmonth %@", self.calMonth);
        }
        else
        {
            self.calMonth = [_calMonth previousMonth];                 
        }
    } completion:^(BOOL finished)
     {
         if (finished) 
         {
            
         }
     }];
}
- (void) nextMonth
{
    [self animationChangeMonth:TRUE];    
}
- (void) previousMonth
{
    [self animationChangeMonth:FALSE];    
}
- (void) layoutSubviews
{
    if (_firstLayout) 
    {
        [self layoutGridCells];    
        /*
         * layout header view
         */
        if (!_calendarHeaderView)
        {
            CalendarViewHeaderView *calendarHeaderView = [self findHeaderView];
            if (calendarHeaderView) 
            {
                if (_calendarHeaderView) 
                {
                    [_calendarHeaderView removeFromSuperview];
                }
                CGRect frame = calendarHeaderView.bounds;
                frame.origin.x = (CGRectGetWidth(self.headerView.bounds) - CGRectGetWidth(frame))/2;
                frame.origin.y = (CGRectGetHeight(self.headerView.bounds) - CGRectGetHeight(frame))/2;        
                calendarHeaderView.delegate = self;
                calendarHeaderView.frame = frame;
                _calendarHeaderView = calendarHeaderView;
                [self.headerView addSubview:_calendarHeaderView];    
            }               
        }     
        /*
         * layout footer view
         */
        if (!_calendarFooterView) 
        {
            CalendarViewFooterView *calendarFooterView = [self findFooterview];
            if (calendarFooterView) 
            {
                if (_calendarFooterView) 
                {
                    [_calendarFooterView removeFromSuperview];
                }
                CGRect frame = calendarFooterView.bounds;
                frame.origin.x = (CGRectGetWidth(self.footerView.bounds) - CGRectGetWidth(frame))/2;
                frame.origin.y = (CGRectGetHeight(self.footerView.bounds) - CGRectGetHeight(frame))/2;        
                calendarFooterView.delegate = self;
                calendarFooterView.frame = frame;
                _calendarFooterView = calendarFooterView;
                [self.footerView addSubview:_calendarFooterView];    
            }        
            else
            {
                CGRect frame = self.frame;
                frame.size.height = CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW;
                self.frame = frame;
            }
        }               
        /*
         * layout week hint labels
         */
        for (UIView *subview in self.weekHintView.subviews) 
        {
            /*
             * subview is not background imageview
             */
            if (![subview isKindOfClass:[UIImageView class]]) 
            {
                [subview removeFromSuperview];
            }
        }
        CGFloat totalWidth = self.gridScrollView.contentSize.width;
        CGFloat width = totalWidth/NUMBER_OF_DAYS_IN_WEEK;
        CGFloat marginX = 0;
        NSArray *titles = [self findWeekTitles];
        for (NSInteger i = 0; i < NUMBER_OF_DAYS_IN_WEEK; i++) 
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(marginX, 0, width, CGRectGetHeight(self.weekHintView.bounds))];
            label.textAlignment = UITextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.text = [titles objectAtIndex:i];
            label.backgroundColor = [UIColor clearColor];
            label.minimumFontSize = 12;
            label.adjustsFontSizeToFitWidth = TRUE;
            [self.weekHintView addSubview:label];
            [label release];
            marginX += width;            
        }
        _firstLayout = FALSE;
    }
    _calendarHeaderView.title = [self findMonthDescription];            
}
- (void) swipe:(UISwipeGestureRecognizer*)gesture
{
    ITTDINFO(@"UISwipeGestureRecognizer direction %d", gesture.direction);
    if (UISwipeGestureRecognizerDirectionRight == gesture.direction) 
    {
        [self previousMonth];
    }
    else if (UISwipeGestureRecognizerDirectionLeft == gesture.direction) 
    {
        [self nextMonth];
    }    
}
- (void) awakeFromNib
{
    [super awakeFromNib];
    self.alpha = 0.0;
    _firstLayout = TRUE;
    _selectedPeriod = PeriodTypeAllDay;
    _minimumDate = [[NSDate date] retain];
    _minimumDay = [[CalDay alloc] initWithDate:_minimumDate];    
    [self initParameters];    
    /*
     * add left and right swipe gesture 
     */
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeGesture];
    [leftSwipeGesture release];
    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeGesture];
    [rightSwipeGesture release];    
    
}
- (NSDate*)selectedDate
{
    return _selectedDay.date;
}
+ (id) viewFromNib
{
    return [[[[[NSBundle mainBundle] loadNibNamed:@"CalendarView" owner:self options:nil] objectAtIndex:0] retain] autorelease];
}
- (void)dealloc 
{
    [_minimumDate release];
    _minimumDate = nil;
    _delegate = nil;
    [_dataSource release];
    _dataSource = nil;
    _calendarHeaderView = nil;
    [_selectedDay release];
    _selectedDay = nil;    
    [_recyledGridSetDic release];
    _recyledGridSetDic = nil;    
    [_gridViewsArray release];
    _gridViewsArray = nil;
    [_monthGridViewsArray release];
    _monthGridViewsArray = nil;        
    [_headerView release];
    _headerView = nil;
    [_footerView release];
    _footerView = nil;    
    [_gridScrollView release];
    _gridScrollView = nil;
    [_weekHintView release];
    [_minimumDay release];
    _minimumDay = nil;    
    [_maximumDate release];
    _maximumDate = nil;
    [_maximumDay release];
    _maximumDay = nil;
    [super dealloc];
}
#pragma mark - CalendarViewHeaderViewDelegate
- (void) calendarViewHeaderViewNextMonth:(CalendarViewHeaderView*)calendarHeaderView
{
    [self nextMonth];
}
- (void) calendarViewHeaderViewPreviousMonth:(CalendarViewHeaderView*)calendarHeaderView
{
    [self previousMonth];
}
- (void) calendarViewHeaderViewDidCancel:(CalendarViewHeaderView*)calendarHeaderView
{
    [self hide];
}
- (void) calendarViewHeaderViewDidSelection:(CalendarViewHeaderView*)calendarHeaderView
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectDay:calDay:)])
    {
        [_delegate calendarViewDidSelectDay:self calDay:self.selectedDay];
    } 
    [self hide];    
}
#pragma mark - CalendarViewFooterViewDelegate
- (void) calendarViewFooterViewDidSelectPeriod:(CalendarViewFooterView*)footerView periodType:(PeriodType)type
{
    self.selectedPeriod = type;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectPeriodType:periodType:)]) {
        [_delegate calendarViewDidSelectPeriodType:self periodType:type];
    }
}
#pragma mark - CalendarGridViewDelegate
- (void) calendarGridViewDidSelectGrid:(CalendarGridView*) gridView
{
    _selectedDay = [gridView.calDay retain];    
    if (_selectedGridView) 
    {
        [_selectedGridView deselect];        
    }
    _selectedGridView = gridView;
    [_selectedGridView select];
}
- (void) show
{
    [UIView animateWithDuration:0.4 animations:^{
        self.layer.zPosition = 3.0;
        self.alpha = 1.0;
    }];
}
- (void) hide
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        _parentView.alpha = 0.0;
        self.layer.zPosition = -1.0;        
    }];      
}
- (void) showInView:(UIView*)view
{
    if (!_parentView) 
    {
        _parentView = [[UIView alloc] initWithFrame:view.bounds];
        _parentView.alpha = 0.0;
        _parentView.backgroundColor = [UIColor whiteColor];
        [view addSubview:_parentView];
    }
    else
    {
        if (_parentView.superview == view) 
        {
        }
        else
        {
            _parentView.alpha = 0.0;
            [_parentView removeFromSuperview];
            _parentView.frame = view.bounds;
            [view addSubview:_parentView];
        }
    }
    if (!self.superview) 
    {        
        [view addSubview:self];
    }
    else
    {        
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
        _parentView.alpha = 0.6;
        self.layer.zPosition = 3.0;        
    }];    
}
@end
