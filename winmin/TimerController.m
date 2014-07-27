//
//  TimerController.m
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerController.h"
#import "TimerTableViewCell.h"
#import "GCDAsyncUdpSocket.h"
#import "CC3xUtility.h"
#import "CC3xMessage.h"
#import "CC3xSwitch.h"
#import "CC3xTimerTask.h"
#import "AddTimerController.h"
#import "DevicesProfileController.h"
@interface TimerController ()<ResponseDelegate>

@end

@implementation TimerController
@synthesize deices, content_view, timer_table;

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
  self.view.backgroundColor = [UIColor grayColor];
  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.title = self.aSwitch.switchName;

  // navi
  UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];

  [left setFrame:CGRectMake(0, 2, 28, 28)];

  [left setImage:[UIImage imageNamed:@"back_button"]
        forState:UIControlStateNormal];

  [left addTarget:self
                action:@selector(backToDevicesWithTimer)
      forControlEvents:UIControlEventTouchUpInside];

  UIBarButtonItem *leftButton =
      [[UIBarButtonItem alloc] initWithCustomView:left];

  self.navigationItem.leftBarButtonItem = leftButton;

  left = nil;
  leftButton = nil;

  UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];

  [right setFrame:CGRectMake(290, 2, 28, 28)];

  [right setImage:[UIImage imageNamed:@"refresh_button"]
         forState:UIControlStateNormal];

  [right addTarget:self
                action:@selector(refreshTimerList)
      forControlEvents:UIControlEventTouchUpInside];

  UIBarButtonItem *rightButton =
      [[UIBarButtonItem alloc] initWithCustomView:right];

  self.navigationItem.rightBarButtonItem = rightButton;

  right = nil;
  rightButton = nil;

  UIImageView *background_imageView =
      [[UIImageView alloc] initWithFrame:[self.view frame]];
  background_imageView.image = [UIImage imageNamed:@"background.png"];
  [super.view addSubview:background_imageView];

  background_imageView = nil;

  //    if (_udpSocket.isClosed == YES || _udpSocket == nil)
  //    {
  //        [CC3xUtility setupUdpSocket:self.udpSocket
  //                               port:APP_PORT];
  //    }

  _timerList = [[NSMutableArray alloc] init];

  self.isRefresh = NO;

  CGRect frame = CGRectMake(0, STATUS_HEIGHT + NAVIGATION_HEIGHT, DEVICE_WIDTH,
                            DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT);
  content_view = [[UIView alloc] initWithFrame:frame];
  content_view.backgroundColor = [UIColor clearColor];
  [self.view addSubview:content_view];
  UIImageView *content_bg = [[UIImageView alloc]
      initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT -
                                                       STATUS_HEIGHT -
                                                       NAVIGATION_HEIGHT)];
  content_bg.image = [UIImage imageNamed:@"window_background"];
  //    [content_bg setBounds:CGRectMake(0, 0, 260, DEVICE_HEIGHT-STATUS_HEIGHT
  //    - NAVIGATION_HEIGHT)];
  [content_view addSubview:content_bg];

  content_bg = nil;
  content_view.layer.cornerRadius = 5.0;

  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 160, 20)];
  label.text = @"定时任务列表";
  label.textAlignment = NSTextAlignmentCenter;
  //    [label setBounds:CGRectMake(100 , 20, 60, 20)];
  label.textColor = [UIColor whiteColor];
  [content_view addSubview:label];

  label = nil;

  timer_table = [[UITableView alloc]
      initWithFrame:CGRectMake(25, 40, DEVICE_WIDTH - 50, DEVICE_HEIGHT - 127)
              style:UITableViewStylePlain];
  //    [timer_table setBounds:CGRectMake(0, 45, DEVICE_WIDTH-60,
  //    DEVICE_HEIGHT-127)];
  timer_table.dataSource = self;
  timer_table.delegate = self;
  timer_table.rowHeight = 110.f;
  timer_table.backgroundColor = [UIColor clearColor];
  [timer_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [timer_table setSeparatorColor:[UIColor blackColor]];
  timer_table.opaque = 0.5;

  [content_view addSubview:timer_table];

  _addTimer_btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [_addTimer_btn setImage:[UIImage imageNamed:@"smartplug_timer_add_button"]
                 forState:UIControlStateNormal];
  [_addTimer_btn setFrame:CGRectMake(265, 4, 30, 30)];
  [_addTimer_btn addTarget:self
                    action:@selector(addTimer)
          forControlEvents:UIControlEventTouchUpInside];
  [content_view addSubview:_addTimer_btn];

  NSLog(@"定时cell绘制");
  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

//视图出现之前，从服务器获取定时列表（本地列表对比？）
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  //  self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
  //                                                 delegateQueue:GLOBAL_QUEUE];
  //  if (_udpSocket.isClosed == YES || _udpSocket == nil) {
  //    [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
  //  }
  [UdpSocketUtil shareInstance].delegate = self;
  [self getTimerList];
  //    self.timerList = self.aSwitch.timerList;
  //    [timer_table reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
  //  if (self.udpSocket) {
  //    [self.udpSocket close];
  //    self.udpSocket = nil;
  //  }
  [UdpSocketUtil shareInstance].delegate = self;
  [self endRefreshing];
  //    self.aSwitch.timerList = self.timerList;

  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)refreshTimerList {
  [NSTimer scheduledTimerWithTimeInterval:3
                                   target:self
                                 selector:@selector(endRefreshing)
                                 userInfo:nil
                                  repeats:NO];
  if (self.isRefresh) {
    return;
  }
  //  if (_udpSocket.isClosed == YES || _udpSocket == nil) {
  //    [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
  //  }
  [self getTimerList];

  self.isRefresh = YES;
}

