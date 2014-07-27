//
//  DevicesProfileVC.m
//  winmin
//
//  Created by sdzg on 14-7-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DevicesProfileVC.h"
#import "EditController.h"
#import "TimerController.h"
#import "DelayController.h"
#define kRefreshIntveral 3

@interface DevicesProfileVC ()<ResponseDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imgViewBackground;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewLight;

@property (strong, nonatomic) IBOutlet UIImageView *imgViewPreExec1;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewPreExec2;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewPreExec3;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewPreExec4;
@property (strong, nonatomic) IBOutlet UILabel *lblPreExecInfo;

@property (strong, nonatomic) IBOutlet UIImageView *imgViewDelay1;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewDelay2;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewDelay3;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewDelay4;
@property (strong, nonatomic) IBOutlet UILabel *lblDelayInfo;

@property (strong, nonatomic) IBOutlet UIImageView *imgViewOperation;

@property (strong, atomic) GCDAsyncUdpSocket *udpSocket;
@property (assign, nonatomic) BOOL isSwitchOn; //设备是否打开
@property (assign, atomic) BOOL isLockOK;

//延迟相关量
@property (strong, nonatomic) NSTimer *delayTimer; //延迟操作
@property (nonatomic, assign) NSInteger delayTime; //延迟时间，单位分钟
@property (nonatomic, assign) BOOL delayIsOn;      //延迟操作是开还是关

//定时列表相关量
@property (nonatomic, strong) NSArray *timeTaskList;

@property (strong, nonatomic) NSTimer *refreshTimer; //开关状态timer

- (IBAction)showPreExecPage:(id)sender;
- (IBAction)showDelayPage:(id)sender;
- (IBAction)showEditPage:(id)sender;
- (IBAction)changeState:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)refresh:(id)sender;
@end

