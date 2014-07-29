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

@interface SockerAndFileController ()<UDPDelegate>
@property(nonatomic, retain) NSIndexPath *selectedIndexPath;  //当前操作的列
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
  //从本地文件中获得设备列表
  NSArray *switchArray = [self loadSwitches];
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
  if (self.updateTimer) {
    [self.updateTimer invalidate];
    _updateTimer = nil;
  }
  [self saveXmlWithList:self.switchDict.allValues];
  [UdpSocketUtil shareInstance].delegate = nil;
  [super viewWillDisappear:animated];
}

#pragma mark - xml file dealing

- (NSArray *)loadSwitches {
  NSString *xmlPath = [CC3xUtility xmlFilePath];
  NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:xmlPath];
  NSError *error;
  GDataXMLDocument *doc =
      [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
  if (doc == nil) {
    return nil;
  }

  NSArray *switchArray = [doc.rootElement elementsForName:@"switch"];
  NSMutableArray *switches =
      [NSMutableArray arrayWithCapacity:switchArray.count];
  NSLog(@"xml读出设备数:%lu", (unsigned long)[switchArray count]);
  for (GDataXMLElement *aSwitch in switchArray) {
    NSString *mac = nil;
    NSString *name = nil;
    NSString *ip = nil;
    unsigned short port = 0;
    switchStatus state = SWITCH_UNKNOWN;
    BOOL local = NO;
    BOOL locked = NO;
    BOOL on = NO;
    NSMutableArray *timerList = nil;
    mac = [[aSwitch attributeForName:@"id"] stringValue];
    NSArray *names = [aSwitch elementsForName:@"name"];
    if (names.count > 0) {
      GDataXMLElement *firstName = (GDataXMLElement *)names[0];
      name = firstName.stringValue;
    }

    NSArray *ips = [aSwitch elementsForName:@"ip"];
    if (ips.count > 0) {
      GDataXMLElement *firstIp = (GDataXMLElement *)ips[0];
      ip = firstIp.stringValue;
    }

    NSArray *ports = [aSwitch elementsForName:@"port"];
    if (ports.count > 0) {
      GDataXMLElement *firstPort = (GDataXMLElement *)ports[0];
      port = [firstPort.stringValue intValue];
    }

    NSArray *states = [aSwitch elementsForName:@"state"];
    if (states.count > 0) {
      GDataXMLElement *firstState = (GDataXMLElement *)states[0];
      state = firstState.stringValue.boolValue;
    }

    NSArray *locks = [aSwitch elementsForName:@"locked"];
    if (locks.count > 0) {
      GDataXMLElement *firstLocked = (GDataXMLElement *)locks[0];
      locked = firstLocked.stringValue.boolValue;
    }

    NSArray *locals = [aSwitch elementsForName:@"local"];
    if (locals.count > 0) {
      GDataXMLElement *firstLocal = (GDataXMLElement *)locals[0];
      local = firstLocal.stringValue.boolValue;
    }

    NSArray *ons = [aSwitch elementsForName:@"on"];
    if (ons.count > 0) {
      GDataXMLElement *firstOn = (GDataXMLElement *)ons[0];
      NSString *onValue = firstOn.stringValue;
      if ([onValue isEqualToString:@"true"]) {
        on = YES;
      } else {
        on = NO;
      }
    }

    //定时列表，待添加
    //        NSArray *timerLists = [aSwitch elementsForName:@"timerList"];
    //        if (timerLists.count > 0) {
    //            GDataXMLElement *firstTimerList = (GDataXMLElement
    //            *)timerLists[0];
    //            timerList = firstTimerList ;
    //        }

    CC3xSwitch *bSwitch = [[CC3xSwitch alloc] initWithName:name
                                                macAddress:mac
                                                    status:state
                                                        ip:ip
                                                      port:port
                                                  isLocked:locked
                                                      isOn:on
                                                 timerList:timerList];
    [switches addObject:bSwitch];
  }

  return switches;
}

