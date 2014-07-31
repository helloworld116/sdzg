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
  static UdpSocketUtil* udpSocketUtil;
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
- (void)udpSocket:(GCDAsyncUdpSocket*)sock
    didConnectToAddress:(NSData*)address {
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
- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotConnect:(NSError*)error {
  NSLog(@"didNotConnect");
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket*)sock didSendDataWithTag:(long)tag {
  NSLog(@"didSendDataWithTag :%ld", tag);
  //需要执行的操作：
  // 1、清空响应数据
  // 2、指定时间后检查数据是否为空，为空说明未响应，触发请求重发
  switch (tag) {
    case P2D_SERVER_INFO_05:

      break;
    case P2D_SCAN_DEV_09:
      [SendResponseHandler shareInstance].responseDataA = nil;
      break;
    case P2D_STATE_INQUIRY_0B:
      [SendResponseHandler shareInstance].responseDataC = nil;
      break;
    case P2S_STATE_INQUIRY_0D:
      [SendResponseHandler shareInstance].responseDataE = nil;
      break;
    case P2D_CONTROL_REQ_11:
    case P2S_CONTROL_REQ_13:
      [SendResponseHandler shareInstance].responseData12Or14 = nil;
      break;
    case P2D_GET_TIMER_REQ_17:
    case P2S_GET_TIMER_REQ_19:
      [SendResponseHandler shareInstance].responseData18Or1A = nil;
      break;
    case P2D_SET_TIMER_REQ_1D:
    case P2S_SET_TIMER_REQ_1F:
      [SendResponseHandler shareInstance].responseData1EOr20 = nil;
      break;
    case P2D_GET_PROPERTY_REQ_25:
    case P2S_GET_PROPERTY_REQ_27:
      [SendResponseHandler shareInstance].responseData26Or28 = nil;
      break;
    case P2D_GET_POWER_INFO_REQ_33:
    case P2S_GET_POWER_INFO_REQ_35:
      break;
    case P2D_LOCATE_REQ_39:
    case P2S_LOCATE_REQ_3B:
      [SendResponseHandler shareInstance].responseData3AOr3C = nil;
      break;
    case P2D_SET_NAME_REQ_3F:
    case P2S_SET_NAME_REQ_41:
      [SendResponseHandler shareInstance].responseData40Or42 = nil;
      break;
    case P2D_DEV_LOCK_REQ_47:
    case P2S_DEV_LOCK_REQ_49:
      [SendResponseHandler shareInstance].responseData48Or4A = nil;
      break;
    case P2D_SET_DELAY_REQ_4D:
    case P2S_SET_DELAY_REQ_4F:
      [SendResponseHandler shareInstance].responseData4EOr50 = nil;
      break;
    case P2D_GET_DELAY_REQ_53:
    case P2S_GET_DELAY_REQ_55:
      [SendResponseHandler shareInstance].responseData54Or56 = nil;
      break;
    case P2S_PHONE_INIT_REQ_59:
      [SendResponseHandler shareInstance].responseData5A = nil;
      break;

    default:
      break;
  }
  [[SendResponseHandler shareInstance]
      checkResponseDataAfterSettingIntervalWithTag:tag];
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data
 *being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket*)sock
    didNotSendDataWithTag:(long)tag
               dueToError:(NSError*)error {
  NSLog(@"didNotSendDataWithTag :%ld", tag);
  switch (tag) {
    case P2D_SERVER_INFO_05:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId5)]) {
        [self.delegate noSendMsgId5];
      }
      break;
    case P2D_SCAN_DEV_09:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId9)]) {
        [self.delegate noSendMsgId9];
      }
      break;
    case P2D_STATE_INQUIRY_0B:
      if ([self.delegate respondsToSelector:@selector(noSendMsgIdB)]) {
        [self.delegate noSendMsgIdB];
      }
      break;
    case P2S_STATE_INQUIRY_0D:
      if ([self.delegate respondsToSelector:@selector(noSendMsgIdD)]) {
        [self.delegate noSendMsgIdD];
      }
      break;
    case P2D_CONTROL_REQ_11:
    case P2S_CONTROL_REQ_13:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId11Or13)]) {
        [self.delegate noSendMsgId11Or13];
      }
      break;
    case P2D_GET_TIMER_REQ_17:
    case P2S_GET_TIMER_REQ_19:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId17Or19)]) {
        [self.delegate noSendMsgId17Or19];
      }
      break;
    case P2D_SET_TIMER_REQ_1D:
    case P2S_SET_TIMER_REQ_1F:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId1DOr1F)]) {
        [self.delegate noSendMsgId1DOr1F];
      }
      break;
    case P2D_GET_PROPERTY_REQ_25:
    case P2S_GET_PROPERTY_REQ_27:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId25Or27)]) {
        [self.delegate noSendMsgId25Or27];
      }
      break;
    case P2D_GET_POWER_INFO_REQ_33:
    case P2S_GET_POWER_INFO_REQ_35:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId33Or35)]) {
        [self.delegate noSendMsgId33Or35];
      }
      break;
    case P2D_LOCATE_REQ_39:
    case P2S_LOCATE_REQ_3B:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId39Or3B)]) {
        [self.delegate noSendMsgId39Or3B];
      }
      break;
    case P2D_SET_NAME_REQ_3F:
    case P2S_SET_NAME_REQ_41:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId3FOr41)]) {
        [self.delegate noSendMsgId3FOr41];
      }
      break;
    case P2D_DEV_LOCK_REQ_47:
    case P2S_DEV_LOCK_REQ_49:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId47Or49)]) {
        [self.delegate noSendMsgId47Or49];
      }
      break;
    case P2D_SET_DELAY_REQ_4D:
    case P2S_SET_DELAY_REQ_4F:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId4DOr4F)]) {
        [self.delegate noSendMsgId4DOr4F];
      }
      break;
    case P2D_GET_DELAY_REQ_53:
    case P2S_GET_DELAY_REQ_55:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId53Or55)]) {
        [self.delegate noSendMsgId53Or55];
      }
      break;
    case P2S_PHONE_INIT_REQ_59:
      if ([self.delegate respondsToSelector:@selector(noSendMsgId59)]) {
        [self.delegate noSendMsgId59];
      }
      break;

    default:
      break;
  }
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket*)sock
       didReceiveData:(NSData*)data
          fromAddress:(NSData*)address
    withFilterContext:(id)filterContext {
  NSLog(@"receiveData is %@", [CC3xMessageUtil hexString:data]);
  if (data) {
    CC3xMessage* msg = (CC3xMessage*)filterContext;
    switch (msg.msgId) {
      case 0xa:
        [SendResponseHandler shareInstance].responseDataA = data;
        if ([self.delegate respondsToSelector:@selector(responseMsgIdA:)]) {
          [self.delegate responseMsgIdA:msg];
        }
        break;
      case 0xc:
        [SendResponseHandler shareInstance].responseDataC = data;
        if ([self.delegate respondsToSelector:@selector(responseMsgIdC:)]) {
          [self.delegate responseMsgIdC:msg];
        }
        break;
      case 0xe:
        [SendResponseHandler shareInstance].responseDataE = data;
        if ([self.delegate respondsToSelector:@selector(responseMsgIdE:)]) {
          [self.delegate responseMsgIdE:msg];
        }
        break;
      case 0x12:
      case 0x14:
        [SendResponseHandler shareInstance].responseData12Or14 = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId12Or14:)]) {
          [self.delegate responseMsgId12Or14:msg];
        }
        break;
      case 0x18:
      case 0x1a:
        [SendResponseHandler shareInstance].responseData18Or1A = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId18Or1A:)]) {
          [self.delegate responseMsgId18Or1A:msg];
        }
        break;
      case 0x1e:
      case 0x20:
        [SendResponseHandler shareInstance].responseData1EOr20 = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId1EOr20:)]) {
          [self.delegate responseMsgId1EOr20:msg];
        }
        break;
      case 0x26:
      case 0x28:
        [SendResponseHandler shareInstance].responseData26Or28 = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId26Or28:)]) {
          [self.delegate responseMsgId26Or28:msg];
        }
        break;
      case 0x3A:
      case 0x3C:
        [SendResponseHandler shareInstance].responseData3AOr3C = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId3AOr3C:)]) {
          [self.delegate responseMsgId3AOr3C:msg];
        }
        break;
      case 0x40:
      case 0x42:
        [SendResponseHandler shareInstance].responseData40Or42 = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId40Or42:)]) {
          [self.delegate responseMsgId40Or42:msg];
        }
        break;
      case 0x48:
      case 0x4a:
        [SendResponseHandler shareInstance].responseData48Or4A = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId48Or4A:)]) {
          [self.delegate responseMsgId48Or4A:msg];
        }
        break;
      case 0x4e:
      case 0x50:
        [SendResponseHandler shareInstance].responseData4EOr50 = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId4EOr50:)]) {
          [self.delegate responseMsgId4EOr50:msg];
        }
        break;
      case 0x54:
      case 0x56:
        [SendResponseHandler shareInstance].responseData54Or56 = data;
        if ([self.delegate
                respondsToSelector:@selector(responseMsgId54Or56:)]) {
          [self.delegate responseMsgId54Or56:msg];
        }
        break;
      case 0x5a:
        [SendResponseHandler shareInstance].responseData5A = data;
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
- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock withError:(NSError*)error {
  NSLog(@"UdpSocketUtil udpSocketDidClose");
}

@end