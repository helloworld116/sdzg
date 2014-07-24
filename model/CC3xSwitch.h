//
//  CC3xSwitch.h
//  CC3x
//
//  Created by hq on 4/5/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, switchStatus)
{
   SWITCH_UNKNOWN,
   SWITCH_LOCAL,
   SWITCH_LOCAL_LOCK,
   SWITCH_OFFLINE,
   SWITCH_REMOTE,
   SWITCH_REMOTE_LOCK,
   SWITCH_NEW,
};


@interface CC3xSwitch : NSObject


@property (nonatomic, copy) NSString *switchName;
@property (nonatomic, assign) switchStatus status;
@property (nonatomic, copy) NSString *macAddress;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) unsigned short port;
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, copy) UIImage * image;
@property (nonatomic, copy) NSMutableArray * timerList;


@property (nonatomic, assign) NSInteger delayTimer;
//!!!:只添加了属性，没有写set



- (instancetype)initWithName:(NSString *)name
        macAddress:(NSString *)aMacAddress
            status:(switchStatus) aStatus
                ip:(NSString *)aIp
              port:(unsigned short)aPort
          isLocked:(BOOL)isLocked
              isOn:(BOOL)isOn
                   timerList:(NSMutableArray *)aTimerList;

- (instancetype)initWithName:(NSString *)name
                  macAddress:(NSString *)aMacAddress
                      status:(switchStatus) aStatus;

@end
