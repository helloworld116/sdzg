//
//  CC3xTimerTask.m
//  CC3x
//
//  Created by hq on 4/20/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import "CC3xTimerTask.h"

@implementation CC3xTimerTask


- (id)initWithWeek:(unsigned char)aWeek
         startTime:(NSUInteger)aStartTime
           endTime:(NSUInteger)aEndTime
            detail:(unsigned char)aTimeDetail
{
   if ((self = [super init])) {
      self.week = aWeek;
      self.startTime = aStartTime;
      self.endTime = aEndTime;
      self.timeDetail = aTimeDetail;
   }

   return self;
}


- (BOOL)isTaskOn
{
   return self.timeDetail & (1 << 0);
}

- (void)setTaskOn:(BOOL)taskOn
{
   if (taskOn) {
      self.timeDetail |= 1 << 0;
   } else {
      self.timeDetail &= ~(1 << 0);
   }
}

- (BOOL)isStartTimeOn
{
   return self.timeDetail & (1 << 1);
}

- (void)setStartTimeON:(BOOL)startTimeON
{
   if (startTimeON) {
      self.timeDetail |= 1 << 1;
   } else {
      self.timeDetail &= (1 << 1);
   }
}

- (BOOL)isEndTimeOn
{
   return self.timeDetail & (1 << 2);
}

- (void)setEndTimeOn:(BOOL)endTimeON
{
   if (endTimeON) {
      self.timeDetail |= 1 << 2;
   } else {
      self.timeDetail &= ~(1 << 2);
   }
}

- (BOOL)isDayOn:(DAYTYPE)aDay
{
   return self.week & aDay;
}


@end
