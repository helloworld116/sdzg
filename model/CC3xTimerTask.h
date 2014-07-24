//
//  CC3xTimerTask.h
//  CC3x
//
//  Created by hq on 4/20/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DAYTYPE){
   MONDAY = 1 << 0,
   TUESDAY = 1 << 1,
   WENSDAY = 1 << 2,
   THURSDAY = 1 << 3,
   FRIDAY = 1 << 4,
   SATURDAY = 1 << 5,
   SUNDAY = 1 << 6
};


@interface CC3xTimerTask : NSObject

@property (nonatomic, assign) unsigned char week;
@property (nonatomic, assign) NSUInteger startTime;
@property (nonatomic, assign) NSUInteger endTime;
@property (nonatomic, assign) unsigned char timeDetail;


- (BOOL)isTaskOn;
- (void)setTaskOn:(BOOL)taskOn;
- (void)setStartTimeON:(BOOL)startTimeON;
- (BOOL)isStartTimeOn;
- (BOOL)isEndTimeOn;
- (void)setEndTimeOn:(BOOL)endTimeON;

- (BOOL)isDayOn:(DAYTYPE)aDay;

@end
