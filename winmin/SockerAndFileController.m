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



@interface SockerAndFileController ()
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;//当前操作的列
@end

@implementation SockerAndFileController
@synthesize tableView_DL;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //从本地文件中获得设备列表
    NSArray *switchArray = [self loadSwitches];
    _switchDict = [[NSMutableDictionary alloc] init];
    for (CC3xSwitch *aSwitch in switchArray) {
        if (aSwitch.macAddress) {
            [_switchDict setObject:aSwitch
                            forKey:aSwitch.macAddress];
        }
    }
    //设置导航栏背景图片
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_background.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = @"智能插座列表";
    UIImageView * background_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    background_imageView.image = [UIImage imageNamed:@"background.png"];
    [super.view addSubview:background_imageView];
    
    
   //右刷新
    UIBarButtonItem * refreshBtn = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshViewControl:)];
    
    self.navigationItem.rightBarButtonItem = refreshBtn;

    //tableview，设备列表
    tableView_DL = [[UITableView alloc]initWithFrame:CGRectMake(0,STATUS_HEIGHT+ NAVIGATION_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT-64) style:UITableViewStylePlain];
    NSLog(@"设备列表 x=%f,y=%f",tableView_DL.frame.origin.x,tableView_DL.frame.origin.y);
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
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //进入视图之前，获取到数据(每次进入都可获取，区别与viewDidLoad，后者只能加载一次)
    
    //初始化socket
    _udpSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:GLOBAL_QUEUE];
    
    [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
    
    
    //查询开关状态
    [self updateSwitchStatus];
}


- (void)viewWillDisappear:(BOOL)animated
{
    if (self.udpSocket!=nil && self.udpSocket) {
        [self.udpSocket close];
        _udpSocket=nil;
    }
    
    
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        _updateTimer = nil;
    }
    
    [self saveXmlWithList:self.switchDict.allValues];
    
    [super viewWillDisappear:animated];
}

#pragma mark - xml file dealing

