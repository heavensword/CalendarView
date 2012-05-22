//
//  AppDelegate.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "CalDay.h"
#import "CalMonth.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSDate *date = [NSDate date];
//    NSLocale *l = [[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"] autorelease];
//    NSCalendar *calendar = [l objectForKey:NSLocaleCalendar];
//    NSDateComponents *dc = [calendar components:NSYearCalendarUnit | NSEraCalendarUnit fromDate:date];
//    for (int month = 1; month <= 12; month++) {
//        [dc setMonth:month];
//        for (int day = 1; day <= 7; day++) {
//            [dc setDay:day];
//            date = [calendar dateFromComponents:dc];
//            NSLog(@"date:%@, month:%u, day:%u, weekday:%u, week:%u", date,
//                  [calendar ordinalityOfUnit:NSMonthCalendarUnit inUnit:NSYearCalendarUnit forDate:date],
//                  [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date],
//                  [calendar ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:date],
//                  [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date]);
//        }
//        NSLog(@" ");
//    }
//    
    ITTDINFO(@"is leap year %d", [DateUtil isLeapYear:2012]);
    ITTDINFO(@"current year %d", [DateUtil getCurrentYear]);
    ITTDINFO(@"numberOfDaysInMonth %d", [DateUtil numberOfDaysInMonth:4]);    
    CalDay *calDay = [[CalDay alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:2*24*60*60]];
    ITTDINFO(@"cal day %@", calDay);
    [calDay release];
    NSInteger x = 12;    
    NSAssert(x!=0, @"x must not be zero");    
    CalMonth *calMonth = [[CalMonth alloc] initWithMonth:4 year:2012];
    ITTDINFO(@"cal month %@", calMonth);
    [calMonth release];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