- (void)endRefreshing {
  //    [self.refreshControl endRefreshing];
  self.isRefresh = NO;
}

- (void)getTimerList {
  //从服务器获取定时列表
  //  if (self.aSwitch.status == SWITCH_OFFLINE ||
  //      self.aSwitch.status == SWITCH_UNKNOWN) {
  //    [self.navigationController popToRootViewControllerAnimated:YES];
  //  }
  //  NSData *msg;
  //  NSString *host;
  //  uint16_t port;
  //  long tag;
  //  //根据不同的网络环境，发送 本地/远程 消息
  //  if (self.aSwitch.status == SWITCH_LOCAL ||
  //      self.aSwitch.status == SWITCH_LOCAL_LOCK) {
  //    msg = [CC3xMessageUtil getP2dMsg17];
  //    host = self.aSwitch.ip;
  //    port = self.aSwitch.port;
  //    tag = P2D_GET_TIMER_REQ_17;
  //  } else if (self.aSwitch.status == SWITCH_REMOTE ||
  //             self.aSwitch.status == SWITCH_REMOTE_LOCK) {
  //    msg = [CC3xMessageUtil getP2SMsg19:self.aSwitch.macAddress];
  //    host = SERVER_IP;
  //    port = SERVER_PORT;
  //    tag = P2S_GET_TIMER_REQ_19;
  //  }
  //  [self.udpSocket sendData:msg
  //                    toHost:host
  //                      port:port
  //               withTimeout:kUDPTimeOut
  //                       tag:tag];

  [[MessageUtil shareInstance] sendMsg17Or19:self.udpSocket
                                     aSwitch:self.aSwitch];
}

- (void)checkSwitchStatus {
  if (self.aSwitch.status == SWITCH_OFFLINE ||
      self.aSwitch.status == SWITCH_UNKNOWN) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

#pragma mark -TableCellDelegate
//自定义tablecell代理，长按手势，触发提示框
- (void)timerListCell:(TimerTableViewCell *)cell
    didHandleLongPress:(UIGestureRecognizer *)recognizer {
  self.selectedCell = cell;
  UIActionSheet *actionSheet = [[UIActionSheet alloc]
               initWithTitle:nil
                    delegate:self
           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
      destructiveButtonTitle:nil
           otherButtonTitles:NSLocalizedString(@"delete", nil),
                             NSLocalizedString(@"Edit", nil), nil];
  [actionSheet showFromRect:cell.bounds inView:cell animated:YES];
}

#pragma mark - UIActionSheet delegate method
//提示框触发不同的方案：编辑 / 删除
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
  if ([title isEqualToString:NSLocalizedString(@"delete", nil)]) {
    [self handleDeleteAction];
  } else if ([title isEqualToString:NSLocalizedString(@"Edit", nil)]) {
    [self handleEditAction];
  }
}
//删除定时
- (void)handleDeleteAction {
  if (![CC3xUtility checkNetworkStatus]) {
    return;
  }
  [self checkSwitchStatus];
  NSIndexPath *indexPath = [timer_table indexPathForCell:self.selectedCell];
  [self.timerList removeObjectAtIndex:indexPath.row];
  [self saveTheTimerList];
}
//编辑定时
- (void)handleEditAction {
  if (![CC3xUtility checkNetworkStatus]) {
    return;
  }
  [self checkSwitchStatus];
  //???:跳转到编辑定时页面
  AddTimerController *d = [[AddTimerController alloc] init];
  NSIndexPath *indexPath = [timer_table indexPathForCell:self.selectedCell];
  d.aSwitch = self.aSwitch;
  d.timerList = self.timerList;
  d.timerTask = [self.timerList objectAtIndex:indexPath.row];

  CATransition *animation = [CATransition animation];
  animation.duration = 0.7f;
  animation.delegate = self;
  animation.timingFunction = UIViewAnimationCurveEaseInOut;
  animation.type = @"rippleEffect";
  [self.navigationController.view.layer addAnimation:animation forKey:nil];

  [self.navigationController pushViewController:d animated:YES];
  //    [self addTimer];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.timerList.count;
}

