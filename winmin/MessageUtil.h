//
//  MessageUtil.h
//  winmin
//
//  Created by sdzg on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageUtil : NSObject
+(instancetype)shareInstance;
-(void)sendMsg09:(GCDAsyncUdpSocket *)udpSocket;
-(void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket;
-(void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket mac:(NSString *)mac;
-(void)sendMsg11:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isSwitchOn:(BOOL)isSwitchOn;
-(void)sendMsg13:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isSwitchOn:(BOOL)isSwitchOn;
-(void)sendMsg47:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isLock:(BOOL)isLock;
-(void)sendMsg49:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isLock:(BOOL)isLock;
-(void)sendMsg11Or13:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isSwitchOn:(BOOL)isSwitchOn;
-(void)sendMsg47Or49:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isLock:(BOOL)isLock;
@end
