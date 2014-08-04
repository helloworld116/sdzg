//
//  MessageUtil.m
//  winmin
//
//  Created by sdzg on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MessageUtil.h"
@interface MessageUtil ()
@property(nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property(atomic, strong) NSData *msg;
@property(atomic, strong) NSString *host;
@property(atomic, assign) uint16_t port;
@property(atomic, assign) long tag;
@end

@implementation MessageUtil

+ (instancetype)shareInstance {
  static MessageUtil *message;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ message = [[MessageUtil alloc] init]; });
  return message;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)socket {
  if (!socket) {
    return;
  }
  //  if (socket.isClosed) {
  //    [CC3xUtility setupUdpSocket:socket port:APP_PORT];
  //  }
  _udpSocket = socket;
}

- (void)send {
  if (self.udpSocket.isClosed) {
    [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
  }
  [self.udpSocket sendData:self.msg
                    toHost:self.host
                      port:self.port
               withTimeout:kUDPTimeOut
                       tag:self.tag];
}

- (void)sendMsg09:(GCDAsyncUdpSocket *)udpSocket sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        if (mode == ActiveMode) {
          self.msg9SendCount = 0;
        } else if (mode == PassiveMode) {
          self.msg9SendCount++;
        }
        self.udpSocket = udpSocket;
        self.msg = [CC3xMessageUtil getP2dMsg09];
        self.host = BROADCAST_ADDRESS;
        self.port = DEVICE_PORT;
        self.tag = P2D_SCAN_DEV_09;
        [self send];
      } else {
        //不在内网的情况下的处理
      }
  });
}

- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        if (mode == ActiveMode) {
          self.msgBSendCount = 0;
        } else if (mode == PassiveMode) {
          self.msgBSendCount++;
        }
        self.udpSocket = udpSocket;
        self.msg = [CC3xMessageUtil getP2dMsg0B];
        self.host = BROADCAST_ADDRESS;
        self.port = DEVICE_PORT;
        self.tag = P2D_STATE_INQUIRY_0B;
        [self send];
      } else {
        //不在内网的情况下的处理
      }
  });
}

- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
              mac:(NSString *)mac
         sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      } else {
        if (mode == ActiveMode) {
          self.msgDSendCount = 0;
        } else if (mode == PassiveMode) {
          self.msgDSendCount++;
        }
        self.udpSocket = udpSocket;
        self.msg = [CC3xMessageUtil getP2SMsg0D:mac];
        self.host = SERVER_IP;
        self.port = SERVER_PORT;
        self.tag = P2S_STATE_INQUIRY_0D;
        [self send];
      }
  });
}

- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
              mac:(NSString *)mac
         sendMode:(SENDMODE)mode
              tag:(long)tag {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      } else {
        if (mode == ActiveMode) {
          [self.msgDSendCountDict setObject:@(0) forKey:mac];
        } else if (mode == PassiveMode) {
          int count = [[self.msgDSendCountDict objectForKey:mac] intValue];
          count++;
          [self.msgDSendCountDict setObject:@(count) forKey:mac];
        }
        self.udpSocket = udpSocket;
        self.msg = [CC3xMessageUtil getP2SMsg0D:mac];
        self.host = SERVER_IP;
        self.port = SERVER_PORT;
        self.tag = tag;
        [self send];
      }
  });
}

- (void)sendMsg0B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msgBOrDSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msgBOrDSendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg0B];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_STATE_INQUIRY_0B;
  [self send];
}

- (void)sendMsg0D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msgBOrDSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msgBOrDSendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2SMsg0D:aSwitch.macAddress];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_STATE_INQUIRY_0D;
  [self send];
}

- (void)sendMsg11:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg11Or13SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg11Or13SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg11:!isSwitchOn];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_CONTROL_REQ_11;
  [self send];
}