- (NSArray *)loadSwitches{
    NSString *xmlPath = [CC3xUtility xmlFilePath];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:xmlPath];
    NSError *error;
    GDataXMLDocument *doc =
    [[GDataXMLDocument alloc] initWithData:xmlData
                                   options:0
                                     error:&error];
    if (doc == nil) {
        return nil;
    }
    
    NSArray *switchArray = [doc.rootElement elementsForName:@"switch"];
    NSMutableArray *switches = [NSMutableArray arrayWithCapacity:switchArray.count];
    NSLog(@"xml读出设备数:%lu",(unsigned long)[switchArray count]);
    for (GDataXMLElement *aSwitch in switchArray) {
        NSString *mac = nil;
        NSString *name = nil;
        NSString *ip = nil;
        unsigned short port = 0;
        switchStatus state = SWITCH_UNKNOWN;
        BOOL local = NO;
        BOOL locked = NO;
        BOOL on = NO;
        NSMutableArray * timerList = nil;
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
            port=[firstPort.stringValue intValue];
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
//            GDataXMLElement *firstTimerList = (GDataXMLElement *)timerLists[0];
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


- (void)saveXmlWithList:(NSArray *)switchArray
{
    GDataXMLElement *switches = [GDataXMLNode elementWithName:@"switches"];
    for (CC3xSwitch *aSwitch in switchArray) {
        NSString *mac = aSwitch.macAddress;
        NSString *portString = [NSString stringWithFormat:@"%d", aSwitch.port];
        GDataXMLElement *switchElement = [GDataXMLNode elementWithName:@"switch"];
        GDataXMLElement *idAttribute = [GDataXMLElement attributeWithName:@"id"
                                                              stringValue:mac];
        [switchElement addAttribute:idAttribute];
        GDataXMLElement *nameEelement =
        [GDataXMLElement elementWithName:@"name"
                             stringValue:aSwitch.switchName];
        GDataXMLElement *ipEelement = [GDataXMLElement elementWithName:@"ip"
                                                           stringValue:aSwitch.ip];
        GDataXMLElement *portElement = [GDataXMLElement elementWithName:@"port"
                                                            stringValue:portString];
        GDataXMLElement *stateElement = [GDataXMLElement elementWithName:@"state"
                                                             stringValue:@"0"];
        GDataXMLElement *lockedEelement =
        [GDataXMLElement elementWithName:@"locked"
                             stringValue:aSwitch.isLocked ? @"true" : @"false"];
        NSString *localStr = nil;
        if (aSwitch.status == SWITCH_LOCAL ||
            aSwitch.status == SWITCH_LOCAL_LOCK) {
            localStr = @"true";
        } else {
            localStr = @"false";
        }
        GDataXMLElement *localElement =
        [GDataXMLElement elementWithName:@"local"
                             stringValue:localStr];
        GDataXMLElement *onElement =
        [GDataXMLElement elementWithName:@"on"
                             stringValue:aSwitch.isOn ? @"true" : @"false"];
        GDataXMLElement *timerListElement = [GDataXMLElement elementWithName:@"timerList" ];
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
    [[GDataXMLDocument alloc] initWithRootElement:switches] ;
    NSData *xmlData = document.XMLData;
    NSString *xmlPath = [CC3xUtility xmlFilePath];
    [xmlData writeToFile:xmlPath
              atomically:YES];
}


//更新设备状态
- (void)updateSwitchStatus{
    if (_udpSocket.isClosed == YES || _udpSocket == nil){
        _udpSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                      delegateQueue:GLOBAL_QUEUE];
        [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
    }
     
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
- (void)sendStateInquiry{
    NSLog(@"扫描设备状态");
//    [self.udpSocket sendData:[CC3xMessageUtil getP2dMsg0B]
//                          toHost:BROADCAST_ADDRESS
//                            port:DEVICE_PORT
//                     withTimeout:10
//                             tag:P2D_STATE_INQUIRY_0B];
    [[MessageUtil shareInstance] sendMsg0B:self.udpSocket];
    for (NSString *mac in [self.switchDict allKeys]) {
//        [self.udpSocket sendData:[CC3xMessageUtil getP2SMsg0D:mac] toHost:SERVER_IP port:SERVER_PORT withTimeout:10 tag:P2S_STATE_INQUIRY_0D];
        [[MessageUtil shareInstance] sendMsg0D:self.udpSocket mac:mac];
    }
}

- (void)dealloc
{
    
    _udpSocket.delegate = nil;
    [_udpSocket close];

    _udpSocket = nil;
    
    
    if (self.updateTimer) {
        [self.updateTimer invalidate];

        _updateTimer = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//发送扫描信息
- (void)sendScanMsg
{ 
    [self.udpSocket sendData:[CC3xMessageUtil getP2dMsg09]
                      toHost:BROADCAST_ADDRESS
                        port:DEVICE_PORT
                 withTimeout:10
                         tag:P2D_SCAN_DEV_09];
}

//刷新
- (void)refreshViewControl:(UIRefreshControl *)refresh
{
    NetworkStatus reach = [[Reachability reachabilityForInternetConnection]
                           currentReachabilityStatus];
    if (reach == NotReachable) {
        [CC3xUtility networkNotReachableAlert];
//        [self.refreshControl endRefreshing];
        return;
    }
    
    if (_udpSocket.isClosed == YES || _udpSocket == nil)
    {
        _udpSocket =[[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                  delegateQueue:GLOBAL_QUEUE];

        [CC3xUtility setupUdpSocket:self.udpSocket port:APP_PORT];
    }
     
    
    [self sendScanMsg];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self didReceiveDeviceInfo];
    });
    
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.switchDict allKeys].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *statusImage;
    static NSString *CellID = @"switchcell";
    CustomCell *cell;
    cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil){
        cell = [[CustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        
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
            //NSLog(@"远程加锁");
            break;
        case SWITCH_NEW:
            statusImage = [UIImage imageNamed:@"icon_new.png"];
            //NSLog(@"新的");
            break;
        default:
            statusImage = [UIImage imageNamed:@"icon_new.png"];
            break;
    }
    cell.status_image = statusImage;
    cell.macAddress = aSwitch.macAddress;
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [cell addGestureRecognizer:longPressGesture];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
    if (![CC3xUtility checkNetworkStatus]) {
        return;
    }
    
    self.selectedCell = (CustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.selectedSwitch = [self.switchDict allValues][indexPath.row];
    NSString *mac = [[self.switchDict allKeys] objectAtIndex:indexPath.row];
    CC3xSwitch *aSwitch = [self.switchDict objectForKey:mac];
    DevicesProfileVC *nextVC = [kSharedAppliction.mainStoryboard instantiateViewControllerWithIdentifier:@"DevicesProfileVC"];
    nextVC.aSwitch = aSwitch;
    nextVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark -----devices  delegate----
- (void)changeAswitch:(id)sender{
    self.selectedSwitch = sender;
    if (self.udpSocket) {
        [self.udpSocket close];
    }
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [tableView_DL indexPathForCell:cell];
    NSString *mac = [[self.switchDict allKeys] objectAtIndex:indexPath.row];
    if ( sender== self.selectedCell) {
        CC3xSwitch * aSwitch = [self.switchDict objectForKey:mac];
        aSwitch = sender;
    }
    [tableView_DL reloadData];
}




- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint p = [gestureRecognizer locationInView:tableView_DL];
    NSIndexPath *indexPath = [tableView_DL indexPathForRowAtPoint:p];
    self.selectedIndexPath=indexPath;
    if (indexPath == nil) {
        NSLog(@"长按屏幕不是长按开关");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSString *lockTitle;
        self.selectedSwitch = [self.switchDict allValues][indexPath.row];
        UITableViewCell *cell = [tableView_DL cellForRowAtIndexPath:indexPath];
        if (_selectedSwitch.status == SWITCH_LOCAL_LOCK ||
            _selectedSwitch.status == SWITCH_REMOTE_LOCK) {
            lockTitle = NSLocalizedString(@"不锁定", nil);
        } else {
            lockTitle = NSLocalizedString(@"锁定", nil);
        }
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:NSLocalizedString(@"取消", nil)
                      destructiveButtonTitle:nil
                           otherButtonTitles:lockTitle,NSLocalizedString(@"删除", nil),NSLocalizedString(@"位置",nil), NSLocalizedString(@"重命名",nil), nil];
        [actionSheet showFromRect:cell.bounds
                           inView:cell
                         animated:YES];

    }
}


#pragma mark - UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"删除", nil)]){
        [self handleDeleteAction];
    } else if ([title isEqualToString:NSLocalizedString(@"锁定", nil)]) {
        [self handleLock:YES];
    } else if ([title isEqualToString:NSLocalizedString(@"不锁定", nil)]) {
        [self handleLock:NO];
    } else if ([title isEqualToString:NSLocalizedString(@"位置", nil)]) {
        [self handleLocate];
    } else if ([title isEqualToString:NSLocalizedString(@"重命名", nil)]) {
        [self handleRename];
    }
}

- (void)handleDeleteAction{
    [self.switchDict removeObjectForKey:_selectedSwitch.macAddress];
    [tableView_DL reloadData];
}

- (void)handleLock:(BOOL)isLock{
    if (![CC3xUtility checkNetworkStatus]) {
        return;
    }
    if (_udpSocket.isClosed == YES || _udpSocket == nil)
    {
        [CC3xUtility setupUdpSocket:self.udpSocket
                               port:APP_PORT];
    }
    if (_selectedSwitch.status == SWITCH_LOCAL||_selectedSwitch.status == SWITCH_LOCAL_LOCK) {
        [self.udpSocket sendData:
         [CC3xMessageUtil getP2dMsg47:isLock]
                          toHost:_selectedSwitch.ip
                            port:_selectedSwitch.port
                     withTimeout:10
                             tag:P2D_DEV_LOCK_REQ_47];
    } else if (_selectedSwitch.status == SWITCH_REMOTE||_selectedSwitch.status == SWITCH_REMOTE_LOCK) {
        [self.udpSocket sendData:
         [CC3xMessageUtil getP2sMsg49:_selectedSwitch.macAddress
                                 lock:isLock]
                          toHost:SERVER_IP
                            port:SERVER_PORT
                     withTimeout:10
                             tag:P2S_DEV_LOCK_REQ_49];
    }
}

- (void)handleLocate{
    if (![CC3xUtility checkNetworkStatus]) {
        return;
    }
    if (_udpSocket.isClosed == YES || _udpSocket == nil)
    {
        [CC3xUtility setupUdpSocket:self.udpSocket
                               port:APP_PORT];
    }
    for (int i = 0; i < REPEATE_TIME; i++) {
        if (_selectedSwitch.status == SWITCH_LOCAL ||
            _selectedSwitch.status == SWITCH_LOCAL_LOCK) {
            [self.udpSocket sendData:[CC3xMessageUtil getP2dMsg39:1]
                              toHost:_selectedSwitch.ip
                                port:_selectedSwitch.port
                         withTimeout:10
                                 tag:P2D_LOCATE_REQ_39];
        } else if (_selectedSwitch.status == SWITCH_LOCAL ||
                   _selectedSwitch.status == SWITCH_LOCAL_LOCK) {
            [self.udpSocket sendData:
             [CC3xMessageUtil getP2SMsg3B:_selectedSwitch.macAddress
                                       on:1]
                              toHost:SERVER_IP
                                port:SERVER_PORT
                         withTimeout:10
                                 tag:P2S_LOCATE_REQ_3B];
        }
    }
}

- (void)handleRename{
    if (![CC3xUtility checkNetworkStatus]) {
        return;
    }
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:_selectedSwitch.switchName
                               message:nil
                              delegate:self
                     cancelButtonTitle:NSLocalizedString(@"取消", nil)
                     otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

#pragma mark - UIAlertViewDelegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *name = [alertView textFieldAtIndex:0].text;
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    } else {
        if (name.length)
        {
            if (_udpSocket.isClosed == YES || _udpSocket == nil)
            {
                [CC3xUtility setupUdpSocket:self.udpSocket
                                       port:APP_PORT];
            }

            dispatch_apply(REPEATE_TIME, GLOBAL_QUEUE, ^(size_t index){
                if (_selectedSwitch.status == SWITCH_LOCAL ||
                    _selectedSwitch.status == SWITCH_LOCAL_LOCK) {
                    [self.udpSocket sendData:[CC3xMessageUtil getP2dMsg3F:name]
                                      toHost:_selectedSwitch.ip
                                        port:_selectedSwitch.port
                                 withTimeout:10
                                         tag:P2D_SET_NAME_REQ_3F];
                } else if (_selectedSwitch.status == SWITCH_REMOTE ||
                           _selectedSwitch.status == SWITCH_REMOTE_LOCK) {
                    [self.udpSocket sendData:
                     [CC3xMessageUtil getP2sMsg41:_selectedSwitch.macAddress
                                             name:name]
                                      toHost:SERVER_IP
                                        port:SERVER_PORT
                                 withTimeout:10
                                         tag:P2S_SET_NAME_REQ_41];
                }
            });
        }
    }
    [[alertView textFieldAtIndex:0] resignFirstResponder];
    self.selectedSwitch.switchName = name;
    [tableView_DL reloadData];
}

