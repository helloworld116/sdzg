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
#import <AudioToolbox/AudioToolbox.h>
#define kRefreshIntveral 5

@interface DevicesProfileVC ()<UDPDelegate, PassValueDelegate>
@property(strong, nonatomic) IBOutlet UIImageView *imgViewBackground;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewLight;

@property(strong, nonatomic) IBOutlet UIImageView *imgViewPreExec1;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewPreExec2;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewPreExec3;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewPreExec4;
@property(strong, nonatomic) IBOutlet UILabel *lblPreExecInfo;

@property(strong, nonatomic) IBOutlet UIImageView *imgViewDelay1;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewDelay2;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewDelay3;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewDelay4;
@property(strong, nonatomic) IBOutlet UILabel *lblDelayInfo;

@property(strong, nonatomic) IBOutlet UIImageView *imgViewOperation;

@property(strong, atomic) GCDAsyncUdpSocket *udpSocket;
@property(assign, nonatomic) BOOL isSwitchOn;  //设备是否打开
@property(assign, atomic) BOOL isLockOK;

//延迟相关量
@property(strong, nonatomic) NSTimer *delayTimer;  //延迟操作
@property(nonatomic, assign) NSInteger delayTime;  //延迟时间，单位分钟
@property(nonatomic, assign) BOOL delayIsOn;       //延迟操作是开还是关

//定时列表相关量
@property(nonatomic, strong) NSArray *timeTaskList;

@property(strong, nonatomic) NSTimer *refreshTimer;  //开关状态timer

