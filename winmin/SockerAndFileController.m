//
//  SockerAndFileController.m
//  winmin
//
//  Created by sdzg on 14-5-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SockerAndFileController.h"
#import "DevicesProfileController.h"
#import "DevicesProfileVC.h"

@interface SockerAndFileController ()<UDPDelegate, PassValueDelegate>
@property (nonatomic, retain) NSIndexPath *selectedIndexPath; //当前操作的列
@end

@implementation SockerAndFileController
@synthesize tableView_DL;
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
  if ([UIViewController
          instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }

  [self.navigationController.navigationBar setTranslucent:NO];
  //从本地文件中获得设备列表
  NSArray *switchArray = [[XMLUtil sharedInstance] loadSwitches];
  _switchDict = [[NSMutableDictionary alloc] init];
  for (CC3xSwitch *aSwitch in switchArray) {
    if (aSwitch.macAddress) {
      [_switchDict setObject:aSwitch forKey:aSwitch.macAddress];
    }
  }

  self.navigationItem.title = @"智能插座列表";
  UIImageView *background_imageView = [[UIImageView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                               self.view.frame.size.height)];
  background_imageView.image = [UIImage imageNamed:@"background.png"];
  [super.view addSubview:background_imageView];

  //右刷新
  UIBarButtonItem *refreshBtn =
      [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(refreshViewControl:)];

  self.navigationItem.rightBarButtonItem = refreshBtn;

  // tableview，设备列表
  tableView_DL = [[UITableView alloc]
      initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)
              style:UITableViewStylePlain];
  NSLog(@"设备列表 x=%f,y=%f", tableView_DL.frame.origin.x,
        tableView_DL.frame.origin.y);
  tableView_DL.dataSource = self;
  tableView_DL.delegate = self;
  tableView_DL.rowHeight = 65.f;
  tableView_DL.backgroundColor = [UIColor clearColor];

  //设置分割线
  [tableView_DL setSeparatorStyle:UITableViewCellSeparatorStyleNone];
  [tableView_DL setSeparatorColor:[UIColor clearColor]];
  //不透明度
  tableView_DL.opaque = 0.6;

  [self.view addSubview:tableView_DL];

  //下拉刷新

  //    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  //    [refreshControl addTarget:self
  //                       action:@selector(refreshViewControl:)
  //             forControlEvents:UIControlEventValueChanged];
  //    self.refreshControl = refreshControl;

  //    [refreshControl release];

  //    [switchArray release];
  //    [background_imageView release];
  //    [refreshBtn release];
  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [UdpSocketUtil shareInstance].delegate = self;
  //查询开关状态
  [self updateSwitchStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
  [UdpSocketUtil shareInstance].delegate = nil;
  if (self.updateTimer) {
    [self.updateTimer invalidate];
    _updateTimer = nil;
  }
  [[XMLUtil sharedInstance] saveXmlWithList:self.switchDict.allValues];
  [super viewWillDisappear:animated];
}

//更新设备状态
- (void)updateSwitchStatus {
  if (self.updateTimer) {
    [self.updateTimer invalidate];

    _updateTimer = nil;
  }

  self.updateTimer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                             target:self
                                           selector:@selector(sendStateInquiry)
                                           userInfo:nil
                                            repeats:YES];
  [self.updateTimer fire];
  [[NSRunLoop currentRunLoop] addTimer:self.updateTimer
                               forMode:NSRunLoopCommonModes];
}
//扫描设备
- (void)sendStateInquiry {
  NSLog(@"扫描设备状态");
  //先局域网内扫描，1秒后内网没有响应的请求外网，更新设备状态
  [[MessageUtil shareInstance] sendMsg0B:self.udpSocket sendMode:ActiveMode];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                 GLOBAL_QUEUE, ^{
      NSArray *macs = [self.switchDict allKeys];
      int j = 0;
      for (int i = 0; i < macs.count; i++) {
        NSString *mac = [[self.switchDict allKeys] objectAtIndex:i];
        CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
        if (aSwitch.status != SWITCH_LOCAL ||
            aSwitch.status != SWITCH_LOCAL_LOCK) {
          double delayInSeconds = 0.5 * j;
          //外网每个延迟0.5秒发送请求
          dispatch_time_t delayInNanoSeconds =
              dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
          dispatch_after(delayInNanoSeconds, GLOBAL_QUEUE, ^{
              [[MessageUtil shareInstance] sendMsg0D:self.udpSocket
                                                 mac:mac
                                            sendMode:ActiveMode];
          });
          j++;
        }
      }
  });
}