- (void)saveXmlWithList:(NSArray *)switchArray {
  GDataXMLElement *switches = [GDataXMLNode elementWithName:@"switches"];
  for (CC3xSwitch *aSwitch in switchArray) {
    NSString *mac = aSwitch.macAddress;
    NSString *portString = [NSString stringWithFormat:@"%d", aSwitch.port];
    GDataXMLElement *switchElement = [GDataXMLNode elementWithName:@"switch"];
    GDataXMLElement *idAttribute =
        [GDataXMLElement attributeWithName:@"id" stringValue:mac];
    [switchElement addAttribute:idAttribute];
    GDataXMLElement *nameEelement =
        [GDataXMLElement elementWithName:@"name"
                             stringValue:aSwitch.switchName];
    GDataXMLElement *ipEelement =
        [GDataXMLElement elementWithName:@"ip" stringValue:aSwitch.ip];
    GDataXMLElement *portElement =
        [GDataXMLElement elementWithName:@"port" stringValue:portString];
    GDataXMLElement *stateElement =
        [GDataXMLElement elementWithName:@"state" stringValue:@"0"];
    GDataXMLElement *lockedEelement =
        [GDataXMLElement elementWithName:@"locked"
                             stringValue:aSwitch.isLocked ? @"true" : @"false"];
    NSString *localStr = nil;
    if (aSwitch.status == SWITCH_LOCAL || aSwitch.status == SWITCH_LOCAL_LOCK) {
      localStr = @"true";
    } else {
      localStr = @"false";
    }
    GDataXMLElement *localElement =
        [GDataXMLElement elementWithName:@"local" stringValue:localStr];
    GDataXMLElement *onElement =
        [GDataXMLElement elementWithName:@"on"
                             stringValue:aSwitch.isOn ? @"true" : @"false"];
    GDataXMLElement *timerListElement =
        [GDataXMLElement elementWithName:@"timerList"];
    [switchElement addChild:timerListElement];

    [switchElement addChild:nameEelement];
    [switchElement addChild:ipEelement];
    [switchElement addChild:portElement];
    [switchElement addChild:stateElement];
    [switchElement addChild:lockedEelement];
    [switchElement addChild:localElement];
    [switchElement addChild:onElement];
    [switches addChild:switchElement];
  }

  GDataXMLDocument *document =
      [[GDataXMLDocument alloc] initWithRootElement:switches];
  NSData *xmlData = document.XMLData;
  NSString *xmlPath = [CC3xUtility xmlFilePath];
  [xmlData writeToFile:xmlPath atomically:YES];
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
  [[MessageUtil shareInstance] sendMsg0B:self.udpSocket];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                 GLOBAL_QUEUE, ^{
      NSArray *macs = [self.switchDict allKeys];
      int j = 0;
      for (int i = 0; i < macs.count; i++) {
        NSString *mac = [[self.switchDict allKeys] objectAtIndex:i];
        CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
        if (aSwitch.status == SWITCH_UNKNOWN) {
          double delayInSeconds = 0.05 * j;
          dispatch_time_t delayInNanoSeconds =
              dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
          dispatch_after(delayInNanoSeconds, GLOBAL_QUEUE, ^{
              [[MessageUtil shareInstance] sendMsg0D:self.udpSocket mac:mac];
          });
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
  [[MessageUtil shareInstance] sendMsg09:self.udpSocket];
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
  cell.devices_image = [UIImage imageNamed:@"icon_plug.png"];
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
  DevicesProfileVC *nextVC = [kSharedAppliction.mainStoryboard
      instantiateViewControllerWithIdentifier:@"DevicesProfileVC"];
  nextVC.aSwitch = aSwitch;
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
                                          on:1];
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
                                                   timerList:msg.timerTaskList];
      if (![self.switchDict objectForKey:aSwitch.macAddress]) {
        aSwitch.status = SWITCH_NEW;
      }
      [self.switchDict setObject:aSwitch forKey:msg.mac];
  });
}

- (void)noResponseMsgIdA {
  [[MessageUtil shareInstance] sendMsg09:self.udpSocket];
}

- (void)noSendMsgId9 {
  [[MessageUtil shareInstance] sendMsg09:self.udpSocket];
}

- (void)responseMsgIdCOrE:(CC3xMessage *)msg {
  [self updateSwitchByMsg:msg];
  dispatch_async(dispatch_get_main_queue(), ^{ [tableView_DL reloadData]; });
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
