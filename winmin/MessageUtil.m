//
//  MessageUtil.m
//  winmin
//
//  Created by sdzg on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MessageUtil.h"
@interface MessageUtil()
@property (atomic,strong) GCDAsyncUdpSocket *udpSocket;
@property (atomic,strong) NSData *msg;
@property (atomic,strong) NSString *host;
@property (atomic,assign) uint16_t port;
@property (atomic,assign) long tag;
@end

@implementation MessageUtil

+(instancetype)shareInstance{
    static MessageUtil *message;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        message = [[MessageUtil alloc] init];
    });
    return message;
}

//-(void)udpSocket:(GCDAsyncUdpSocket *)udpSocket{
////    @synchronized(self.udpSocket){
////        if (!udpSocket) {
////            return;
////        }
////        if (udpSocket.isClosed) {
////            [CC3xUtility setupUdpSocket:udpSocket port:APP_PORT];
////        }
////        self.udpSocket = udpSocket;
////    }
//    if (!udpSocket) {
//        return;
//    }
//    if (udpSocket.isClosed) {
//        [CC3xUtility setupUdpSocket:udpSocket port:APP_PORT];
//    }
//    udpSocket = udpSocket;
//}
//
//-(GCDAsyncUdpSocket *)udpSocket{
//    return nil;
//}

-(void)send{
    [self.udpSocket sendData:self.msg toHost:self.host port:self.port withTimeout:kUDPTimeOut tag:self.tag];
}

-(void)sendMsg09:(GCDAsyncUdpSocket *)udpSocket{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2dMsg09];
    self.host = BROADCAST_ADDRESS;
    self.port = DEVICE_PORT;
    self.tag = P2D_SCAN_DEV_09;
    [self send];
}

-(void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2dMsg0B];
    self.host = BROADCAST_ADDRESS;
    self.port = DEVICE_PORT;
    self.tag = P2D_STATE_INQUIRY_0B;
    [self send];
}

-(void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket mac:(NSString *)mac{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2SMsg0D:mac];
    self.host = SERVER_IP;
    self.port = SERVER_PORT;
    self.tag = P2S_STATE_INQUIRY_0D;
    [self send];
}

-(void)sendMsg11:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isSwitchOn:(BOOL)isSwitchOn{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2dMsg11:!isSwitchOn];
    self.host = aSwitch.ip;
    self.port = aSwitch.port;
    self.tag = P2D_CONTROL_REQ_11;
    [self send];
}

-(void)sendMsg13:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isSwitchOn:(BOOL)isSwitchOn{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2sMsg13:aSwitch.macAddress aSwitch:!isSwitchOn];
    self.host = SERVER_IP;
    self.port = SERVER_PORT;
    self.tag = P2S_CONTROL_REQ_13;
    [self send];
}

-(void)sendMsg47:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isLock:(BOOL)isLock{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2dMsg47:isLock];
    self.host = aSwitch.ip;
    self.port = aSwitch.port;
    self.tag = P2D_DEV_LOCK_REQ_47;
    [self send];
}

-(void)sendMsg49:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isLock:(BOOL)isLock{
    self.udpSocket = udpSocket;
    self.msg = [CC3xMessageUtil getP2sMsg49:aSwitch.macAddress lock:isLock];
    self.host = SERVER_IP;
    self.port = SERVER_PORT;
    self.tag = P2S_DEV_LOCK_REQ_49;
    [self send];
}


-(void)sendMsg11Or13:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isSwitchOn:(BOOL)isSwitchOn{
    //根据不同的网络环境，发送 本地/远程 消息
    if (aSwitch.status == SWITCH_LOCAL || aSwitch.status == SWITCH_LOCAL_LOCK) {
        [self sendMsg11:udpSocket aSwitch:aSwitch isSwitchOn:isSwitchOn];
    } else if (aSwitch.status == SWITCH_REMOTE || aSwitch.status == SWITCH_REMOTE_LOCK) {
        [self sendMsg13:udpSocket aSwitch:aSwitch isSwitchOn:isSwitchOn];
    }
}

-(void)sendMsg47Or49:(GCDAsyncUdpSocket *)udpSocket aSwitch:(CC3xSwitch *)aSwitch isLock:(BOOL)isLock{
    //根据不同的网络环境，发送 本地/远程 消息
    if (aSwitch.status == SWITCH_LOCAL || aSwitch.status == SWITCH_LOCAL_LOCK) {
        [self sendMsg47:udpSocket aSwitch:aSwitch isLock:isLock];
    } else if (aSwitch.status == SWITCH_REMOTE || aSwitch.status == SWITCH_REMOTE_LOCK) {
        [self sendMsg49:udpSocket aSwitch:aSwitch isLock:isLock];
    }
}
@end
