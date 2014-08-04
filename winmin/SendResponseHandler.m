//
//  SendResponseHandler.m
//  winmin
//
//  Created by sdzg on 14-7-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SendResponseHandler.h"

@implementation SendResponseHandler
+ (instancetype)shareInstance {
  static SendResponseHandler *responseHandler;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken,
                ^{ responseHandler = [[SendResponseHandler alloc] init]; });
  return responseHandler;
}

- (void)checkResponseDataAfterSettingIntervalWithTag:(long)tag {
  float delay;
  switch (tag) {
    case P2D_SERVER_INFO_05:
    case P2D_SCAN_DEV_09:
    case P2D_STATE_INQUIRY_0B:
    case P2D_CONTROL_REQ_11:
    case P2D_GET_TIMER_REQ_17:
    case P2D_SET_TIMER_REQ_1D:
    case P2D_GET_PROPERTY_REQ_25:
    case P2D_GET_POWER_INFO_REQ_33:
    case P2D_LOCATE_REQ_39:
    case P2D_SET_NAME_REQ_3F:
    case P2D_DEV_LOCK_REQ_47:
    case P2D_SET_DELAY_REQ_4D:
    case P2D_GET_DELAY_REQ_53:
      delay = kCheckPrivatePrivateResponseInterval;
      break;
    case P2S_STATE_INQUIRY_0D:
    case P2S_CONTROL_REQ_13:
    case P2S_GET_TIMER_REQ_19:
    case P2S_SET_TIMER_REQ_1F:
    case P2S_GET_PROPERTY_REQ_27:
    case P2S_GET_POWER_INFO_REQ_35:
    case P2S_LOCATE_REQ_3B:
    case P2S_SET_NAME_REQ_41:
    case P2S_DEV_LOCK_REQ_49:
    case P2S_SET_DELAY_REQ_4F:
    case P2S_GET_DELAY_REQ_55:
    case P2S_PHONE_INIT_REQ_59:
      delay = kCheckPublicPrivateResponseInterval;
      break;
    default:
      break;
  }
  dispatch_time_t delayInNanoSeconds =
      dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
  dispatch_after(delayInNanoSeconds, GLOBAL_QUEUE,
                 ^{ [self checkWithTag:tag]; });
}

- (void)checkWithTag:(long)tag {
  if (kSharedAppliction.networkStatus != NotReachable) {
    switch (tag) {
      case P2D_SERVER_INFO_05:

        break;
      case P2D_SCAN_DEV_09:
        if (!self.responseDataA) {
          if ([MessageUtil shareInstance].msg9SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgIdA)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg9SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgIdA];
          }
        }
        break;
      case P2D_STATE_INQUIRY_0B:
        if (!self.responseDataC) {
          if (kSharedAppliction.networkStatus == ReachableViaWiFi &&
              [MessageUtil shareInstance].msgBSendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgIdC)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msgBSendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgIdC];
          }
        }
        break;
      case P2S_STATE_INQUIRY_0D:
        if (!self.responseDataE) {
          if ([MessageUtil shareInstance].msgDSendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgIdE)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msgDSendCount + 1);

            [[UdpSocketUtil shareInstance].delegate noResponseMsgIdE];
          }
        }
        break;
      case P2D_CONTROL_REQ_11:
      case P2S_CONTROL_REQ_13:
        if (!self.responseData12Or14) {
          if ([MessageUtil shareInstance].msg11Or13SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId12Or14)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg11Or13SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId12Or14];
          }
        }
        break;
      case P2D_GET_TIMER_REQ_17:
      case P2S_GET_TIMER_REQ_19:
        if (!self.responseData18Or1A) {
          if ([MessageUtil shareInstance].msg17Or19SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId18Or1A)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg17Or19SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId18Or1A];
          }
        }
        break;
      case P2D_SET_TIMER_REQ_1D:
      case P2S_SET_TIMER_REQ_1F:
        if (!self.responseData1EOr20) {
          NSLog(@"tag %ld 重新发送%d次", tag,
                [MessageUtil shareInstance].msg1DOr1FSendCount + 1);
          if ([MessageUtil shareInstance].msg1DOr1FSendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId1EOr20)]) {
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId1EOr20];
          }
        }
        break;
      case P2D_GET_PROPERTY_REQ_25:
      case P2S_GET_PROPERTY_REQ_27:
        if (!self.responseData26Or28) {
          if ([MessageUtil shareInstance].msg25Or27SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId26Or28)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg25Or27SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId26Or28];
          }
        }
        break;
      case P2D_GET_POWER_INFO_REQ_33:
      case P2S_GET_POWER_INFO_REQ_35:
        break;
      case P2D_LOCATE_REQ_39:
      case P2S_LOCATE_REQ_3B:
        if (!self.responseData3AOr3C) {
          if ([MessageUtil shareInstance].msg39Or3BSendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId3AOr3C)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg39Or3BSendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId3AOr3C];
          }
        }
        break;
      case P2D_SET_NAME_REQ_3F:
      case P2S_SET_NAME_REQ_41:
        if (!self.responseData40Or42) {
          if ([MessageUtil shareInstance].msg3FOr41SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId40Or42)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg3FOr41SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId40Or42];
          }
        }
        break;
      case P2D_DEV_LOCK_REQ_47:
      case P2S_DEV_LOCK_REQ_49:
        if (!self.responseData48Or4A) {
          if ([MessageUtil shareInstance].msg47Or49SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId48Or4A)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg47Or49SendCount + 1);

            [[UdpSocketUtil shareInstance].delegate noResponseMsgId48Or4A];
          }
        }
        break;
      case P2D_SET_DELAY_REQ_4D:
      case P2S_SET_DELAY_REQ_4F:
        if (!self.responseData4EOr50) {
          if ([MessageUtil shareInstance].msg4DOr4FSendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId4EOr50)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg4DOr4FSendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId4EOr50];
          }
        }
        break;
      case P2D_GET_DELAY_REQ_53:
      case P2S_GET_DELAY_REQ_55:
        if (!self.responseData54Or56) {
          if ([MessageUtil shareInstance].msg53Or55SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId54Or56)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg53Or55SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId54Or56];
          }
        }
        break;
      case P2S_PHONE_INIT_REQ_59:
        if (!self.responseData5A) {
          if ([MessageUtil shareInstance].msg59SendCount < kTryCount &&
              [[UdpSocketUtil shareInstance].delegate
                  respondsToSelector:@selector(noResponseMsgId5A)]) {
            NSLog(@"tag %ld 重新发送%d次", tag,
                  [MessageUtil shareInstance].msg59SendCount + 1);
            [[UdpSocketUtil shareInstance].delegate noResponseMsgId5A];
          }
        }
        break;

      default:
        break;
    }
  }
}
@end