- (void)dealloc {
  if (self.updateTimer) {
    [self.updateTimer invalidate];
    _updateTimer = nil;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//发送扫描信息
- (void)sendScanMsg {
  [[MessageUtil shareInstance] sendMsg09:self.udpSocket sendMode:ActiveMode];
}

//刷新
- (void)refreshViewControl:(UIRefreshControl *)refresh {
  [self sendScanMsg];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{ [self didReceiveDeviceInfo]; });
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.switchDict allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UIImage *statusImage;
  static NSString *CellID = @"switchcell";
  CustomCell *cell;
  cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
  if (cell == nil) {
    cell = [[CustomCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:CellID];
  }
  NSUInteger row = indexPath.row;
  NSString *mac = [[self.switchDict allKeys] objectAtIndex:row];
  CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
  cell.name = aSwitch.switchName;
  cell.device_imageV.image = [aSwitch getImageByImageName:aSwitch.imageName];
  //  if ([aSwitch.imageName isEqualToString:DEFAULT_IMAGENAME]) {
  //    cell.devices_image = [UIImage imageNamed:DEFAULT_IMAGENAME];
  //  } else {
  //    NSString *imagePath =
  //        [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
  //            stringByAppendingPathComponent:@"1406699841.png"];
  //    cell.devices_image = [UIImage imageWithContentsOfFile:imagePath];
  //  }

  switch (aSwitch.status) {
    case SWITCH_LOCAL:
      statusImage = [UIImage imageNamed:@"icon_local.png"];
      // NSLog(@"本地");
      break;
    case SWITCH_LOCAL_LOCK:
      statusImage = [UIImage imageNamed:@"icon_local_lock.png"];
      // NSLog(@"本地加锁");
      break;
    case SWITCH_OFFLINE:
      statusImage = [UIImage imageNamed:@"icon_offline_en"];
      // NSLog(@"离线");
      break;
    case SWITCH_UNKNOWN:
      statusImage = [UIImage imageNamed:@"icon_offline.png"];
      // NSLog(@"aSwitch.status unknown");
      break;
    case SWITCH_REMOTE:
      statusImage = [UIImage imageNamed:@"icon_remote.png"];
      // NSLog(@"远程");
      break;
    case SWITCH_REMOTE_LOCK:
      statusImage = [UIImage imageNamed:@"icon_remote_lock.png"];
      // NSLog(@"远程加锁");
      break;
    case SWITCH_NEW:
      statusImage = [UIImage imageNamed:@"icon_new.png"];
      // NSLog(@"新的");
      break;
    default:
      statusImage = [UIImage imageNamed:@"icon_new.png"];
      break;
  }
  cell.status_image = statusImage;
  cell.macAddress = aSwitch.macAddress;
  UILongPressGestureRecognizer *longPressGesture =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handleLongPress:)];
  longPressGesture.minimumPressDuration = 0.5;
  [cell addGestureRecognizer:longPressGesture];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (![CC3xUtility checkNetworkStatus]) {
    return;
  }

  self.selectedCell = (CustomCell *)[tableView cellForRowAtIndexPath:indexPath];
  self.selectedSwitch = [self.switchDict allValues][indexPath.row];
  NSString *mac = [[self.switchDict allKeys] objectAtIndex:indexPath.row];
  CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
  aSwitch.status = SWITCH_LOCAL;
  DevicesProfileVC *nextVC = [kSharedAppliction.mainStoryboard
      instantiateViewControllerWithIdentifier:@"DevicesProfileVC"];
  nextVC.aSwitch = aSwitch;
  nextVC.passValueDelegate = self;
  nextVC.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark-----devices  delegate----
- (void)changeAswitch:(id)sender {
  self.selectedSwitch = sender;

  UITableViewCell *cell = (UITableViewCell *)sender;
  NSIndexPath *indexPath = [tableView_DL indexPathForCell:cell];
  NSString *mac = [[self.switchDict allKeys] objectAtIndex:indexPath.row];
  if (sender == self.selectedCell) {
    CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
    aSwitch = sender;
  }
  [tableView_DL reloadData];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:tableView_DL];
  NSIndexPath *indexPath = [tableView_DL indexPathForRowAtPoint:p];
  self.selectedIndexPath = indexPath;
  if (indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    self.selectedSwitch = [self.switchDict allValues][indexPath.row];
    UITableViewCell *cell = [tableView_DL cellForRowAtIndexPath:indexPath];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:nil
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"取消", nil)
        destructiveButtonTitle:nil
             otherButtonTitles:NSLocalizedString(@"闪烁", nil),
                               NSLocalizedString(@"删除", nil), nil];
    [actionSheet showFromRect:cell.bounds inView:cell animated:YES];
  }
}

