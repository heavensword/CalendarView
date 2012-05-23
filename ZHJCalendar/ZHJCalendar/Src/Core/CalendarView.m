//
//  CalendarView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CalendarView.h"
#import "CalendarViewHeaderView.h"
#import "CalendarGridView.h"
#import "CalMonth.h"
#import "CalDay.h"

#define MARGIN_LEFT                              5
#define MARGIN_TOP                               9
#define PADDING_VERTICAL                         5
#define PADDING_HORIZONTAL                       3
#define HORIZONTAL_SWIPE_HEIGHT_CONSTRAINT       80
#define HORIZONTAL_SWIPE_WIDTH_CONSTRAINT        90
#define SWIPE_TIMERINTERVAL                      0.3

@interface CalendarView()

@property (nonatomic, assign) CGSize gridSize;
@property (retain, nonatomic) CalMonth *calMonth;

@property (retain, nonatomic) IBOutlet UIView *weekHintView;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet CalendarScrollView *gridScrollView;

- (void) initParameters;
- (void) layoutGridCells;
- (void) recyleAllGridViews;
- (void) resetSelectedIndicesMatrix;
- (void) resetFoucsMatrix;
- (void) updateSelectedGridViewState;
- (void) removeGridViewAtRow:(NSUInteger) row column:(NSUInteger)column;
- (void) addGridViewAtRow:(CalendarGridView*)gridView row:(NSUInteger) row column:(NSUInteger)column;

- (BOOL) isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger) column;
/*
 * caculate rows of calendar view based on month
 */
- (NSUInteger) getRows;
/*
 * caculate month day based on row and column on calendar view
 */
- (NSUInteger) getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column;
/*
 * caculate grid view frame based on row and column on calendar view
 */
- (CGRect) getFrameForRow:(NSUInteger)row column:(NSUInteger)column;

- (NSString*) findMonthDescription;

- (NSArray*) findWeekTitles;

/*
 * @return:current day or first day of a month
 */
- (CalDay*) getFirstSelectedAvailableDay;

- (CalendarViewHeaderView*) findHeaderView;
- (CalendarViewFooterView*) findFooterview;

- (CalendarGridView*) findGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay;
- (CalendarGridView*) findDisableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay;
- (CalendarGridView*) getGridViewAtRow:(NSUInteger) row column:(NSUInteger)column;

@end

@implementation CalendarView

@synthesize appear;
@synthesize selectedDateArray;
@synthesize selectedDate;
@synthesize gridSize = _gridSize;
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
@synthesize allowsMultipleSelection = _allowsMultipleSelection;

