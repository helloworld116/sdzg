//
//  MessageUtil.h
//  winmin
//
//  Created by sdzg on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageUtil : NSObject
+ (instancetype)shareInstance;

- (void)sendMsg09:(GCDAsyncUdpSocket *)udpSocket;

- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket;

- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;

- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket mac:(NSString *)mac;

- (void)sendMsg11:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn;
- (void)sendMsg13:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn;

- (void)sendMsg17:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg19:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;

- (void)sendMsg1D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList;
- (void)sendMsg1F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList;

- (void)sendMsg25:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg27:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;

- (void)sendMsg39:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on;
- (void)sendMsg3B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on;

- (void)sendMsg3F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name;
- (void)sendMsg41:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name;

- (void)sendMsg47:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock;
- (void)sendMsg49:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock;

- (void)sendMsg4D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on;
- (void)sendMsg4F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on;

- (void)sendMsg53:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg55:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;

- (void)sendMsg59:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch;

/**
 *  手机查询开关状态
 *
 *  @param udpSocket
 *  @param aSwitch
 */
- (void)sendMsg0BOr0D:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg11Or13:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
           isSwitchOn:(BOOL)isSwitchOn;
- (void)sendMsg17Or19:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg1DOr1F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             timeList:(NSArray *)timeList;
- (void)sendMsg25Or27:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch;
- (void)sendMsg39Or3B:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                   on:(BOOL)on;
- (void)sendMsg3FOr41:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                 name:(NSString *)name;
- (void)sendMsg47Or49:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
               isLock:(BOOL)isLock;
- (void)sendMsg4DOr4F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
            delayTime:(NSInteger)delayTime
             switchOn:(BOOL)on;
- (void)sendMsg53Or55:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch;
@end