#pragma mark - Navigation


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (self.isAllowded) {
        return YES;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"警告", nil)
                                                        message:NSLocalizedString(@"你没有权限使用", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];

        return NO;
    }
}


//更新设备状态
- (void)updateSwitchByMsg:(CC3xMessage *)msg{
    CC3xSwitch *aSwitch = [self.switchDict objectForKey:msg.mac];
    if (aSwitch == nil) {
        return;
    } else {
        aSwitch.ip = msg.ip;
        aSwitch.port = msg.port;
        aSwitch.isLocked = msg.isLocked;
        aSwitch.isOn = msg.isOn;
        if (msg.msgId == 0xc && aSwitch.status != SWITCH_NEW){
            if (aSwitch.isLocked) {
                aSwitch.status = SWITCH_LOCAL_LOCK;
            }else{
                aSwitch.status = SWITCH_LOCAL;
            }
        } else if (msg.msgId == 0xe && aSwitch.status == SWITCH_UNKNOWN && aSwitch.status != SWITCH_NEW){
            if (aSwitch.isLocked) {
                aSwitch.status = SWITCH_REMOTE_LOCK;
            }else{
                aSwitch.status = SWITCH_REMOTE;
            }
        } else if(aSwitch.status == SWITCH_UNKNOWN){
            aSwitch.status = SWITCH_OFFLINE;
        }
        aSwitch.status = SWITCH_REMOTE;
        [self.switchDict setObject:aSwitch forKey:msg.mac];
    }
}