#pragma mark - UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
  if ([title isEqualToString:NSLocalizedString(@"删除", nil)]) {
    [self handleDeleteAction];
  } else if ([title isEqualToString:NSLocalizedString(@"闪烁", nil)]) {
    [self handleLocate];
  }
}

- (void)handleDeleteAction {
  [self.switchDict removeObjectForKey:_selectedSwitch.macAddress];
  [tableView_DL reloadData];
}

- (void)handleLocate {
  [[MessageUtil shareInstance] sendMsg39Or3B:self.udpSocket
                                     aSwitch:_selectedSwitch
                                          on:1
                                    sendMode:ActiveMode];
}

//- (void)handleLock:(BOOL)isLock {
//  [[MessageUtil shareInstance] sendMsg47Or49:self.udpSocket
//                                     aSwitch:_selectedSwitch
//                                      isLock:isLock];
//}
//- (void)handleRename {
//  if (![CC3xUtility checkNetworkStatus]) {
//    return;
//  }
//  UIAlertView *alert = [[UIAlertView alloc]
//          initWithTitle:_selectedSwitch.switchName
//                message:nil
//               delegate:self
//      cancelButtonTitle:NSLocalizedString(@"取消", nil)
//      otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
//  [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//  [alert show];
//}
//
//#pragma mark - UIAlertViewDelegate method
//
//- (void)alertView:(UIAlertView *)alertView
//    clickedButtonAtIndex:(NSInteger)buttonIndex {
//  NSString *name = [alertView textFieldAtIndex:0].text;
//  if (buttonIndex == alertView.cancelButtonIndex) {
//    return;
//  } else {
//    if (name.length) {
//      [[MessageUtil shareInstance] sendMsg3FOr41:self.udpSocket
//                                         aSwitch:_selectedSwitch
//                                            name:name];
//    }
//  }
//  [[alertView textFieldAtIndex:0] resignFirstResponder];
//  self.selectedSwitch.switchName = name;
//  [tableView_DL reloadData];
//}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier
                                  sender:(id)sender {
  if (self.isAllowded) {
    return YES;
  } else {
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"警告", nil)
                  message:NSLocalizedString(@"你没有权限使用", nil)
                 delegate:nil
        cancelButtonTitle:NSLocalizedString(@"确定", nil)
        otherButtonTitles:nil, nil];
    [alert show];

    return NO;
  }
}

//更新设备状态
- (void)updateSwitchByMsg:(CC3xMessage *)msg {
  CC3xSwitch *aSwitch = [self.switchDict objectForKey:msg.mac];
  if (aSwitch == nil) {
    return;
  } else {
    aSwitch.switchName = msg.deviceName;
    aSwitch.ip = msg.ip;
    aSwitch.port = msg.port;
    aSwitch.isLocked = msg.isLocked;
    aSwitch.isOn = msg.isOn;
    if (msg.msgId == 0xc && aSwitch.status != SWITCH_NEW) {
      if (aSwitch.isLocked) {
        aSwitch.status = SWITCH_LOCAL_LOCK;
      } else {
        aSwitch.status = SWITCH_LOCAL;
      }
    } else if (msg.msgId == 0xe && aSwitch.status != SWITCH_NEW &&
               aSwitch.status == SWITCH_UNKNOWN) {
      if (aSwitch.isLocked) {
        aSwitch.status = SWITCH_REMOTE_LOCK;
      } else {
        aSwitch.status = SWITCH_REMOTE;
      }
    } else if (aSwitch.status == SWITCH_UNKNOWN) {
      aSwitch.status = SWITCH_OFFLINE;
    }
    [self.switchDict setObject:aSwitch forKey:msg.mac];
  }
}

- (void)didReceiveDeviceInfo {
  [tableView_DL reloadData];
}

#pragma mark 修改设备信息后处理的Delegate
- (void)passValue:(id)value {
  NSDictionary *switchInfo = (NSDictionary *)value;
  NSString *mac = switchInfo[@"mac"];
  CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
  aSwitch.imageName = switchInfo[@"imageName"];
  aSwitch.switchName = switchInfo[@"name"];
  NSIndexPath *editIndexPath =
      [tableView_DL indexPathForCell:self.selectedCell];
  NSArray *indexPaths = @[ editIndexPath ];
  [tableView_DL beginUpdates];
  [tableView_DL reloadRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationNone];
  [tableView_DL endUpdates];
}