- (void)setDayOfTimer:(TimerTableViewCell *)cell task:(CC3xTimerTask *)aTask {
  //显示选中的重复weekday
  UIImage *image = [UIImage imageNamed:@"edit_week_select"];
  UIImage *image1 = [UIImage imageNamed:@"edit_week_unselect"];
  [cell.mondayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  [cell.tuesdayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  [cell.wensdayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  [cell.thursdayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  [cell.fridayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  [cell.saturdayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  [cell.sundayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  if ([aTask isDayOn:MONDAY]) {
    [cell.mondayButton setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [cell.mondayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  }
  if ([aTask isDayOn:TUESDAY]) {
    [cell.tuesdayButton setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [cell.tuesdayButton setBackgroundImage:image1
                                  forState:UIControlStateNormal];
  }
  if ([aTask isDayOn:WENSDAY]) {
    [cell.wensdayButton setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [cell.wensdayButton setBackgroundImage:image1
                                  forState:UIControlStateNormal];
  }
  if ([aTask isDayOn:THURSDAY]) {
    [cell.thursdayButton setBackgroundImage:image
                                   forState:UIControlStateNormal];
  } else {
    [cell.thursdayButton setBackgroundImage:image1
                                   forState:UIControlStateNormal];
  }
  if ([aTask isDayOn:FRIDAY]) {
    [cell.fridayButton setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [cell.fridayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  }
  if ([aTask isDayOn:SATURDAY]) {
    [cell.saturdayButton setBackgroundImage:image
                                   forState:UIControlStateNormal];
  } else {
    [cell.saturdayButton setBackgroundImage:image1
                                   forState:UIControlStateNormal];
  }
  if ([aTask isDayOn:SUNDAY]) {
    [cell.sundayButton setBackgroundImage:image forState:UIControlStateNormal];
  } else {
    [cell.sundayButton setBackgroundImage:image1 forState:UIControlStateNormal];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"TIMER_LIST_CELL";
  TimerTableViewCell *cell;
  cell = (TimerTableViewCell *)
      [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    cell = [[TimerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellId];
  }
  NSUInteger row = indexPath.row;
  //如果定时列表为空，直接返回
  CC3xTimerTask *task = self.timerList[row];
  cell.open_field.text =
      [NSString stringWithFormat:@"%02u:%02u", task.startTime / 3600,
                                 (task.startTime % 3600) / 60];
  cell.open_status_label.text = task.isStartTimeOn
                                    ? NSLocalizedString(@"Run", nil)
                                    : NSLocalizedString(@"Not run", nil);
  cell.close_field.text =
      [NSString stringWithFormat:@"%02u:%02u", task.endTime / 3600,
                                 (task.endTime % 3600) / 60];
  cell.close_status_label.text = task.isEndTimeOn
                                     ? NSLocalizedString(@"Run", nil)
                                     : NSLocalizedString(@"Not run", nil);
  cell.set_switch.on = task.isTaskOn ? YES : NO;
  [cell.set_switch addTarget:self
                      action:@selector(toggleSwitch:)
            forControlEvents:UIControlEventValueChanged];
  [self setDayOfTimer:cell task:task];
  cell.aDelegate = self;

  return cell;
}
//点击触发跳转 定时编辑
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [timer_table deselectRowAtIndexPath:indexPath animated:YES];
  //    AddTimerController * add = [[AddTimerController alloc]init];
  //    add.timerTask = [self.timerList objectAtIndex:indexPath.row];
  //
  //
  //    [self.navigationController pushViewController:add animated:YES];
}

#pragma mark - toggle the switch
//定时器开关选择
- (void)toggleSwitch:(id)sender {
  if (![CC3xUtility checkNetworkStatus]) {
    return;
  }
  if (self.aSwitch.status == SWITCH_UNKNOWN ||
      self.aSwitch.status == SWITCH_OFFLINE) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
  UISwitch *us = (UISwitch *)sender;
  self.selectedSwitch = us;
  CGPoint center = us.center;
  CGPoint cellPoint = [us.superview convertPoint:center toView:timer_table];
  NSIndexPath *indexPath = [timer_table indexPathForRowAtPoint:cellPoint];
  self.selectedCell =
      (TimerTableViewCell *)[timer_table cellForRowAtIndexPath:indexPath];
  NSLog(@"indexpaht is %ld", (long)indexPath.row);
  [self.timerList[indexPath.row] setTaskOn:us.on];
  [self saveTheTimerList];
}

#pragma mark - network
- (void)saveTheTimerList {
  //  NSCalendar *gregorian =
  //      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  //
  //  NSDateComponents *comps =
  //      [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit |
  //                            NSMinuteCalendarUnit
  //                   fromDate:[NSDate date]];
  //  NSLog(@"comps ==== %@", comps);
  //
  //  NSInteger weekday = ([comps weekday] + 5) % 7;
  //  NSInteger hour = [comps hour];
  //  NSInteger min = [comps minute];
  //  NSInteger currentTime = weekday * 24 * 3600 + hour * 3600 + min * 60;
  //  NSData *msg;
  //  NSString *host;
  //  uint16_t port;
  //  long tag;
  //  //根据不同的网络环境，发送 本地/远程 消息
  //  if (self.aSwitch.status == SWITCH_LOCAL ||
  //      self.aSwitch.status == SWITCH_LOCAL_LOCK) {
  //    msg = [CC3xMessageUtil getP2dMsg1D:currentTime
  //                              timerNum:self.timerList.count
  //                             timerList:self.timerList];
  //    host = self.aSwitch.ip;
  //    port = self.aSwitch.port;
  //    tag = P2D_SET_TIMER_REQ_1D;
  //  } else if (self.aSwitch.status == SWITCH_REMOTE ||
  //             self.aSwitch.status == SWITCH_REMOTE_LOCK) {
  //    msg = [CC3xMessageUtil getP2SMsg1F:currentTime
  //                              timerNum:self.timerList.count
  //                             timerList:self.timerList
  //                                   mac:self.aSwitch.macAddress];
  //    host = SERVER_IP;
  //    port = SERVER_PORT;
  //    tag = P2S_SET_TIMER_REQ_1F;
  //  }
  //  [self.udpSocket sendData:msg
  //                    toHost:host
  //                      port:port
  //               withTimeout:kUDPTimeOut
  //                       tag:tag];
  [[MessageUtil shareInstance] sendMsg1DOr1F:self.udpSocket
                                     aSwitch:self.aSwitch
                                    timeList:self.timerList];
}

#pragma mark - udp delegate method

//- (void)udpSocket:(GCDAsyncUdpSocket *)sock
//       didReceiveData:(NSData *)data
//          fromAddress:(NSData *)address
//    withFilterContext:(id)filterContext {
//  NSLog(@"received  timerList data------------------------");
//  if (data) {
//    CC3xMessage *msg = (CC3xMessage *)filterContext;
//    NSLog(@"recv %02x from %@:%d %@", msg.msgId, msg.ip, msg.port,
//          [CC3xMessageUtil hexString:data]);
//    if (msg.msgId == 0x18 || msg.msgId == 0x1a) {
//      NSLog(@"获取定时列表成功");
//      dispatch_sync(GLOBAL_QUEUE, ^{
//          //如果收到定时数据，本地数据清零
//          [self.timerList removeAllObjects];
//          for (CC3xTimerTask *task in msg.timerTaskList) {
//            if (![self.timerList containsObject:task]) {
//              [self.timerList addObject:task];
//            }
//          }
//      });
//      dispatch_async(dispatch_get_main_queue(), ^{
//          [timer_table reloadData];
//          [self endRefreshing];
//      });
//    } else if (msg.msgId == 0x1e || msg.msgId == 0x20) {
//      NSLog(@"编辑定时列表成功");
//      dispatch_async(dispatch_get_main_queue(), ^{
//          [timer_table reloadData];
//          [self endRefreshing];
//      });
//    }
//  }
//}
//
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
//  LogInfo(@"msg %ld is sent", tag);
//}
//
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock
//    didNotSendDataWithTag:(long)tag
//               dueToError:(NSError *)error {
//  dispatch_async(dispatch_get_main_queue(), ^{
//      if (tag == P2D_SET_TIMER_REQ_1D || tag == P2S_SET_TIMER_REQ_1F) {
//        self.selectedSwitch.on = !self.selectedSwitch.on;
//      }
//      [self endRefreshing];
//      LogInfo(@"Error happens %@", error);
//  });
//}
//
//- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
//{
//  NSLog(@"TimerController udp has closed");
//}

#pragma mark ResponseDelegate
- (void)responseMsgId18Or1A:(CC3xMessage *)msg {
  dispatch_sync(GLOBAL_QUEUE, ^{
      //如果收到定时数据，本地数据清零
      [self.timerList removeAllObjects];
      for (CC3xTimerTask *task in msg.timerTaskList) {
        if (![self.timerList containsObject:task]) {
          [self.timerList addObject:task];
        }
      }
  });
  dispatch_async(dispatch_get_main_queue(), ^{
      [timer_table reloadData];
      [self endRefreshing];
  });
}

- (void)responseMsgId1EOr20:(CC3xMessage *)msg {
  dispatch_async(dispatch_get_main_queue(), ^{
      [timer_table reloadData];
      [self endRefreshing];
  });
}
//进入定时编辑页面
- (void)addTimer {
  AddTimerController *add = [[AddTimerController alloc] init];
  add.aSwitch = self.aSwitch;
  //    add.delegate = self;
  add.timerList = self.timerList;

  CATransition *animation = [CATransition animation];
  animation.duration = 0.7f;
  animation.delegate = self;
  animation.type = @"rippleEffect";
  animation.timingFunction = UIViewAnimationCurveEaseInOut;
  [self.navigationController.view.layer addAnimation:animation forKey:nil];

  [self.navigationController pushViewController:add animated:YES];
}
- (void)backToDevicesWithTimer {
  //    if (self.delegate && [self.delegate
  //    respondsToSelector:@selector(timer:)])
  //    {
  //        NSLog(@"保存timerList回到设备控制页面");
  //!!!:代理返回方法传参有问题，会导致crash
  //        [self.delegate timer:self.timerList];
  self.aSwitch.timerList = self.timerList;
  [self.navigationController popViewControllerAnimated:YES];
  //    }
  //
  //    NSLog(@"返回devices成功");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
// preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if (self.udpSocket) {
//        [self.udpSocket close];
//    }
//    if ([segue.identifier isEqualToString:@"add_timer"]) {
//        id theSegue = segue.destinationViewController;
//        [theSegue setValue:self.aSwitch
//                forKeyPath:@"aSwitch"];
//        [theSegue setValue:self.timerList forKey:@"timerList"];
//        if (sender == self.selectedCell) {
//            NSIndexPath *indexPath = [timer_table
//            indexPathForCell:self.selectedCell];
//            CC3xTimerTask *task = self.timerList[indexPath.row];
//            [theSegue setValue:task forKey:@"timerTask"];
//        }
//    }
//}
#pragma mark------ timeListDelegate
//添加定时器代理，
//- (void)changeTimerList:(id)sender
//{
//    if (self.udpSocket) {
//        [self.udpSocket close];
//    }
//    self.timerList = sender;
//    if (sender == self.selectedCell)
//    {
//        NSIndexPath *indexPath = [timer_table
//        indexPathForCell:self.selectedCell];
//        CC3xTimerTask *task = self.timerList[indexPath.row];
//        self.aSwitch.timerList = self.timerList;
//        task = sender;
//    }
//
//    [timer_table reloadData];
//}

//返回设备控制页面
- (void)godevices {
  [self.navigationController popViewControllerAnimated:YES];
}
//刷新
- (void)refresh {
  [timer_table reloadData];
}
@end
