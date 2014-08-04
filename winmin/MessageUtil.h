//
//  MessageUtil.h
//  winmin
//
//  Created by sdzg on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kNotReachableNotification @"NotReachableNotification"

@interface MessageUtil : NSObject
typedef enum { ActiveMode, PassiveMode } SENDMODE;
@property(atomic, assign) NSUInteger msg9SendCount;
@property(atomic, assign) NSUInteger msgBSendCount;
@property(atomic, assign) NSUInteger msgDSendCount;
@property(atomic, strong) NSMutableDictionary *msgDSendCountDict;
@property(atomic, assign) NSUInteger msgBOrDSendCount;
@property(atomic, assign) NSUInteger msg11Or13SendCount;
@property(atomic, assign) NSUInteger msg17Or19SendCount;
@property(atomic, assign) NSUInteger msg1DOr1FSendCount;
@property(atomic, assign) NSUInteger msg25Or27SendCount;
@property(atomic, assign) NSUInteger msg39Or3BSendCount;
@property(atomic, assign) NSUInteger msg3FOr41SendCount;
@property(atomic, assign) NSUInteger msg47Or49SendCount;
@property(atomic, assign) NSUInteger msg4DOr4FSendCount;
@property(atomic, assign) NSUInteger msg53Or55SendCount;
@property(atomic, assign) NSUInteger msg59SendCount;

+ (instancetype)shareInstance;

/**
 *  手机添加设备
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg09:(GCDAsyncUdpSocket *)udpSocket sendMode:(SENDMODE)mode;

/**
 *  手机向内网查询设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket sendMode:(SENDMODE)mode;
/**
 *  手机向内网查询设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
/**
 *  手机向外网查询设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
/**
 *  手机向外网查询设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
              mac:(NSString *)mac
         sendMode:(SENDMODE)mode;

/**
 *  手机向内网控制开关“开或关”
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isSwitchOn 开关当前状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg11:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn
         sendMode:(SENDMODE)mode;
/**
 *  手机向外网控制开关“开或关”
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isSwitchOn 开关当前状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg13:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn
         sendMode:(SENDMODE)mode;

/**
 *  手机向内网获取设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg17:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
/**
 *  手机向外网获取设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg19:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

/**
 *  手机向内网设置设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param timeList  定时列表集合
 *  @param mode
 */
- (void)sendMsg1D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList
         sendMode:(SENDMODE)mode;
/**
 *  手机向外网设置设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param timeList  定时列表集合
 *  @param mode
 */
- (void)sendMsg1F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList
         sendMode:(SENDMODE)mode;

/**
 *  手机向内网获取设备控制权限
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg25:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
/**
 *  手机向外网获取设备控制权限
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg27:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

/**
 *  内网发送指令，设备定位，即使设备灯闪烁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param on        定位标识，目前只有1，表示定位
 *  @param mode
 */
- (void)sendMsg39:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on
         sendMode:(SENDMODE)mode;
/**
 *  外网发送指令，设备定位，即使设备灯闪烁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param on        定位标识，目前只有1，表示定位
 *  @param mode
 */
- (void)sendMsg3B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on
         sendMode:(SENDMODE)mode;

/**
 *  内网设置设备名称
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param name      设备名称
 *  @param mode
 */
- (void)sendMsg3F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name
         sendMode:(SENDMODE)mode;
/**
 *  外网设置设备名称
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param name      设备名称
 *  @param mode
 */
- (void)sendMsg41:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name
         sendMode:(SENDMODE)mode;

/**
 *  内网发指令使设备加锁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isLock    设备当前的锁定状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg47:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock
         sendMode:(SENDMODE)mode;
/**
 *  外网发指令使设备加锁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isLock    设备当前的锁定状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg49:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock
         sendMode:(SENDMODE)mode;

/**
 *  内网设置设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param delayTime 延时时间，单位分钟
 *  @param on        0x1表示开，0x0表示关
 *  @param mode
 */
- (void)sendMsg4D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on
         sendMode:(SENDMODE)mode;
/**
 *  外网设置设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param delayTime 延时时间，单位分钟
 *  @param on        0x1表示开，0x0表示关
 *  @param mode
 */
- (void)sendMsg4F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on
         sendMode:(SENDMODE)mode;

/**
 *  内网查询设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg53:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
/**
 *  外网查询设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg55:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

/**
 *  手机开机上报基本信息
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg59:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

/**
 *  手机查询开关状态
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg0BOr0D:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
/**
 *  手机控制开关“开或关”
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isSwitchOn 开关当前状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg11Or13:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
           isSwitchOn:(BOOL)isSwitchOn
             sendMode:(SENDMODE)mode;
/**
 *  手机获取设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg17Or19:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
/**
 *  手机设置设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param timeList  定时列表集合
 *  @param mode
 */
- (void)sendMsg1DOr1F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             timeList:(NSArray *)timeList
             sendMode:(SENDMODE)mode;
/**
 *  手机获取设备控制权限
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg25Or27:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
/**
 *  设备定位，即使设备灯闪烁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param on        定位标识，目前只有1，表示定位
 *  @param mode
 */
- (void)sendMsg39Or3B:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                   on:(BOOL)on
             sendMode:(SENDMODE)mode;
/**
 *  设置设备名称
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param name      设备名称
 *  @param mode
 */
- (void)sendMsg3FOr41:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                 name:(NSString *)name
             sendMode:(SENDMODE)mode;
/**
 *  设备加锁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isLock    设备当前的锁定状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg47Or49:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
               isLock:(BOOL)isLock
             sendMode:(SENDMODE)mode;
/**
 *  设置设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param delayTime 延时时间，单位分钟
 *  @param on        0x1表示开，0x0表示关
 *  @param mode
 */
- (void)sendMsg4DOr4F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
            delayTime:(NSInteger)delayTime
             switchOn:(BOOL)on
             sendMode:(SENDMODE)mode;
/**
 *  查询设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg53Or55:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
@end