#pragma mark udp delegate method

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
    if (data){
        CC3xMessage *msg = (CC3xMessage *)filterContext;
        NSLog(@"recv %02x from %@:%d %@",msg.msgId,msg.ip,msg.port,[CC3xMessageUtil hexString:data]);
        if (msg.msgId == 0xa){
            //手机扫描设备
            dispatch_sync(GLOBAL_QUEUE, ^{
                CC3xSwitch *aSwitch =
                [[CC3xSwitch alloc] initWithName:msg.deviceName
                                      macAddress:msg.mac
                                          status:msg.state
                                              ip:msg.ip
                                            port:msg.port
                                        isLocked:msg.isLocked
                                            isOn:msg.isOn
                                       timerList:msg.timerTaskList];
                if (![self.switchDict objectForKey:aSwitch.macAddress]){
                    aSwitch.status = SWITCH_NEW;
                }
                [self.switchDict setObject:aSwitch
                                    forKey:msg.mac];
            });
        } else if (msg.msgId == 0xc || msg.msgId == 0xe){
            //手机的开关状态，前者内网，后者外网
            [self updateSwitchByMsg:msg];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView_DL reloadData];
            });
        } else if (msg.msgId == 0x48 || msg.msgId == 0x4a){
            //锁定请求后的响应，48是内网，4a是外网
            NSLog(@"请求锁定");
            [self updateSwitchByMsg:msg];
            if (!msg.state){
                NSLog(@"已锁定");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.selectedIndexPath) {
                        NSArray *indexPaths = @[self.selectedIndexPath];
                        [tableView_DL beginUpdates];
                        [tableView_DL reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        [tableView_DL endUpdates];
                        self.selectedIndexPath=nil;
                    }
                });
            }
        } else if (msg.msgId == 0x26 || msg.msgId == 0x28){
            //手机获取控制权限，前者是内网，后者是外网
            NSLog(@"获取属性");
            if (!msg.state){
                self.isAllowded = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            }
        }
	} else{
		NSLog(@"没有收到Data，设备状态无");
        
	}
}

- (void)didReceiveDeviceInfo
{
    [tableView_DL reloadData]; 
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
didSendDataWithTag:(long)tag
{
    //NSLog(@" %ld 号信息发送", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
       dueToError:(NSError *)error
{
//    [self.refreshControl endRefreshing];
    NSLog(@"错误： %@", error);
}


- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock
                withError:(NSError *)error
{
    NSLog(@"关闭 socked %@",sock);
    if (error) {
        NSLog(@"关闭通信，因为 %@", error);
    }
}

@end