- (void)sendMsg13:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
       isSwitchOn:(BOOL)isSwitchOn
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg11Or13SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg11Or13SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg =
      [CC3xMessageUtil getP2sMsg13:aSwitch.macAddress aSwitch:!isSwitchOn];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_CONTROL_REQ_13;
  [self send];
}

- (void)sendMsg17:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg17Or19SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg17Or19SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg17];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_TIMER_REQ_17;
  [self send];
}

- (void)sendMsg19:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg17Or19SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg17Or19SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2SMsg19:aSwitch.macAddress];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_TIMER_REQ_19;
  [self send];
}

- (void)sendMsg1D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg1DOr1FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg1DOr1FSendCount++;
  }
  //获取公历日期,相对的当前时间
  NSCalendar *gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps =
      [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit |
                            NSMinuteCalendarUnit
                   fromDate:[NSDate date]];
  int weekday = ([comps weekday] + 5) % 7;
  int hour = (int)[comps hour];
  int min = (int)[comps minute];
  //获取当前时间离本周一0点开始的秒数
  NSInteger currentTime = weekday * 24 * 3600 + hour * 3600 + min * 60;
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg1D:currentTime
                                 timerNum:timeList.count
                                timerList:timeList];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_SET_TIMER_REQ_1D;
  [self send];
}

- (void)sendMsg1F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         timeList:(NSArray *)timeList
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg1DOr1FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg1DOr1FSendCount++;
  }
  //获取公历日期,相对的当前时间
  NSCalendar *gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps =
      [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit |
                            NSMinuteCalendarUnit
                   fromDate:[NSDate date]];
  int weekday = ([comps weekday] + 5) % 7;
  int hour = (int)[comps hour];
  int min = (int)[comps minute];
  //获取当前时间离本周一0点开始的秒数
  NSInteger currentTime = weekday * 24 * 3600 + hour * 3600 + min * 60;
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2SMsg1F:currentTime
                                 timerNum:timeList.count
                                timerList:timeList
                                      mac:aSwitch.macAddress];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_SET_TIMER_REQ_1F;
  [self send];
}

- (void)sendMsg25:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg25Or27SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg25Or27SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg25];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_PROPERTY_REQ_25;
  [self send];
}

- (void)sendMsg27:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg25Or27SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg25Or27SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2SMsg27:aSwitch.macAddress];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_PROPERTY_REQ_27;
  [self send];
}

- (void)sendMsg39:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg39Or3BSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg39Or3BSendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg39:on];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_LOCATE_REQ_39;
  [self send];
}

- (void)sendMsg3B:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
               on:(BOOL)on
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg39Or3BSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg39Or3BSendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2SMsg3B:aSwitch.macAddress on:on];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_LOCATE_REQ_3B;
  [self send];
}

- (void)sendMsg3F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg3FOr41SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg3FOr41SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg3F:name];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_SET_NAME_REQ_3F;
  [self send];
}

- (void)sendMsg41:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
             name:(NSString *)name
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg3FOr41SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg3FOr41SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2sMsg41:aSwitch.macAddress name:name];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_SET_NAME_REQ_41;
  [self send];
}

- (void)sendMsg47:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg47Or49SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg47Or49SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg47:!isLock];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_DEV_LOCK_REQ_47;
  [self send];
}

- (void)sendMsg49:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
           isLock:(BOOL)isLock
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg47Or49SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg47Or49SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2sMsg49:aSwitch.macAddress lock:!isLock];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_DEV_LOCK_REQ_49;
  [self send];
}

- (void)sendMsg4D:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg4DOr4FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg4DOr4FSendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg4D:delayTime on:on];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_SET_DELAY_REQ_4D;
  [self send];
}

- (void)sendMsg4F:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
        delayTime:(NSInteger)delayTime
         switchOn:(BOOL)on
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg4DOr4FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg4DOr4FSendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg =
      [CC3xMessageUtil getP2SMsg4F:aSwitch.macAddress delay:delayTime on:on];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_SET_DELAY_REQ_4F;
  [self send];
}

