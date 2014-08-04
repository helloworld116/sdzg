//
//  CC3xSwitch.h
//  CC3x
//
//  Created by hq on 4/5/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, switchStatus) {
    SWITCH_UNKNOWN, SWITCH_LOCAL,       SWITCH_LOCAL_LOCK, SWITCH_OFFLINE,
    SWITCH_REMOTE,  SWITCH_REMOTE_LOCK, SWITCH_NEW,
};

@interface CC3xSwitch : NSObject

@property(nonatomic, strong) NSString *switchName;
@property(nonatomic, assign) switchStatus status;
@property(nonatomic, strong) NSString *macAddress;
@property(nonatomic, strong) NSString *ip;
@property(nonatomic, assign) unsigned short port;
@property(nonatomic, assign) BOOL isLocked;
@property(nonatomic, assign) BOOL isOn;

@property(nonatomic, strong) NSString *imageName;
@property(nonatomic, strong) NSMutableArray *timerList;

@property(nonatomic, assign) NSInteger delayTimer;
//!!!:只添加了属性，没有写set

@property(nonatomic, assign) NSInteger pmTwoPointFive;
@property(nonatomic, assign) float temperature;
@property(nonatomic, assign) NSInteger humidity;  //湿度
@property(nonatomic, assign) float power;         //功率
@property(nonatomic, strong) NSString *airDesc;   //空气质量说明

@property(nonatomic, assign) long tag;  //记录udp请求发送时的tag

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
                     airDesc:(NSString *)airDesc;

- (instancetype)initWithName:(NSString *)name
                  macAddress:(NSString *)aMacAddress
                      status:(switchStatus)aStatus
                          ip:(NSString *)aIp
                        port:(unsigned short)aPort
                    isLocked:(BOOL)isLocked
                        isOn:(BOOL)isOn
                   timerList:(NSMutableArray *)aTimerList
                   imageName:(NSString *)imageName;

- (instancetype)initWithName:(NSString *)name
                  macAddress:(NSString *)aMacAddress
                      status:(switchStatus)aStatus;

- (UIImage *)getImageByImageName:(NSString *)imageName;
@end
