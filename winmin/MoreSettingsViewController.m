//
//  MoreSettingsViewController.m
//  winmin
//
//  Created by sdzg on 14-5-12.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MoreSettingsViewController.h"
#import "AddNewDevicesController.h"

#import "FAQViewController.h"
#import "APPQrcodeViewController.h"
#import "USERSBookViewController.h"
#import "AboutViewController.h"
#define BroadCastTag 0
@interface MoreSettingsViewController ()

@end

@implementation MoreSettingsViewController
@synthesize _tableView, cell_image_array, cell_name_array, socketQueue;
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
  self.navigationItem.title = @"更多";
  self.tabBarItem.title = @"更多";
  //背景
  UIImageView *background_imageView = [[UIImageView alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                               self.view.frame.size.height)];
  background_imageView.image = [UIImage imageNamed:@"background.png"];
  [super.view addSubview:background_imageView];

  background_imageView = nil;

  // tableView列表显示
  _tableView = [[UITableView alloc]
      initWithFrame:CGRectMake(
                        0, STATUS_HEIGHT + NAVIGATION_HEIGHT, DEVICE_WIDTH,
                        DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT - 49)
              style:UITableViewStylePlain];
  _tableView.delegate = self;
  _tableView.dataSource = self;
  [self.view addSubview:_tableView];
  _tableView.backgroundColor = [UIColor clearColor];
  [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  _tableView.opaque = 0.8;
  //给定固定cell名和图标，存在数组中
  //    , @"导出数据", @"导入数据"
  cell_name_array = [[NSArray alloc]
      initWithObjects:@"添加新设备", @"按键震动", @"APP下载链接",
                      @"FAQ", @"用户手册", @"关于", nil];
  cell_image_array = [[NSArray alloc]
      initWithObjects:
          [UIImage imageNamed:@"icon_add_device"],
          //                      [UIImage imageNamed:@"icon_upload_data"],
          //                      [UIImage imageNamed:@"icon_download_data"],
          [UIImage imageNamed:@"icon_shake"],
          [UIImage imageNamed:@"icon_qrcode"], [UIImage imageNamed:@"icon_faq"],
          [UIImage imageNamed:@"icon_faq"], [UIImage imageNamed:@"icon_about"],
          nil];
}

#pragma mark-----------------------tableview datasource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {  // 8个cell
  return [cell_name_array count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {  //高度65
  return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {  // cell样式
  static NSString *identify = @"_cell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:identify];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:identify];
  }

  NSInteger row = indexPath.row;
  cell.textLabel.text = [cell_name_array objectAtIndex:row];
  cell.imageView.image = [cell_image_array objectAtIndex:row];
  cell.backgroundColor = [UIColor whiteColor];
  if (row == 1) {
    UISwitch *key_shake = [[UISwitch alloc] init];
    key_shake.on =
        [[[NSUserDefaults standardUserDefaults] valueForKey:kShake] boolValue];
    key_shake.center = cell.contentView.center;
    CGRect rect = key_shake.frame;
    rect.origin.x = cell.frame.size.width - rect.size.width - 30.0;
    rect.origin.y += 10.0;
    key_shake.frame = rect;
    [key_shake addTarget:self
                  action:@selector(switchAction:)
        forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:key_shake];
  }
  //  UISwitch *sw = (UISwitch *)[cell viewWithTag:1001];
  //  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
  //  if (![userDefault valueForKey:kShake]) {
  //    [userDefault setValue:@NO forKey:kShake];
  //  }
  //  sw.on = [[userDefault valueForKey:kShake] boolValue];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  NSInteger row = indexPath.row;
  //跳转添加设备
  if (row == 0) {
    AddNewDevicesViewController *add_device = [AddNewDevicesViewController new];
    add_device.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:add_device animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
  //  //导出数据,点击弹出提示框
  //  if (row == 1) {
  //    UIAlertView *export_data = [[UIAlertView alloc]
  //            initWithTitle:@"导出数据"
  //                  message:@"数" @"据" @"已"
  //                  @"经准备导出，请需要数据的手机按“导入"
  //                  @"数据”" @"按钮，" @"进"
  //                  @"行连接！点击“取消”后，停止共享数"
  //                  @"据..."
  //                 delegate:self
  //        cancelButtonTitle:@"取消"
  //        otherButtonTitles:nil];
  //    for (UIView *message in [export_data subviews]) {
  //      if ([message isKindOfClass:[UILabel class]]) {
  //        UILabel *label = (UILabel *)message;
  //        label.textAlignment = NSTextAlignmentLeft;
  //      }
  //    }
  //    [export_data show];
  //    [self broadAddress];
  //  }
  //  //导入文件
  //  if (row == 2) {
  //    //在导入文件时出现，文件的交互
  //
  //    // TODO:表格的添加
  //    UIActionSheet *import_data =
  //        [[UIActionSheet alloc] initWithTitle:@"搜索到的设备"
  //                                    delegate:self
  //                           cancelButtonTitle:@"取消"
  //                      destructiveButtonTitle:nil
  //                           otherButtonTitles:nil];
  //    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  //    [btn setTitle:@"device_name" forState:UIControlStateNormal];
  //    //        tableView_import = [[UITableView
  //    //        alloc]initWithFrame:CGRectMake(10, 35,
  //    //        import_data.frame.size.width-20,
  //    //        import_data.frame.size.height-49-20)
  //    style:UITableViewStylePlain];
  //
  //    //        [import_data addSubview:tableView_import];
  //    /**
  //     *需要判断是否有UDP报文，然后显示对方手机名称和ip地址及端口
  //     */
  //
  //    UIButton *device = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  //    device.frame = CGRectMake(10, 35, import_data.frame.size.width - 20,
  //    45);
  //    [device addTarget:self
  //                  action:@selector(broadAddress)
  //        forControlEvents:UIControlEventTouchUpInside];
  //    [import_data addSubview:device];
  //
  //    [import_data showInView:self.view];
  //  }
  //按键震动
  if (row == 1) {
  }
  // APP下载链接
  if (row == 2) {
  }
  // FAQ
  if (row == 3) {
    FAQViewController *faq = [[FAQViewController alloc] init];
    faq.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:faq animated:YES];
  }
  //用户手册
  if (row == 4) {
    USERSBookViewController *use = [[USERSBookViewController alloc] init];
    use.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:use animated:YES];
  }
  //关于我们
  if (row == 5) {
    AboutViewController *aboutVC = [kSharedAppliction.mainStoryboard
        instantiateViewControllerWithIdentifier:@"AboutViewController"];
    aboutVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:aboutVC animated:YES];
  }
}