@implementation DevicesProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navigationItem.title = self.aSwitch.switchName;
  self.isSwitchOn = self.aSwitch.isOn;
  [self changeOutwardBySwitchState:self.isSwitchOn];
  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [UdpSocketUtil shareInstance].delegate = self;
  //初始化udpsocket,绑定接收端口
  //  self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
  //                                                 delegateQueue:GLOBAL_QUEUE];
  //  [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];

  //根据不同的网络环境，发送 本地/远程 消息
  //定时列表
  //  dispatch_async(GLOBAL_QUEUE, ^{
  //根据不同的网络环境，发送 本地/远程 消息
  //      if (self.aSwitch.status == SWITCH_LOCAL ||
  //          self.aSwitch.status == SWITCH_LOCAL_LOCK) {
  //        NSData *timeMsg = [CC3xMessageUtil getP2dMsg17];
  //        [self.udpSocket sendData:timeMsg
  //                          toHost:self.aSwitch.ip
  //                            port:self.aSwitch.port
  //                     withTimeout:kUDPTimeOut
  //                             tag:P2D_GET_TIMER_REQ_17];
  //      } else if (self.aSwitch.status == SWITCH_REMOTE ||
  //                 self.aSwitch.status == SWITCH_REMOTE_LOCK) {
  //        NSData *timeMsg = [CC3xMessageUtil
  //        getP2SMsg19:self.aSwitch.macAddress];
  //        [self.udpSocket sendData:timeMsg
  //                          toHost:SERVER_IP
  //                            port:SERVER_PORT
  //                     withTimeout:kUDPTimeOut
  //                             tag:P2S_GET_TIMER_REQ_19];
  //      }
  //  });
  [[MessageUtil shareInstance] sendMsg17Or19:self.udpSocket
                                     aSwitch:self.aSwitch];

  //  //延迟执行的任务
  //  double delayInSeconds = 0.05;
  //  dispatch_time_t delayInNanoSeconds =
  //      dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  //  dispatch_after(delayInNanoSeconds, GLOBAL_QUEUE, ^{
  //      dispatch_async(GLOBAL_QUEUE, ^{
  //          //根据不同的网络环境，发送 本地/远程 消息
  //          if (self.aSwitch.status == SWITCH_LOCAL ||
  //              self.aSwitch.status == SWITCH_LOCAL_LOCK) {
  //            NSData *delayMsg = [CC3xMessageUtil getP2dMsg53];
  //            [self.udpSocket sendData:delayMsg
  //                              toHost:self.aSwitch.ip
  //                                port:self.aSwitch.port
  //                         withTimeout:kUDPTimeOut
  //                                 tag:P2D_GET_DELAY_REQ_53];
  //          } else if (self.aSwitch.status == SWITCH_REMOTE ||
  //                     self.aSwitch.status == SWITCH_REMOTE_LOCK) {
  //            NSData *delayMsg =
  //                [CC3xMessageUtil getP2SMsg55:self.aSwitch.macAddress];
  //            [self.udpSocket sendData:delayMsg
  //                              toHost:SERVER_IP
  //                                port:SERVER_PORT
  //                         withTimeout:kUDPTimeOut
  //                                 tag:P2S_GET_DELAY_REQ_55];
  //          }
  //      });
  //  });
  //延迟执行的任务
  double delayInSeconds = 0.05;
  dispatch_time_t delayInNanoSeconds =
      dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^{
      [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                         aSwitch:self.aSwitch];
  });

  //页面刷新定时器
  double delayInSeconds2 = kRefreshIntveral;
  dispatch_time_t delayInNanoSeconds2 =
      dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
  dispatch_after(
      delayInNanoSeconds2, dispatch_get_main_queue(),
      ^{
        //      self.refreshTimer =
        //          [[NSTimer alloc] initWithFireDate:[NSDate date]
        //                                   interval:kRefreshIntveral
        //                                     target:self
        //                                   selector:@selector(checkSwitchStateInTimer)
        //                                   userInfo:nil
        //                                    repeats:YES];
        //      [[NSRunLoop currentRunLoop] addTimer:self.refreshTimer
        //                                   forMode:NSRunLoopCommonModes];

        //      self.refreshTimer = [NSTimer
        //          scheduledTimerWithTimeInterval:kRefreshIntveral
        //                                  target:self
        //                                selector:@selector(checkSwitchStateInTimer)
        //                                userInfo:nil
        //                                 repeats:YES];
      });
  self.refreshTimer =
      [NSTimer scheduledTimerWithTimeInterval:kRefreshIntveral
                                       target:self
                                     selector:@selector(checkSwitchStateInTimer)
                                     userInfo:nil
                                      repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  //  if (self.udpSocket) {
  //    if (!self.udpSocket.isClosed) {
  //      [self.udpSocket close];
  //    }
  //    self.udpSocket = nil;
  //  }
  [self.delayTimer invalidate];
  [self.refreshTimer invalidate];
  self.delayTimer = nil;
  self.refreshTimer = nil;
  [UdpSocketUtil shareInstance].delegate = nil;
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//根据设备开关状态改变相应的背景背景图片
- (void)changeOutwardBySwitchState:(BOOL)isOn {
  dispatch_async(dispatch_get_main_queue(), ^{
      if (isOn) {
        self.imgViewBackground.image = [UIImage imageNamed:@"background"];
        self.imgViewLight.image = [UIImage imageNamed:@"lamp_light"];
        self.imgViewOperation.image =
            [UIImage imageNamed:@"smartplug_open_button"];
      } else {
        self.imgViewBackground.image = [UIImage imageNamed:@"background1"];
        self.imgViewLight.image = [UIImage imageNamed:@"lamp_unlight"];
        self.imgViewOperation.image =
            [UIImage imageNamed:@"smartplug_close_button"];
      }
  });
}

- (void)checkSwitchStateInTimer {
  //  //根据不同的网络环境，发送 本地/远程 消息
  //  if (self.aSwitch.status == SWITCH_LOCAL ||
  //      self.aSwitch.status == SWITCH_LOCAL_LOCK) {
  //    //开关状态
  //    [self.udpSocket sendData:[CC3xMessageUtil getP2dMsg0B]
  //                      toHost:self.aSwitch.ip
  //                        port:self.aSwitch.port
  //                 withTimeout:kUDPTimeOut
  //                         tag:P2D_STATE_INQUIRY_0B];
  //  } else if (self.aSwitch.status == SWITCH_REMOTE ||
  //             self.aSwitch.status == SWITCH_REMOTE_LOCK) {
  //    //开关状态
  //    [self.udpSocket
  //           sendData:[CC3xMessageUtil getP2SMsg0D:self.aSwitch.macAddress]
  //             toHost:SERVER_IP
  //               port:SERVER_PORT
  //        withTimeout:kUDPTimeOut
  //                tag:P2S_STATE_INQUIRY_0D];
  //  }
  [[MessageUtil shareInstance] sendMsg0BOr0D:self.udpSocket
                                     aSwitch:self.aSwitch];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)showPreExecPage:(id)sender {
  TimerController *nextVC = [[TimerController alloc] init];
  nextVC.aSwitch = self.aSwitch;
  nextVC.timerList = self.aSwitch.timerList;
  [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)showDelayPage:(id)sender {
  DelayController *nextVC = [[DelayController alloc] init];
  nextVC.aSwitch = self.aSwitch;
  [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)showEditPage:(id)sender {
  EditController *nextVC = [[EditController alloc] init];
  nextVC.aSwitch = self.aSwitch;
  [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)changeState:(id)sender {
  //如果没有网络
  if (![CC3xUtility checkNetworkStatus]) {
    return;
  }
  //检测设备状态
  [self checkSwitchStatus];
  //发送控制消息包
  [self sendMsg17];

  self.isLockOK = NO;

  //是否震动 userdefault
  //    BOOL shake =
  //    [[[NSUserDefaults standardUserDefaults] valueForKey:kShake] boolValue];
  //    if (shake) {
  //        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  //    }
}

- (IBAction)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)refresh:(id)sender {
}

//检测网络状态
- (void)checkSwitchStatus {
  if (self.aSwitch.status == SWITCH_OFFLINE ||
      self.aSwitch.status == SWITCH_UNKNOWN) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

//发送控制消息包
- (void)sendMsg17 {
  //发送消息之前检测网络状态
  NetworkStatus reach = [[Reachability
          reachabilityForInternetConnection] currentReachabilityStatus];
  //如果网络状态为没有链接，弹出提示框
  if (reach == NotReachable) {
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"Error", nil)
                  message:NSLocalizedString(@"The switch is offline", nil)
                 delegate:self
        cancelButtonTitle:NSLocalizedString(@"OK", nil)
        otherButtonTitles:nil, nil];
    [alert show];
    return;
  }
  //  //发送消息包之前检测udpsocket的状态，
  //  if (_udpSocket.isClosed == YES || _udpSocket == nil) {
  //    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
  //                                               delegateQueue:GLOBAL_QUEUE];
  //    [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
  //  }
  //  dispatch_async(GLOBAL_QUEUE, ^{
  //      NSData *msg;
  //      NSString *host;
  //      uint16_t port;
  //      long tag;
  //      //根据不同的网络环境，发送 本地/远程 消息
  //      if (self.aSwitch.status == SWITCH_LOCAL ||
  //          self.aSwitch.status == SWITCH_LOCAL_LOCK) {
  //        msg = [CC3xMessageUtil getP2dMsg11:!self.isSwitchOn];
  //        host = self.aSwitch.ip;
  //        port = self.aSwitch.port;
  //        tag = P2D_CONTROL_REQ_11;
  //      } else if (self.aSwitch.status == SWITCH_REMOTE ||
  //                 self.aSwitch.status == SWITCH_REMOTE_LOCK) {
  //        msg = [CC3xMessageUtil getP2sMsg13:self.aSwitch.macAddress
  //                                   aSwitch:!self.isSwitchOn];
  //        host = SERVER_IP;
  //        port = SERVER_PORT;
  //        tag = P2S_CONTROL_REQ_13;
  //      }
  //      [self.udpSocket sendData:msg
  //                        toHost:host
  //                          port:port
  //                   withTimeout:kUDPTimeOut
  //                           tag:tag];
  //  });
  [[MessageUtil shareInstance] sendMsg11Or13:self.udpSocket
                                     aSwitch:self.aSwitch
                                  isSwitchOn:self.isSwitchOn];
}

//倒计时显示，
- (void)countDown {
  dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"delay time is %d", self.delayTime);
      if (self.delayTime <= 0) {
        [self.delayTimer invalidate];
        self.imgViewDelay1.image = [UIImage imageNamed:@"digit_0"];
        self.imgViewDelay2.image = [UIImage imageNamed:@"digit_0"];
        self.imgViewDelay3.image = [UIImage imageNamed:@"digit_0"];
        self.imgViewDelay4.image = [UIImage imageNamed:@"digit_0"];
        self.lblDelayInfo.text = @"";
      } else if (self.delayTime > 0) {
        int hour = self.delayTime / 60;
        int min = self.delayTime % 60;
        NSString *image1Name =
            [@"digit_" stringByAppendingFormat:@"%d", hour / 10];
        NSString *image2Name =
            [@"digit_" stringByAppendingFormat:@"%d", hour % 10];
        NSString *image3Name =
            [@"digit_" stringByAppendingFormat:@"%d", min / 10];
        NSString *image4Name =
            [@"digit_" stringByAppendingFormat:@"%d", min % 10];
        self.imgViewDelay1.image = [UIImage imageNamed:image1Name];
        self.imgViewDelay2.image = [UIImage imageNamed:image2Name];
        self.imgViewDelay3.image = [UIImage imageNamed:image3Name];
        self.imgViewDelay4.image = [UIImage imageNamed:image4Name];
        if (self.delayIsOn) {
          self.lblDelayInfo.text = @"开启";
        } else {
          self.lblDelayInfo.text = @"关闭";
        }
        self.delayTime--;
      }
  });
}

