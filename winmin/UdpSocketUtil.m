//
//  UdpSocketUtil.m
//  winmin
//
//  Created by 文正光 on 14-7-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "UdpSocketUtil.h"
@interface UdpSocketUtil ()<GCDAsyncUdpSocketDelegate>

@end

@implementation UdpSocketUtil
- (id)init {
  self = [super init];
  if (self) {
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                   delegateQueue:GLOBAL_QUEUE];
    [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
  }
  return self;
}

+ (instancetype)shareInstance {
  static UdpSocketUtil *udpSocketUtil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ udpSocketUtil = [[UdpSocketUtil alloc] init]; });
  return udpSocketUtil;
}

#pragma mark UDP Delegate
/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for
 *reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the
 *connection is successful.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
    didConnectToAddress:(NSData *)address {
  NSLog(@"didConnectToAddress");
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for
 *reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the
 *connection fails.
 * This may happen, for example, if a domain name is given for the host and the
 *domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
  NSLog(@"didNotConnect");
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
  NSLog(@"didSendDataWithTag :%ld", tag);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data
 *being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
    didNotSendDataWithTag:(long)tag
               dueToError:(NSError *)error {
  NSLog(@"didNotSendDataWithTag :%ld", tag);
  switch (tag) {
    case P2D_SERVER_INFO_05:

      break;
    case P2D_SCAN_DEV_09:

      break;
    case P2D_STATE_INQUIRY_0B:

      break;
    case P2S_STATE_INQUIRY_0D:

      break;
    case P2D_CONTROL_REQ_11:

      break;
    case P2S_CONTROL_REQ_13:

      break;
    case P2D_GET_TIMER_REQ_17:

      break;
    case P2S_GET_TIMER_REQ_19:

      break;
    case P2D_SET_TIMER_REQ_1D:

      break;
    case P2S_SET_TIMER_REQ_1F:

      break;
    case P2D_GET_PROPERTY_REQ_25:

      break;
    case P2S_GET_PROPERTY_REQ_27:

      break;
    case P2D_GET_POWER_INFO_REQ_33:

      break;
    case P2S_GET_POWER_INFO_REQ_35:

      break;
    case P2D_LOCATE_REQ_39:

      break;
    case P2S_LOCATE_REQ_3B:

      break;
    case P2D_SET_NAME_REQ_3F:

      break;
    case P2S_SET_NAME_REQ_41:

      break;
    case P2D_DEV_LOCK_REQ_47:

      break;
    case P2S_DEV_LOCK_REQ_49:

      break;
    case P2D_SET_DELAY_REQ_4D:

      break;
    case P2S_SET_DELAY_REQ_4F:

      break;
    case P2D_GET_DELAY_REQ_53:

      break;
    case P2S_GET_DELAY_REQ_55:

      break;
    case P2S_PHONE_INIT_REQ_59:

      break;

    default:
      break;
  }
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
       didReceiveData:(NSData *)data
          fromAddress:(NSData *)address
    withFilterContext:(id)filterContext {
  NSLog(@"receiveData is %@", [CC3xMessageUtil hexString:data]);
  if (data) {
    CC3xMessage *msg = (CC3xMessage *)filterContext;
    switch (msg.msgId) {
      case 0xa:
        if ([self.delegate respondsToSelector:@selector(responseMsgIdA:)]) {
          [self.delegate responseMsgIdA:msg];
        }
        break;
      case 0xc:
      case 0xe:
        if ([self.delegate respondsToSelector:@selector(responseMsgIdCOrE:)]) {
          [self.delegate responseMsgIdCOrE:msg];
        }
        break;
      case 0x12:
      case 0x14:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId12Or14:)]) {
          [self.delegate responseMsgId12Or14:msg];
        }
        break;
      case 0x18:
      case 0x1a:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId18Or1A:)]) {
          [self.delegate responseMsgId18Or1A:msg];
        }
        break;
      case 0x1e:
      case 0x20:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId1EOr20:)]) {
          [self.delegate responseMsgId1EOr20:msg];
        }
        break;
      case 0x26:
      case 0x28:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId26Or28:)]) {
          [self.delegate responseMsgId26Or28:msg];
        }
        break;
      case 0x3A:
      case 0x3C:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId3AOr3C:)]) {
          [self.delegate responseMsgId3AOr3C:msg];
        }
        break;
      case 0x40:
      case 0x42:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId40Or42:)]) {
          [self.delegate responseMsgId40Or42:msg];
        }
        break;
      case 0x4e:
      case 0x50:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId4EOr50:)]) {
          [self.delegate responseMsgId4EOr50:msg];
        }
        break;
      case 0x54:
      case 0x56:
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId54Or56:)]) {
          [self.delegate responseMsgId54Or56:msg];
        }
        break;
      case 0x5a:
        if ([self.delegate respondsToSelector:@selector(responseMsgId5A:)]) {
          [self.delegate responseMsgId5A:msg];
        }
        break;
      default:
        break;
    }
  }
}
/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
  NSLog(@"UdpSocketUtil udpSocketDidClose");
}

@end