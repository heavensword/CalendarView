//
//  Enum.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-13.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#ifndef ZHJCalendar_Enum_h
#define ZHJCalendar_Enum_h

typedef enum 
{
    PeriodTypeKnown = 11,
    PeriodTypeAllDay,
    PeriodTypeMorning,
    PeriodTypeNoon,
    PeriodTypeAfternoon,
    PeriodTypeEvening
}PeriodType;

typedef enum 
{
    WeekDayKnown = 0,
    WeekDayMonday,
    WeekDayTuesday,
    WeekDayWednesday,
    WeekDayThurday,
    WeekDayFriday,
    WeekDaySaturday,
    WeekDaySunday
}WeekDay;

#endif
