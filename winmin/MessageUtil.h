//
//  MessageUtil.h
//  winmin
//
//  Created by sdzg on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageUtil : NSObject
typedef enum { ActiveMode, PassiveMode } SENDMODE;
@property(atomic, assign) NSUInteger msg9SendCount;
@property(atomic, assign) NSUInteger msgBSendCount;
@property(atomic, assign) NSUInteger msgDSendCount;
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

- (void)sendMsg09:(GCDAsyncUdpSocket *)udpSocket sendMode:(SENDMODE)mode;

- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket sendMode:(SENDMODE)mode;

- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
              mac:(NSString *)mac
         sendMode:(SENDMODE)mode;

- (void)sendMsg11:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn
         sendMode:(SENDMODE)mode;
- (void)sendMsg13:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn
         sendMode:(SENDMODE)mode;

- (void)sendMsg17:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
- (void)sendMsg19:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

- (void)sendMsg1D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList
         sendMode:(SENDMODE)mode;
- (void)sendMsg1F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList
         sendMode:(SENDMODE)mode;

- (void)sendMsg25:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
- (void)sendMsg27:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

- (void)sendMsg39:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on
         sendMode:(SENDMODE)mode;
- (void)sendMsg3B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on
         sendMode:(SENDMODE)mode;

- (void)sendMsg3F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name
         sendMode:(SENDMODE)mode;
- (void)sendMsg41:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name
         sendMode:(SENDMODE)mode;

- (void)sendMsg47:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock
         sendMode:(SENDMODE)mode;
- (void)sendMsg49:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock
         sendMode:(SENDMODE)mode;

- (void)sendMsg4D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on
         sendMode:(SENDMODE)mode;
- (void)sendMsg4F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on
         sendMode:(SENDMODE)mode;

- (void)sendMsg53:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;
- (void)sendMsg55:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

- (void)sendMsg59:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode;

/**
 *  手机查询开关状态
 *
 *  @param udpSocket
 *  @param aSwitch
 */
- (void)sendMsg0BOr0D:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
- (void)sendMsg11Or13:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
           isSwitchOn:(BOOL)isSwitchOn
             sendMode:(SENDMODE)mode;
- (void)sendMsg17Or19:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
- (void)sendMsg1DOr1F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             timeList:(NSArray *)timeList
             sendMode:(SENDMODE)mode;
- (void)sendMsg25Or27:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
- (void)sendMsg39Or3B:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                   on:(BOOL)on
             sendMode:(SENDMODE)mode;
- (void)sendMsg3FOr41:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                 name:(NSString *)name
             sendMode:(SENDMODE)mode;
- (void)sendMsg47Or49:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
               isLock:(BOOL)isLock
             sendMode:(SENDMODE)mode;
- (void)sendMsg4DOr4F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
            delayTime:(NSInteger)delayTime
             switchOn:(BOOL)on
             sendMode:(SENDMODE)mode;
- (void)sendMsg53Or55:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode;
@end