#pragma mark 延迟操作处理
- (void)delayHandler {
  dispatch_async(dispatch_get_main_queue(), ^{
      //      self.delayTimer = [[NSTimer alloc] initWithFireDate:[NSDate
      //      date]
      //                                                 interval:60
      //                                                   target:self
      //                                                 selector:@selector(countDown)
      //                                                 userInfo:nil
      //                                                  repeats:YES];
      //      [[NSRunLoop currentRunLoop] addTimer:self.delayTimer
      //                                   forMode:NSRunLoopCommonModes];
      self.delayTimer =
          [NSTimer scheduledTimerWithTimeInterval:60
                                           target:self
                                         selector:@selector(countDown)
                                         userInfo:nil
                                          repeats:YES];
  });
}

#pragma mark 定时列表处理
- (void)timeTaskHandler {
  //当前时间
  NSDate *currentDate = [NSDate date];
  NSCalendar *gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps =
      [gregorian components:NSWeekdayCalendarUnit fromDate:currentDate];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
  NSString *dateString = [dateFormatter stringFromDate:currentDate];
  //当日零时
  NSDate *zeroDate = [dateFormatter dateFromString:dateString];
  //当前时间距离零时的秒数
  NSTimeInterval diff =
      [currentDate timeIntervalSince1970] - [zeroDate timeIntervalSince1970];
  //公历，国外的习惯，周日是一周的开始，也就是说周日返回1，周六返回7
  int weekday = [comps weekday];
  if (weekday == 1) {
    weekday = 8;
  }
  weekday -= 2;
  //保存操作打开，且今天包含在定时列表、设定时间晚于当前时间并且操作打开的task集合
  NSMutableArray *taskInTodayList = [NSMutableArray array];
  for (CC3xTimerTask *task in self.timeTaskList) {
    //操作开关打开
    if (task.timeDetail & 1 << 0) {
      //今天是否包含在内
      if (task.week & (1 << weekday)) {
        //时间还未到并且操作打开
        if ((diff < task.startTime && (task.timeDetail & 1 << 1)) ||
            (diff < task.endTime && (task.timeDetail & 1 << 2))) {
          [taskInTodayList addObject:task];
        }
      }
    }
  }
  //有满足条件的定时列表
  if ([taskInTodayList count] > 0) {
    NSMutableArray *startTimeList = [NSMutableArray array];
    NSMutableArray *endTimeList = [NSMutableArray array];
    for (CC3xTimerTask *task in taskInTodayList) {
      if (task.startTime > diff && task.timeDetail & 1 << 1) {
        [startTimeList addObject:@(task.startTime)];
      }
      if (task.endTime > diff && task.timeDetail & 1 << 2) {
        [endTimeList addObject:@(task.endTime)];
      }
    }
    NSArray *sortStartTimeList = [startTimeList
        sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int num1 = (int)obj1;
            int num2 = (int)obj2;
            return num1 - num2;
        }];
    NSArray *sortEndTimeList = [endTimeList
        sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            int num1 = (int)obj1;
            int num2 = (int)obj2;
            return num1 - num2;
        }];

    int startMin = -1;
    int endMin = -1;
    if (sortStartTimeList.count) {
      startMin = [[sortStartTimeList lastObject] intValue];
    }
    if (sortEndTimeList.count) {
      endMin = [[sortEndTimeList lastObject] intValue];
    }
    int min;
    NSString *desc;
    if (startMin == -1 || endMin == -1) {
      min = startMin == -1 ? endMin : startMin;
      desc = startMin == -1 ? @"关闭时间" : @"开启时间";
    } else {
      min = startMin <= endMin ? startMin : endMin;
      desc = startMin <= endMin ? @"开启时间" : @"关闭时间";
    }
    int hour = min / 3600;
    int minu = (min % 3600) / 60;
    NSString *image1Name = [@"digit_" stringByAppendingFormat:@"%d", hour / 10];
    NSString *image2Name = [@"digit_" stringByAppendingFormat:@"%d", hour % 10];
    NSString *image3Name = [@"digit_" stringByAppendingFormat:@"%d", minu / 10];
    NSString *image4Name = [@"digit_" stringByAppendingFormat:@"%d", minu % 10];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imgViewPreExec1.image = [UIImage imageNamed:image1Name];
        self.imgViewPreExec2.image = [UIImage imageNamed:image2Name];
        self.imgViewPreExec3.image = [UIImage imageNamed:image3Name];
        self.imgViewPreExec4.image = [UIImage imageNamed:image4Name];
        self.lblPreExecInfo.text = desc;
    });
    //时间到后清空
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)((min - (long)diff) * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSString *imageName = @"digit_0";
        self.imgViewPreExec1.image = [UIImage imageNamed:imageName];
        self.imgViewPreExec2.image = [UIImage imageNamed:imageName];
        self.imgViewPreExec3.image = [UIImage imageNamed:imageName];
        self.imgViewPreExec4.image = [UIImage imageNamed:imageName];
        self.lblPreExecInfo.text = @"";
    });
  }
}