- (void) initParameters
{
    _allowsMultipleSelection = FALSE;
    _firstLayout = TRUE;
    _selectedPeriod = PeriodTypeAllDay;
    _minimumDate = [[NSDate date] retain];
    _minimumDay = [[CalDay alloc] initWithDate:_minimumDate];    
    _previousSelectedIndex.row = NSNotFound;
    _previousSelectedIndex.column = NSNotFound;
    
    _gridSize = CGSizeMake(39, 31);    
    _date = [[NSDate date] retain];        
    _selectedDay = [[CalDay alloc] initWithDate:_date];        
    _calMonth = [[CalMonth alloc] initWithDate:_date];            
    _gridViewsArray = [[NSMutableArray alloc] init];  
    _monthGridViewsArray = [[NSMutableArray alloc] init];  
    _recyledGridSetDic = [[NSMutableDictionary alloc] init];
    
    NSUInteger n = 6;
    _selectedIndicesMatrix = (bool**)malloc(sizeof(bool*)*n);
    _foucsMatrix  = (bool**)malloc(sizeof(bool*)*n);
    for (NSUInteger i = 0; i < n; i++) 
    {
        _selectedIndicesMatrix[i] = malloc(sizeof(bool)*NUMBER_OF_DAYS_IN_WEEK);
        memset(_selectedIndicesMatrix[i], FALSE, NUMBER_OF_DAYS_IN_WEEK);

        _foucsMatrix[i] = malloc(sizeof(bool)*NUMBER_OF_DAYS_IN_WEEK);
        memset(_foucsMatrix[i], FALSE, NUMBER_OF_DAYS_IN_WEEK);

    }
    for (NSUInteger index = 0; index < n; index++) 
    {
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        [_gridViewsArray addObject:rows];
        [rows release];
    }    
}
- (void) freeMatrix
{
    NSInteger n = 6;
    for (int i = 0; i < n; i++) 
    {
        free(_selectedIndicesMatrix[i]);
        _selectedIndicesMatrix[i] = NULL;
        free(_foucsMatrix[i]);
        _foucsMatrix[i] = NULL;
    }    
    free(_selectedIndicesMatrix);
    _selectedIndicesMatrix = NULL;
    free(_foucsMatrix);
    _foucsMatrix = NULL;
    
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
- (void) setCalMonth:(CalMonth *)calMonth
{
    [self recyleAllGridViews];      
    if (_calMonth)
    {
        [_calMonth release];
        _calMonth = nil;
    }
    _calMonth = [calMonth retain];
    [_selectedDay release];
    _selectedDay = nil;    
    _selectedDay = [[self getFirstSelectedAvailableDay] retain];
    _firstLayout = TRUE;    
    [self setNeedsLayout];
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
- (NSUInteger) getRows
{
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger row = (offsetRow + _calMonth.days - 1)/NUMBER_OF_DAYS_IN_WEEK;
    return row + 1;    
}
- (NSUInteger) getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column
{
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;            
    NSUInteger day = (row * NUMBER_OF_DAYS_IN_WEEK + 1 - offsetRow) + column;
    return day;
}
- (BOOL) isValidGridViewIndex:(GridIndex)index
{
    BOOL valid = TRUE;
    if (index.column < 0||
        index.row < 0||
        index.column >= NUMBER_OF_DAYS_IN_WEEK||
        index.row >= [self getRows]) 
    {
        valid = FALSE;
    }
    return valid;
}
- (GridIndex) getGridViewIndex:(CalendarScrollView*)calendarScrollView touches:(NSSet*)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:calendarScrollView];
    GridIndex index;
    NSInteger row = (location.y - MARGIN_TOP + PADDING_VERTICAL)/(PADDING_VERTICAL + _gridSize.height);
    NSInteger column = (location.x - MARGIN_LEFT + PADDING_HORIZONTAL)/(PADDING_HORIZONTAL + _gridSize.width);
    ITTDINFO(@"row %d column %d", row, column);
    index.row = row;
    index.column = column;
    return index;
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
    for (NSMutableArray *rowGridViewsArray in _gridViewsArray) 
    {
        for (CalendarGridView *gridView in rowGridViewsArray) 
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
        [rowGridViewsArray removeAllObjects];
    }
    [_monthGridViewsArray removeAllObjects];
}
- (CalendarGridView*) getGridViewAtRow:(NSUInteger) row column:(NSUInteger)column
{
    CalendarGridView *gridView = nil;
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    gridView = [rowGridViewsArray objectAtIndex:column];
    return gridView;
}
- (BOOL) isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger) column
{
    BOOL selectedEnable = TRUE;    
    NSUInteger day = [self getMonthDayAtRow:row column:column];
    if (day < 1 || day > _calMonth.days)
    {
        selectedEnable = FALSE;
    }
    else
    {
        CalDay *calDay = [_calMonth calDayAtDay:day];
        ITTDINFO(@"day is %d", day);            
        if([self isEarlyerMinimumDay:calDay] || [self isAfterMaximumDay:calDay])
        {
            selectedEnable = FALSE;
        }        
    }
    return selectedEnable;
}
- (void) resetSelectedIndicesMatrix
{
    NSInteger n = 6;
    for (NSInteger row = 0; row < n; row++) 
    {
        memset(_selectedIndicesMatrix[row], FALSE, NUMBER_OF_DAYS_IN_WEEK);
        memset(_foucsMatrix[row], FALSE, NUMBER_OF_DAYS_IN_WEEK);                
    }
}
- (void) resetFoucsMatrix
{
    NSInteger n = 6;
    for (NSInteger row = 0; row < n; row++) 
    {
        memset(_foucsMatrix[row], FALSE, NUMBER_OF_DAYS_IN_WEEK);                
    }    
}
/*
 * update grid state
 */
