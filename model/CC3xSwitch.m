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
                   imageName:(NSString *)imageName
              pmTwoPointFive:(NSInteger)pmTwoPointFive
                 temperature:(float)temperature
                    humidity:(NSInteger)humidity
                       power:(float)power
                     airDesc:(NSString *)airDesc {
  self = [self initWithName:name
                 macAddress:aMacAddress
                     status:aStatus
                         ip:aIp
                       port:aPort
                   isLocked:isLocked
                       isOn:isOn
                  timerList:aTimerList
                  imageName:imageName];
  self.pmTwoPointFive = pmTwoPointFive;
  self.temperature = temperature;
  self.humidity = humidity;
  self.power = power;
  self.airDesc = airDesc;
  return self;
}

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
      imageName = DEFAULT_IMAGENAME;
    }
    self.switchName = name;
    self.macAddress = aMacAddress;
    self.status = aStatus;
    self.ip = aIp;
    self.port = aPort;
    self.isLocked = isLocked;
    self.isOn = isOn;
    self.timerList = aTimerList;
    self.imageName = imageName;
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

- (UIImage *)getImageByImageName:(NSString *)imageName {
  UIImage *image;
  NSArray *imageNames = [kTemplatePicDict allValues];
  for (NSString *name in imageNames) {
    if ([imageName isEqualToString:name]) {
      image = [UIImage imageNamed:name];
      break;
    }
  }
  if (image) {
    return image;
  } else {
    NSString *imagePath =
        [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
            stringByAppendingPathComponent:imageName];
    image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
  }
}

@end