#pragma mark 按键震动
- (void)switchAction:(UISwitch *)aSwitch {
  BOOL on = [aSwitch isOn];
  [[NSUserDefaults standardUserDefaults] setBool:on forKey:kShake];
}

//#pragma mark---------------------------UDP
//------------------------------------
////配置之前广播地址、配置信息
//- (void)broadAddress {
//  NSError *error = nil;
//  _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
//                                             delegateQueue:GLOBAL_QUEUE
//                                               socketQueue:socketQueue];
//  if (![self.udpSocket bindToPort:BIND_PORT error:&error]) {
//    LogInfo(@"port:%@", error);
//  }
//  if (![self.udpSocket enableBroadcast:YES error:&error]) {
//    LogInfo(@"broad:%@", error);
//  }
//  self.sendInfoTimer =
//      [NSTimer scheduledTimerWithTimeInterval:0.1
//                                       target:self
//                                     selector:@selector(sendInfo)
//                                     userInfo:nil
//                                      repeats:YES];
//  [self startToExport];
//  self.udpIsRunning = YES;
//}
//
////延迟触发广播
//- (void)sendInfo {
//  NSData *content;
//  NSString *deviceName = [UIDevice currentDevice].name;
//
//  LogInfo(@"info is %@", deviceName);
//  content = [deviceName dataUsingEncoding:NSUTF8StringEncoding];
//
//  [self.udpSocket sendData:content
//                    toHost:BROADCAST_ADDRESS
//                      port:EXPORT_PORT
//               withTimeout:15
//                       tag:BroadCastTag];
//}
////停止广播
//- (void)stopBroadcast {
//  //定时器失效，关闭udp
//  [self.sendInfoTimer invalidate];
//
//  _sendInfoTimer = nil;
//  [self.udpSocket close];
//  [self startToExport];
//}
////接收到的
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock
//       didReceiveData:(NSData *)data
//          fromAddress:(NSData *)address
//    withFilterContext:(id)filterContext {
//  NSString *msg =
//      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//  NSString *address1;
//  uint16_t port;
//
//  [GCDAsyncUdpSocket getHost:&address1 port:&port fromAddress:address];
//
//  LogInfo(@"address is %@:%d", address1, port);
//  if (msg) {
//    LogInfo(@"receiving data: %@", msg);
//  }
//
//  msg = nil;
//}
//
//- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
//  LogInfo("did send data : %ld", tag);
//}
//
//#pragma mark---------------------------------tcp
//-----------------------------------
//- (void)startToExport {
//  LogInfo(@"start to the tcp connection");
//  NSError *error = nil;
//  socketQueue = dispatch_queue_create("socketQueue", NULL);
//  //建立tcp
//  _tcpSocket =
//      [[GCDAsyncSocket alloc] initWithDelegate:self
//      delegateQueue:socketQueue];
//  _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
//
//  if (![self.tcpSocket acceptOnPort:BIND_PORT error:&error]) {
//    LogInfo(@"Error starting server: %@", error);
//  }
//  self.tcpIsRunning = YES;
//}
////传送得文件，从存储的xml目录下找到
//- (NSData *)xmlFileData {
//  NSData *data = nil;
//  NSString *xmlPath = [CC3xUtility xmlFilePath];
//  if ([[NSFileManager defaultManager] fileExistsAtPath:xmlPath]) {
//    data = [NSData dataWithContentsOfFile:xmlPath];
//  }
//  return data;
//}
//
////接受
//- (void)socket:(GCDAsyncSocket *)sock
//    didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
//  @synchronized(_connectedSockets) {
//    [_connectedSockets addObject:newSocket];
//  }
//  NSString *host = [newSocket connectedHost];
//  UInt16 port = [newSocket connectedPort];
//
//  NSData *data = [self xmlFileData];
//  LogInfo(@"send file to host %@ port %d  data %@", host, port, data);
//  [newSocket writeData:data withTimeout:-1 tag:P2P_INFO_TAG_0];
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
//  LogInfo(@"didwrite file to %ld", tag);
//}
//
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
//  LogInfo(@"client disconnected");
//}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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

@end