- (void) updateSelectedGridViewState
{
    CalendarGridView *gridView = nil;
    NSInteger rows = [self getRows];
    for (NSInteger row = 0; row < rows; row++) 
    {
        for (NSInteger column = 0; column < NUMBER_OF_DAYS_IN_WEEK; column++) 
        {
            gridView = [self getGridViewAtRow:row column:column];
            /*
             * grid selected status and current seleted status are different
             */
            if (gridView.selected ^ _selectedIndicesMatrix[row][column]) 
            {
                gridView.selected = _selectedIndicesMatrix[row][column];                
            }
        }
    }
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
- (void) removeGridViewAtRow:(NSUInteger) row column:(NSUInteger)column
{
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    if (column < [rowGridViewsArray count]) 
    {
        [rowGridViewsArray removeObjectAtIndex:column];        
    }
}
- (void) addGridViewAtRow:(CalendarGridView*)gridView row:(NSUInteger) row 
                   column:(NSUInteger)column
{
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    NSInteger count = [rowGridViewsArray count];
    if (column > count||column < count)
    {      
        if (column > count) 
        {
            NSInteger offsetCount = column - count + 1;
            for (NSInteger offset = 0; offset < offsetCount; offset++) 
            {
                [rowGridViewsArray addObject:[NSNull null]];
            }            
        }
        [rowGridViewsArray replaceObjectAtIndex:column withObject:gridView];        
    }    
    else if (column == count) 
    {        
        [rowGridViewsArray insertObject:gridView atIndex:column];
    }
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
            gridView = [self findDisableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;            
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [self addGridViewAtRow:gridView row:row column:column];
            count--;
        }
    }    
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    for (NSInteger day = 1; day <= _calMonth.days; day++)
    {
        calDay = [_calMonth calDayAtDay:day];
        row = (offsetRow + day - 1)/NUMBER_OF_DAYS_IN_WEEK;
        column = [calDay getWeekDay] - 1;
        gridView = [self findGridViewAtRow:row column:column calDay:calDay];
        gridView.delegate = self;
        gridView.calDay = calDay;
        gridView.row = row;
        gridView.column = column;
        gridView.selectedEanable = ([self isEarlyerMinimumDay:calDay] || [self isAfterMaximumDay:calDay]) ? FALSE:TRUE;
        if ([calDay isEqualToDay:self.selectedDay]) 
        {
            hasSelectedDay = TRUE;
            gridView.selected = TRUE;
            _selectedIndicesMatrix[row][column] = TRUE;
        }
        frame = [self getFrameForRow:row column:column];        
        gridView.frame = frame;
        [gridView setNeedsLayout];
        [self.gridScrollView addSubview:gridView];   
        [_monthGridViewsArray addObject:gridView];
        [self addGridViewAtRow:gridView row:row column:column];
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
        CalendarGridView *selectedGridView = [_monthGridViewsArray objectAtIndex:0];     
        _selectedIndicesMatrix[selectedGridView.row][selectedGridView.column] = TRUE;        
        selectedGridView.selected = TRUE;
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
            gridView = [self findDisableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [self addGridViewAtRow:gridView row:row column:column];
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
- (CalDay*) getFirstSelectedAvailableDay
{
    CalDay *selectedCalDay = nil;
    for (NSInteger day = 1; day <= _calMonth.days; day++)
    {
        CalDay *calDay = [_calMonth calDayAtDay:day];
        if ([calDay isToday]) 
        {
            selectedCalDay = calDay;
            break;
        }
    }
    if (!selectedCalDay) 
    {
        selectedCalDay = [_calMonth firstDay];
    }
    return selectedCalDay;
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
- (CalendarGridView*) findGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay
{
    CalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarGridViewForRow:column:calDay:)]) 
    {
        gridView = [_dataSource calendarView:self calendarGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;
}
- (CalendarGridView*) findDisableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay*)calDay
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
    _calendarHeaderView.nextMonthButton.enabled = FALSE;
    _calendarHeaderView.previousMonthButton.enabled = FALSE;    
    CalMonth *month = nil;
    if (next) 
    {            
        month = [_calMonth nextMonth];   
    }
    else
    {
        month = [_calMonth previousMonth];                 
    }    
    if (_date) 
    {
        [_date release];
        _date = nil;
    }
    _date = [[month firstDay].date retain];
    self.calMonth = month;    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:options forView:self.gridScrollView cache:TRUE]; 
    } completion:^(BOOL finished)
     {
         if (finished) 
         {
             _calendarHeaderView.nextMonthButton.enabled = TRUE;
             _calendarHeaderView.previousMonthButton.enabled = TRUE;                
         }
     }];
}
- (void) nextMonth
{
    [self resetSelectedIndicesMatrix];
    [self animationChangeMonth:TRUE];    
}
- (void) previousMonth
{
    [self resetSelectedIndicesMatrix];    
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
    if (UISwipeGestureRecognizerDirectionLeft == gesture.direction) 
    {
        [self nextMonth];
    }
    else 
    {
        [self previousMonth];
    }
}
- (void) awakeFromNib
{
    [super awakeFromNib];
    self.alpha = 0.0;
    self.multipleTouchEnabled = TRUE;
    self.gridScrollView.calendarDelegate = self;    
    [self initParameters];      
//    /*
//     * add left and right swipe gesture 
//     */
//    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:leftSwipeGesture];
//    [leftSwipeGesture release];
//    
//    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:rightSwipeGesture];
//    [rightSwipeGesture release];     
}
- (NSDate*)selectedDate
{
    return _selectedDay.date;
}
- (NSArray*) selectedDateArray
{
    if (!_allowsMultipleSelection) 
    {
        return nil;
    }
    else
    {
        NSUInteger rows = [self getRows];
        NSMutableArray *selectedDates = [NSMutableArray array];        
        for (NSUInteger row = 0; row < rows; row++) 
        {
            for (NSUInteger column = 0; column < NUMBER_OF_DAYS_IN_WEEK; column++) 
            {
                if (_selectedIndicesMatrix[row][column]) 
                {
                    NSUInteger day = [self getMonthDayAtRow:row column:column];
                    CalDay *calDay = [_calMonth calDayAtDay:day];    
                    [selectedDates addObject:calDay.date];
                    ITTDINFO(@"selected day %d", day);                    
                }
            }
        }
        return selectedDates;
    }
}
+ (id) viewFromNib
{
    return [[[[[NSBundle mainBundle] loadNibNamed:@"CalendarView" owner:self options:nil] objectAtIndex:0] retain] autorelease];
}
- (void)dealloc 
{
    [self freeMatrix];
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
}
- (void) hide
{
    [UIView animateWithDuration:0.3 animations:^{
        _shieldView.alpha = 0.0;        
        self.alpha = 0.0;
    }];      
}
- (void) showInView:(UIView*)view
{
    if (!_shieldView) 
    {
        _shieldView = [[UIView alloc] initWithFrame:view.bounds];
        _shieldView.alpha = 0.0;
        _shieldView.backgroundColor = [UIColor whiteColor];
        [view addSubview:_shieldView];
    }
    else
    {
        if (_shieldView.superview == view) 
        {
        }
        else
        {
            _shieldView.alpha = 0.0;
            [_shieldView removeFromSuperview];
            _shieldView.frame = view.bounds;
            [view addSubview:_shieldView];
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
        _shieldView.alpha = 0.6;
    }];    
}

