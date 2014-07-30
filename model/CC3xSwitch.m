//
//  CC3xSwitch.m
//  CC3x
//
//  Created by hq on 4/5/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import "CC3xSwitch.h"
#import "CC3xUtility.h"

@implementation CC3xSwitch

- (instancetype)initWithName:(NSString *)name
                  macAddress:(NSString *)aMacAddress
                      status:(switchStatus)aStatus
                          ip:(NSString *)aIp
                        port:(unsigned short)aPort
                    isLocked:(BOOL)isLocked
                        isOn:(BOOL)isOn
                   timerList:(NSMutableArray *)aTimerList
                   imageName:(NSString *)imageName {
  if ((self = [super init])) {
    if ([name isEqualToString:@""]) {
      name = DEFAULT_NAME;
    }
    if (!imageName || [@"" isEqualToString:imageName]) {
      self.imageName = DEFAULT_IMAGENAME;
    }
    self.switchName = name;
    self.macAddress = aMacAddress;
    self.status = aStatus;
    self.ip = aIp;
    self.port = aPort;
    self.isLocked = isLocked;
    self.isOn = isOn;
    self.timerList = aTimerList;
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name
                  macAddress:(NSString *)aMacAddress
                      status:(switchStatus)aStatus {
  return [self initWithName:name
                 macAddress:aMacAddress
                     status:aStatus
                         ip:nil
                       port:0
                   isLocked:NO
                       isOn:YES
                  timerList:nil
                  imageName:nil];
}

@end