#pragma mark UDP Delegate
///**
// * By design, UDP is a connectionless protocol, and connecting is not needed.
// * However, you may optionally choose to connect to a particular host for
// *reasons
// * outlined in the documentation for the various connect methods listed above.
// *
// * This method is called if one of the connect methods are invoked, and the
// *connection is successful.
// **/
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock
//    didConnectToAddress:(NSData *)address {
//  NSLog(@"didConnectToAddress");
//}
//
///**
// * By design, UDP is a connectionless protocol, and connecting is not needed.
// * However, you may optionally choose to connect to a particular host for
// *reasons
// * outlined in the documentation for the various connect methods listed above.
// *
// * This method is called if one of the connect methods are invoked, and the
// *connection fails.
// * This may happen, for example, if a domain name is given for the host and
// the
// *domain name is unable to be resolved.
// **/
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
//  NSLog(@"didNotConnect");
//}
//
///**
// * Called when the datagram with the given tag has been sent.
// **/
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
//  NSLog(@"didSendDataWithTag :%ld", tag);
//}
//
///**
// * Called if an error occurs while trying to send a datagram.
// * This could be due to a timeout, or something more serious such as the data
// *being too large to fit in a sigle packet.
// **/
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock
//    didNotSendDataWithTag:(long)tag
//               dueToError:(NSError *)error {
//  NSLog(@"didNotSendDataWithTag :%ld", tag);
//}
//
///**
// * Called when the socket has received the requested datagram.
// **/
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock
//       didReceiveData:(NSData *)data
//          fromAddress:(NSData *)address
//    withFilterContext:(id)filterContext {
//  NSLog(@"receiveData is %@", [CC3xMessageUtil hexString:data]);
//  if (data) {
//    CC3xMessage *msg = (CC3xMessage *)filterContext;
//    if (msg.msgId == 0x12 || msg.msgId == 0x14) {
//      //设备开关
//      if (msg.state == 0 && !self.isLockOK) {
//        self.isLockOK = YES;
//        self.isSwitchOn = !self.isSwitchOn;
//        self.aSwitch.isOn = self.isSwitchOn;
//        dispatch_async(dispatch_get_main_queue(),
//                       ^{ [self changeOutwardBySwitchState:self.isSwitchOn];
//                       });
//      }
//    } else if (msg.msgId == 0x18 || msg.msgId == 0x1a) {
//      //定时列表
//      if (msg.timerTaskNumber > 0) {
//        self.timeTaskList = msg.timerTaskList;
//        [self timeTaskHandler];
//      }
//    } else if (msg.msgId == 0x54 || msg.msgId == 0x56) {
//      //延迟响应
//      if (msg.delay > 0) {
//        self.delayTime = msg.delay;
//        self.delayIsOn = msg.isOn;
//        [self delayHandler];
//      }
//    } else if (msg.msgId == 0xc || msg.msgId == 0xe) {
//      //开关状态响应
//      dispatch_async(dispatch_get_main_queue(),
//                     ^{ [self changeOutwardBySwitchState:msg.isOn]; });
//    }
//  }
//}
//
///**
// * Called when the socket is closed.
// **/
//- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
//{
//  NSLog(@"DevicesProfileVC udpSocketDidClose");
//}

#pragma mark ResponseDelegate
- (void)responseMsgId12Or14:(CC3xMessage *)msg {
  if (msg.state == 0 && !self.isLockOK) {
    self.isLockOK = YES;
    self.isSwitchOn = !self.isSwitchOn;
    self.aSwitch.isOn = self.isSwitchOn;
    [self changeOutwardBySwitchState:self.isSwitchOn];
  }
}

- (void)responseMsgIdCOrE:(CC3xMessage *)msg {
  [self changeOutwardBySwitchState:msg.isOn];
}

- (void)responseMsgId18Or1A:(CC3xMessage *)msg {
  if (msg.timerTaskNumber > 0) {
    self.timeTaskList = msg.timerTaskList;
    [self timeTaskHandler];
  }
}

- (void)responseMsgId54Or56:(CC3xMessage *)msg {
  if (msg.delay > 0) {
    self.delayTime = msg.delay;
    self.delayIsOn = msg.isOn;
    [self delayHandler];
  }
}
@end