- (void)sendMsg53:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg53Or55SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg53Or55SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2dMsg53];
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_DELAY_REQ_53;
  [self send];
}

- (void)sendMsg55:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg53Or55SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg53Or55SendCount++;
  }
  self.udpSocket = udpSocket;
  self.msg = [CC3xMessageUtil getP2SMsg55:aSwitch.macAddress];
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_DELAY_REQ_55;
  [self send];
}

- (void)sendMsg59:(GCDAsyncUdpSocket *)udpSocket
          aSwitch:(CC3xSwitch *)aSwitch
         sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (mode == ActiveMode) {
        self.msg59SendCount = 0;
      } else if (mode == PassiveMode) {
        self.msg59SendCount++;
      }
      self.udpSocket = udpSocket;
      self.msg = [CC3xMessageUtil getP2SMsg59:aSwitch.macAddress];
      self.host = SERVER_IP;
      self.port = SERVER_PORT;
      self.tag = P2S_PHONE_INIT_REQ_59;
      [self send];
  });
}

#pragma mark 区分内网和外网处理
- (void)sendMsg0BOr0D:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg0B:udpSocket aSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg0D:udpSocket aSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg0D:udpSocket aSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg11Or13:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
           isSwitchOn:(BOOL)isSwitchOn
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg11:udpSocket
                  aSwitch:aSwitch
               isSwitchOn:isSwitchOn
                 sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg13:udpSocket
                  aSwitch:aSwitch
               isSwitchOn:isSwitchOn
                 sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg13:udpSocket
                aSwitch:aSwitch
             isSwitchOn:isSwitchOn
               sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg17Or19:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg17:udpSocket aSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg19:udpSocket aSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg19:udpSocket aSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg1DOr1F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             timeList:(NSArray *)timeList
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg1D:udpSocket
                  aSwitch:aSwitch
                 timeList:timeList
                 sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg1F:udpSocket
                  aSwitch:aSwitch
                 timeList:timeList
                 sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg1F:udpSocket
                aSwitch:aSwitch
               timeList:timeList
               sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg25Or27:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg25:udpSocket aSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg27:udpSocket aSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg27:udpSocket aSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg39Or3B:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                   on:(BOOL)on
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg39:udpSocket aSwitch:aSwitch on:on sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg3B:udpSocket aSwitch:aSwitch on:on sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg3B:udpSocket aSwitch:aSwitch on:on sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg3FOr41:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
                 name:(NSString *)name
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg3F:udpSocket aSwitch:aSwitch name:name sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg41:udpSocket aSwitch:aSwitch name:name sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg41:udpSocket aSwitch:aSwitch name:name sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg47Or49:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
               isLock:(BOOL)isLock
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg47:udpSocket
                  aSwitch:aSwitch
                   isLock:isLock
                 sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg49:udpSocket
                  aSwitch:aSwitch
                   isLock:isLock
                 sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg49:udpSocket aSwitch:aSwitch isLock:isLock sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg4DOr4F:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
            delayTime:(NSInteger)delayTime
             switchOn:(BOOL)on
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg4D:udpSocket
                  aSwitch:aSwitch
                delayTime:delayTime
                 switchOn:on
                 sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg4F:udpSocket
                  aSwitch:aSwitch
                delayTime:delayTime
                 switchOn:on
                 sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg4F:udpSocket
                aSwitch:aSwitch
              delayTime:delayTime
               switchOn:on
               sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}

- (void)sendMsg53Or55:(GCDAsyncUdpSocket *)udpSocket
              aSwitch:(CC3xSwitch *)aSwitch
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
          [self sendMsg53:udpSocket aSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.status == SWITCH_REMOTE ||
                   aSwitch.status == SWITCH_REMOTE_LOCK) {
          [self sendMsg55:udpSocket aSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg55:udpSocket aSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNotReachableNotification
                          object:self
                        userInfo:@{
                          @"NetworkStatus" : @(NotReachable)
                        }];
      }
  });
}
@end