#pragma mark - CalendarScrollViewDelegate
- (void) calendarSrollViewTouchesBegan:(CalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = FALSE;   
    UITouch *beginTouch = [touches anyObject];
    _beginTimeInterval = beginTouch.timestamp;
    _beginPoint = [beginTouch locationInView:calendarScrollView];
}
- (void) calendarSrollViewTouchesMoved:(CalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = TRUE;
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index]) 
    {
        if (_allowsMultipleSelection) 
        {
            BOOL selectedEnable = FALSE;
            /*
             * the grid is on unselected state
             */
            if (!_selectedIndicesMatrix[index.row][index.column]) 
            {              
                [self resetFoucsMatrix];
                _foucsMatrix[index.row][index.column] = TRUE;                
                selectedEnable = !_selectedIndicesMatrix[index.row][index.column];
                selectedEnable = (selectedEnable & [self isGridViewSelectedEnableAtRow:index.row column:index.column]);
                _selectedIndicesMatrix[index.row][index.column] = selectedEnable;                
            }
        }
        else
        {
            //do nothing
        }
        _previousSelectedIndex = index;        
        [self updateSelectedGridViewState];                            
    }
}

- (void) calendarSrollViewTouchesEnded:(CalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index]) 
    {
        BOOL selectedEnable = TRUE;        
        if (!_moved) 
        {
            if (!_allowsMultipleSelection) 
            {
                [self resetSelectedIndicesMatrix];
                selectedEnable = TRUE;
                selectedEnable = selectedEnable & [self isGridViewSelectedEnableAtRow:index.row column:index.column];
                _selectedIndicesMatrix[index.row][index.column] = selectedEnable;
            }             
            else
            {
                selectedEnable = _selectedIndicesMatrix[index.row][index.column];
                _selectedIndicesMatrix[index.row][index.column] = !selectedEnable;                                        
            }
        }
        [self updateSelectedGridViewState];                            
        if (!_allowsMultipleSelection) 
        {
            if (!_moved) 
            {
                NSInteger day = [self getMonthDayAtRow:index.row column:index.column];                                
                if (day >= 1 && day <= _calMonth.days) 
                {
                    [_selectedDay release];
                    _selectedDay = nil;                
                    _selectedDay = [[_calMonth calDayAtDay:day] retain];                    
                }                        
            }
        }
    }    
    UITouch *endTouch = [touches anyObject];
    if (endTouch.timestamp - _beginTimeInterval <= SWIPE_TIMERINTERVAL)
    {
        CGPoint endPoint = [endTouch locationInView:calendarScrollView];
        if (fabs(endPoint.y - _beginPoint.y) < HORIZONTAL_SWIPE_HEIGHT_CONSTRAINT) 
        {
            if (fabs(endPoint.x - _beginPoint.x) > HORIZONTAL_SWIPE_WIDTH_CONSTRAINT) 
            {
                //swipe right
                if (endPoint.x > _beginPoint.x)
                {
                    [self previousMonth];
                }
                else
                {
                    [self nextMonth];
                }                
            }
        }
    }
}
@end