@property(nonatomic, strong)
    NSDictionary *updateSwitchInfo;  //修改图片后传递到列表页面，修改图片和名称

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
  self.navigationItem.hidesBackButton = YES;
  UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [backBtn setImage:[UIImage imageNamed:@"back_button"]
           forState:UIControlStateNormal];
  backBtn.frame = CGRectMake(0, 2, 28, 28);
  [backBtn addTarget:self
                action:@selector(back:)
      forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:backBtn];

  self.isSwitchOn = self.aSwitch.isOn;
  [self changeOutwardBySwitchState:self.isSwitchOn];
  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [UdpSocketUtil shareInstance].delegate = self;
  [[MessageUtil shareInstance] sendMsg17Or19:self.udpSocket
                                     aSwitch:self.aSwitch
                                    sendMode:ActiveMode];
  //延迟执行的任务
  double delayInSeconds = 0.05;
  dispatch_time_t delayInNanoSeconds =
      dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^{
      [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                         aSwitch:self.aSwitch
                                        sendMode:ActiveMode];
  });

  //页面刷新定时器
  double delayInSeconds2 = kRefreshIntveral;
  dispatch_time_t delayInNanoSeconds2 =
      dispatch_time(DISPATCH_TIME_NOW, delayInSeconds2 * NSEC_PER_SEC);
  dispatch_after(
      delayInNanoSeconds2, dispatch_get_main_queue(),
      ^{//      self.refreshTimer =
        //          [[NSTimer alloc] initWithFireDate:[NSDate date]
        //                                   interval:kRefreshIntveral
        //                                     target:self
        // selector:@selector(checkSwitchStateInTimer)
        //                                   userInfo:nil
        //                                    repeats:YES];
        //      [[NSRunLoop currentRunLoop] addTimer:self.refreshTimer
        //                                   forMode:NSRunLoopCommonModes];

        //      self.refreshTimer = [NSTimer
        //          scheduledTimerWithTimeInterval:kRefreshIntveral
        //                                  target:self
        // selector:@selector(checkSwitchStateInTimer)
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
  [[MessageUtil shareInstance] sendMsg0BOr0D:self.udpSocket
                                     aSwitch:self.aSwitch
                                    sendMode:ActiveMode];
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
  nextVC.passValueDelegate = self;
  [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark 修改名字后用到的Delegate
- (void)passValue:(id)value {
  NSDictionary *switchInfo = (NSDictionary *)value;
  self.updateSwitchInfo = switchInfo;
  self.navigationItem.title = switchInfo[@"name"];
}

- (IBAction)changeState:(id)sender {
  //  //如果没有网络
  //  if (![CC3xUtility checkNetworkStatus]) {
  //    return;
  //  }
  //  //检测设备状态
  //  [self checkSwitchStatus];
  //发送控制消息包
  [self sendMsg11];

  self.isLockOK = NO;

  //是否震动 userdefault
  BOOL shake =
      [[[NSUserDefaults standardUserDefaults] valueForKey:kShake] boolValue];
  if (shake) {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  }
}

- (IBAction)back:(id)sender {
  if (self.updateSwitchInfo) {
    [self.passValueDelegate passValue:self.updateSwitchInfo];
  }
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
- (void)sendMsg11 {
  //  //发送消息之前检测网络状态
  //  NetworkStatus reach = [[Reachability
  //          reachabilityForInternetConnection] currentReachabilityStatus];
  //  //如果网络状态为没有链接，弹出提示框
  //  if (reach == NotReachable) {
  //    UIAlertView *alert = [[UIAlertView alloc]
  //            initWithTitle:NSLocalizedString(@"Error", nil)
  //                  message:NSLocalizedString(@"The switch is offline", nil)
  //                 delegate:self
  //        cancelButtonTitle:NSLocalizedString(@"OK", nil)
  //        otherButtonTitles:nil, nil];
  //    [alert show];
  //    return;
  //  }
  [[MessageUtil shareInstance] sendMsg11Or13:self.udpSocket
                                     aSwitch:self.aSwitch
                                  isSwitchOn:self.isSwitchOn
                                    sendMode:ActiveMode];
}

//倒计时显示，
- (void)countDown {
  dispatch_async(dispatch_get_main_queue(), ^{
      //      NSLog(@"delay time is %d", self.delayTime);
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

#pragma mark UDPDelegate
- (void)responseMsgId12Or14:(CC3xMessage *)msg {
  if (msg.state == 0 && !self.isLockOK) {
    self.isLockOK = YES;
    self.isSwitchOn = !self.isSwitchOn;
    self.aSwitch.isOn = self.isSwitchOn;
    [self changeOutwardBySwitchState:self.isSwitchOn];
  }
}

- (void)noResponseMsgId12Or14 {
  [[MessageUtil shareInstance] sendMsg11Or13:self.udpSocket
                                     aSwitch:self.aSwitch
                                  isSwitchOn:self.isSwitchOn
                                    sendMode:PassiveMode];
}

- (void)noSendMsgId11Or13 {
  [[MessageUtil shareInstance] sendMsg11Or13:self.udpSocket
                                     aSwitch:self.aSwitch
                                  isSwitchOn:self.isSwitchOn
                                    sendMode:PassiveMode];
}

- (void)responseMsgIdCOrE:(CC3xMessage *)msg {
  //列表页面请求响应后，代理已更改为此vc
  if ([self.aSwitch.macAddress isEqualToString:msg.mac]) {
    [self changeOutwardBySwitchState:msg.isOn];
  }
}

- (void)responseMsgIdC:(CC3xMessage *)msg {
  //列表页面请求响应后，代理已更改为此vc
  if ([self.aSwitch.macAddress isEqualToString:msg.mac]) {
    [self changeOutwardBySwitchState:msg.isOn];
  }
}

- (void)noResponseMsgIdC {
  [[MessageUtil shareInstance] sendMsg0B:self.udpSocket sendMode:PassiveMode];
}

- (void)responseMsgIdE:(CC3xMessage *)msg {
  //列表页面请求响应后，代理已更改为此vc
  if ([self.aSwitch.macAddress isEqualToString:msg.mac]) {
    [self changeOutwardBySwitchState:msg.isOn];
  }
}

- (void)noResponseMsgIdE {
  [[MessageUtil shareInstance] sendMsg0D:self.udpSocket
                                     mac:self.aSwitch.macAddress
                                sendMode:PassiveMode];
}

- (void)responseMsgId18Or1A:(CC3xMessage *)msg {
  if (msg.timerTaskNumber > 0) {
    self.timeTaskList = msg.timerTaskList;
    [self timeTaskHandler];
  }
}

- (void)noResponseMsgId18Or1A {
  [[MessageUtil shareInstance] sendMsg17Or19:self.udpSocket
                                     aSwitch:self.aSwitch
                                    sendMode:PassiveMode];
}

- (void)noSendMsgId17Or19 {
  [[MessageUtil shareInstance] sendMsg17Or19:self.udpSocket
                                     aSwitch:self.aSwitch
                                    sendMode:PassiveMode];
}

- (void)responseMsgId54Or56:(CC3xMessage *)msg {
  if (msg.delay > 0) {
    self.delayTime = msg.delay;
    self.delayIsOn = msg.isOn;
    [self countDown];
    [self delayHandler];
  }
}

- (void)noResponseMsgId54Or56 {
  [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                     aSwitch:self.aSwitch
                                    sendMode:PassiveMode];
}

- (void)noSendMsgId53Or55 {
  [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                     aSwitch:self.aSwitch
                                    sendMode:PassiveMode];
}
@end