#pragma mark 处理内外网开关状态响应
- (void)handleResponseCOrE:(CC3xMessage *)msg {
  [self updateSwitchByMsg:msg];
  for (CustomCell *cell in [tableView_DL visibleCells]) {
    if ([cell.macAddress isEqualToString:msg.mac]) {
      dispatch_async(dispatch_get_main_queue(), ^{
          NSIndexPath *indexPath = [tableView_DL indexPathForCell:cell];
          if (indexPath) {
            NSArray *indexPaths = @[ indexPath ];
            [tableView_DL beginUpdates];
            [tableView_DL reloadRowsAtIndexPaths:indexPaths
                                withRowAnimation:UITableViewRowAnimationNone];
            [tableView_DL endUpdates];
          }
      });
    }
  }
}

#pragma mark UDPDelegate
- (void)responseMsgIdA:(CC3xMessage *)msg {
  dispatch_sync(GLOBAL_QUEUE, ^{
      CC3xSwitch *aSwitch = [[CC3xSwitch alloc] initWithName:msg.deviceName
                                                  macAddress:msg.mac
                                                      status:msg.state
                                                          ip:msg.ip
                                                        port:msg.port
                                                    isLocked:msg.isLocked
                                                        isOn:msg.isOn
                                                   timerList:msg.timerTaskList
                                                   imageName:nil];
      if (![self.switchDict objectForKey:aSwitch.macAddress]) {
        aSwitch.status = SWITCH_NEW;
      }
      [self.switchDict setObject:aSwitch forKey:msg.mac];
  });
}

- (void)noResponseMsgIdA {
  [[MessageUtil shareInstance] sendMsg09:self.udpSocket sendMode:PassiveMode];
}

- (void)noSendMsgId9 {
  [[MessageUtil shareInstance] sendMsg09:self.udpSocket sendMode:PassiveMode];
}

- (void)responseMsgIdC:(CC3xMessage *)msg {
  [self handleResponseCOrE:msg];
}

- (void)noResponseMsgIdC {
  [[MessageUtil shareInstance] sendMsg0B:self.udpSocket sendMode:PassiveMode];
  if ([MessageUtil shareInstance].msgBSendCount == kTryCount - 1) {
    for (CC3xSwitch *aSwitch in [self.switchDict allValues]) {
      if (aSwitch.status == SWITCH_LOCAL ||
          aSwitch.status == SWITCH_LOCAL_LOCK) {
        aSwitch.status = SWITCH_REMOTE;
      }
    }
  }
}

- (void)responseMsgIdE:(CC3xMessage *)msg {
  [self handleResponseCOrE:msg];
}

- (void)noResponseMsgIdE {
  //  [[MessageUtil shareInstance] sendMsg0D:self.udpSocket
  //                                     mac:mac
  //                                sendMode:ActiveMode];
  //  for (CC3xSwitch *aSwitch in [self.switchDict allValues]) {
  //    aSwitch.status = SWITCH_UNKNOWN;
  //  }
}

- (void)responseMsgId26Or28:(CC3xMessage *)msg {
  if (!msg.state) {
    self.isAllowded = YES;
    dispatch_async(dispatch_get_main_queue(), ^{});
  }
}

//- (void)responseMsgId48Or4A:(CC3xMessage *)msg {
//  [self updateSwitchByMsg:msg];
//  if (!msg.state) {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.selectedIndexPath) {
//          NSArray *indexPaths = @[ self.selectedIndexPath ];
//          [tableView_DL beginUpdates];
//          [tableView_DL reloadRowsAtIndexPaths:indexPaths
//                              withRowAnimation:UITableViewRowAnimationNone];
//          [tableView_DL endUpdates];
//          self.selectedIndexPath = nil;
//        }
//    });
//  }
//}
//
//- (void)noResponseMsgId48Or4A {
//  //    [[MessageUtil shareInstance] sendMsg47Or49:self.udpSocket
//  //                                       aSwitch:_selectedSwitch
//  //                                        isLock:isLock];
//}
//
//- (void)noSendMsgId47Or49 {
//  //    [[MessageUtil shareInstance] sendMsg47Or49:self.udpSocket
//  //                                       aSwitch:_selectedSwitch
//  //                                        isLock:isLock];
//}
@end
