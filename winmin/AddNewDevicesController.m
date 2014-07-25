//
//  AddNewDevicesController.m
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AddNewDevicesController.h"
#import "GCDAsyncUdpSocket.h"
#import "CC3xAPManager.h"
#import "CC3xMessage.h"
#import "CC3xUtility.h"
#import "DDLog.h"
#include <netdb.h>
@interface AddNewDevicesViewController ()

@end

@implementation AddNewDevicesViewController

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
    //背景
    UIImageView * background_imageView = [[UIImageView alloc]initWithFrame:[self.view frame]];
    background_imageView.image = [UIImage imageNamed:@"background.png"];
    [super.view addSubview:background_imageView];

    background_imageView = nil;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"添加新设备";
    //返回按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [left setFrame:CGRectMake(0, 2, 28, 28)];
    
    [left setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    
    [left addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:left];
    
    self.navigationItem.leftBarButtonItem = leftButton;

    leftButton = nil;
    //wifi名，可默认获取
    textfield_wifi =[[UITextField alloc]initWithFrame:CGRectMake(27, 76, 273, 30)];
    textfield_wifi.borderStyle = UITextBorderStyleRoundedRect;
    textfield_wifi.placeholder = @"WIFI:";
    textfield_wifi.clearButtonMode = UITextFieldViewModeAlways;
    textfield_wifi.enabled = YES;
    textfield_wifi.delegate = self;
    
    //密码
    textfield_password =[[UITextField alloc]initWithFrame:CGRectMake(27, 118, 273, 30)];
    textfield_password.borderStyle = UITextBorderStyleRoundedRect;
    textfield_password.placeholder = @"密码:";
    textfield_password.clearButtonMode = UITextFieldViewModeAlways;
    textfield_password.enabled = YES;
    textfield_password.delegate = self;
    textfield_password.secureTextEntry = YES;
    
    //是否显示
    label_showpassword = [[UILabel alloc]initWithFrame:CGRectMake(27, 171, 128, 21)];
    label_showpassword.text = @"是否显示密码:";
    
    
    switch_showpassword = [[UISwitch alloc]initWithFrame:CGRectMake(251, 171, 51, 31)];
    switch_showpassword.on = NO;
    [switch_showpassword addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
    //点击开始连接按钮
    button_startconfig = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button_startconfig.frame = CGRectMake(10, 216, 300, 30);
    [button_startconfig setBackgroundImage:[UIImage imageNamed:@"save_button_image"] forState:UIControlStateNormal];
    
    [button_startconfig setTitle:@"开始配置" forState:UIControlStateNormal];
    [button_startconfig addTarget:self action:@selector(touchToAdd:) forControlEvents:UIControlEventTouchUpInside];
    //将控件作为子视图添加再视图上
    [self.view addSubview:textfield_wifi];
    [self.view addSubview:textfield_password];
    [self.view addSubview:label_showpassword];
    [self.view addSubview:switch_showpassword];
    [self.view addSubview:button_startconfig];
    
    
    config = nil;
    _switchesDict = [[NSMutableDictionary alloc]init];
    //注册通知，WiFi状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(wifiStatusChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appEnterInBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(appEnterInforground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    //检测网络
    wifiReachability = [Reachability reachabilityForLocalWiFi] ;
    [wifiReachability connectionRequired];
	[wifiReachability startNotifier];
    
    _udpSocket = [[GCDAsyncUdpSocket alloc]
                  initWithDelegate:self
                  delegateQueue:GLOBAL_QUEUE];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //视图出现前，检测网络连接状态   wifi/wan/not
    NetworkStatus netStatus = [wifiReachability currentReachabilityStatus];
    if (netStatus == NotReachable) {// No activity if no wifi
        [self networkNotReachableAlert];
    } else {
        NSString *ssid = [FirstTimeConfig getSSID];
        textfield_wifi.text = ssid;
    }
}
//udp方法
#pragma mark udp delegate method

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext{
//	if (!_isRunning) return;
    NSLog(@"receiveData is %@", [CC3xMessageUtil hexString:data]);
    if (data) {
        CC3xMessage *msg = (CC3xMessage *)filterContext;
        if (msg.msgId == 0x2) {
            NSLog(@"添加设备，mac:%@，ip:%@，port:%d", msg.mac, msg.ip, msg.port);
            /*if (![self.switchesDict objectForKey:msg.mac]) {
             [self.switchesDict setObject:msg
             forKey:msg.mac];*/
            NSData *msg5 = [CC3xMessageUtil getP2dMsg05];
            
            [_udpSocket sendData:msg5
                       toAddress:address
                     withTimeout:-1
                             tag:P2D_SERVER_INFO_05];
            
        }else if (msg.msgId==0x06){
            NSLog(@"添加成功，mac:%@,state:%d",msg.mac,msg.state);
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"添加成功" message:msg.mac delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
	} else {
		LogInfo(@"Error converting received data into UTF-8 String");
	}
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    LogInfo(@"msg %ld is sent", tag);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"AddNewDevicesController ->udp  has closed");
}






//view load之前检查wifi网络

- (void)networkNotReachableAlert
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"WiFi没有连接，请检查你的WiFi" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];

}
//网络连接完好，进行udp传输
- (void)startTransmitting{
    @try {
        NetworkStatus netStatus = [wifiReachability currentReachabilityStatus];
        if ( netStatus == NotReachable ){// No activity if no wifi
            [self networkNotReachableAlert];
            return;
        }
        
       
        config = nil;
        
        if ( [textfield_password.text length] ){// for user enter the password
            self.passwordStr =
            [textfield_password.text length] ? textfield_password.text : nil;
            config = [[FirstTimeConfig alloc] initWithKey:self.passwordStr];
        }else {
            config = [[FirstTimeConfig alloc] init];
        }
        
        [self sendAction];
        [self enableUIAccess:NO];
    }
    @catch (NSException *exception) {
        LogInfo(@"%s exception == %@",__FUNCTION__,[exception description]);
        // Sandy: may be alert for user ...
        [self enableUIAccess:YES];
    }
    @finally {
    }
}

-(void) sendAction
{
    @try {
        LogInfo(@"begin");
        [config transmitSettings];
        [CC3xUtility setupUdpSocket:self.udpSocket
                               port:APP_PORT];
        _isRunning = YES;
        LogInfo(@"end");
    }
    @catch (NSException *exception) {
        LogInfo(@"exception === %@",[exception description]);
        if ( button_startconfig.selected ) {/// start button in sending mode
            [self touchToAdd:button_startconfig];
        }
    }
    @finally {
        
    }
}




//完成时关闭连接
- (void)viewWillDisappear:(BOOL)animated
{
    
    if (self.udpSocket) {
        [self.udpSocket close];
    }

//    self.udpSocket = nil;
    [self.networkConfigView removeFromSuperview];
}


//button触发配置方法
- (void)touchToAdd:(UIButton *)sender
{
    if (![CC3xUtility checkNetworkStatus]) {
        return;
    }
    if (button_startconfig.selected){
        [self stopAction];
        // Retain the UI access for the user.
        [self enableUIAccess:YES];

    }else{
        [self startConfig];
        [self startTransmitting];

    }
}





//开始配置,自定义actionsheet
- (void)startConfig
{
    NSLog(@"//开始配置,自定义actionsheet");
    //设置主视图，半透明，
    CGRect frame = self.view.frame;
    _View_config = [[UIView alloc]initWithFrame:CGRectMake(0.0, CGRectGetMidY(frame),frame.size.width, frame.size.height/2.0)];
    
//    _View_config.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"actionsheet_background"]];
    self.View_config.layer.cornerRadius = 5.0;//圆角设定，
    
    bg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"actionsheet_background"]];
    [bg setFrame:_View_config.frame];
    [self.view addSubview:bg];
    
    
    
    
    //标题设置
    UILabel * label_title = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, CGRectGetWidth(_View_config.frame), 32.0)];
    label_title.font = [UIFont systemFontOfSize:17.0];
    label_title.text = @"网络配置";
    label_title.textAlignment = NSTextAlignmentCenter;
    [self.View_config addSubview:label_title];

    label_title = nil;
    
    //设置完成时显示文本
    UITextView * textView = [[UITextView alloc]initWithFrame:CGRectMake(0, label_title.frame.size.height+2.0, _View_config.frame.size.width, _View_config.frame.size.height-label_title.frame.size.height-60.0)];
    textView.selectable = NO;
    textView.editable = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.text = @"  正在对网络进行配置";
    [_View_config addSubview:textView];
    
    
    //取消按钮
    button_cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button_cancel.frame = CGRectMake(20, self.View_config.frame.size.height-40, frame.size.width-40, 30);
    [button_cancel setBackgroundImage:[UIImage imageNamed:@"alertview_cancel_button"] forState:UIControlStateNormal];
    [button_cancel setTitle:@"取消配置" forState:UIControlStateNormal];
    [button_cancel addTarget:self action:@selector(dismissConfigView) forControlEvents:UIControlEventTouchUpInside];
    [_View_config addSubview:button_cancel];
    button_cancel.hidden = YES;
    
    
    //添加进度条动画
    _hud = [[MBProgressHUD alloc] initWithView:self.View_config];
    self.hud.frame =
    CGRectMake(0, textView.frame.origin.y + textView.frame.size.height + 10.0,
               frame.size.width,
               CGRectGetHeight(self.hud.frame));

    textView = nil;
    [_View_config addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    self.hud.delegate = self;
    __block UIButton *button = button_cancel;
    [self.hud showAnimated:YES whileExecutingBlock:^{
        button.hidden = YES;
        float progress = 0.0f;
        while (progress < 1.0f) {
            progress += 0.01f;
            self.hud.progress = progress;
            usleep(100000);
        }
    }completionBlock:^{
        button.hidden = NO;
        [self stopAction];
        [_hud removeFromSuperview];
        _hud = nil;
    }];
    
    //添加主视图到window上
    UIApplication *app = [UIApplication sharedApplication];
    [app.keyWindow addSubview:_View_config];
    
    
    
    //视图出现动画持续
    CGPoint center = _View_config.center;
    _View_config.center = CGPointMake(_View_config.center.x, frame.size.height*3/2);
    [UIView animateWithDuration:0.4 animations:^{
        _View_config.center = center;
    }];
}

-(void) stopAction{
    LogInfo(@"%s begin", __PRETTY_FUNCTION__);
    @try {
        [config stopTransmitting];
    }
    @catch (NSException *exception) {
        LogInfo(@"%s exception == %@",__FUNCTION__,[exception description]);
    }
    @finally {
        
    }
    LogInfo(@"%s end", __PRETTY_FUNCTION__);
}

//连接视图消失
- (void)dismissConfigView
{
    [self stopAction];
    [self.udpSocket close];
    [self.hud removeFromSuperview];
    [bg removeFromSuperview];

    _hud = nil;
    
    [_View_config removeFromSuperview];

    _View_config = nil;
    
    [self enableUIAccess:YES];

    _View_config = nil;
    
}
- (void)enableUIAccess:(BOOL)isEnable
{
    button_startconfig.selected = !isEnable;
    button_startconfig.userInteractionEnabled = isEnable;
    textfield_wifi.userInteractionEnabled = isEnable;
    textfield_password.userInteractionEnabled = isEnable;
    switch_showpassword.userInteractionEnabled = isEnable;
    
    
    
    
}


//wifi状态改变
- (void)wifiStatusChanged:(NSNotification *)notification
{
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//显示密码
#pragma mark uiswitch action


- (void)switched:(id)sender
{
    textfield_password.secureTextEntry = !switch_showpassword.on;
}
//键盘响应
#pragma mark keyboard delegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == textfield_wifi) {
        [textfield_password becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}
//通知
#pragma mark - notification method



- (void)appEnterInforground:(NSNotification*)notification
{
    
}


- (void)appEnterInBackground:(NSNotification*)notification
{
    
}

- (void) waitForAckThread: (id)sender{
    @try {
        LogInfo(@"%s begin", __PRETTY_FUNCTION__);
        Boolean val = [config waitForAck];
        LogInfo(@"Bool value == %d",val);
        if (val) {
            [self stopAction];
            [self performSelectorOnMainThread:@selector(stopAction)
                                   withObject:nil
                                waitUntilDone:YES];
        }
    }
    @catch (NSException *exception) {
        LogInfo(@"%s exception == %@",__FUNCTION__,[exception description]);
        /// stop here
    }
    @finally {
    }
    
    if ( [NSThread isMainThread]  == NO ){
        LogInfo(@"这不是主线程");
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }else {
        LogInfo(@"这是主线程");
    }
    LogInfo(@"%s end", __PRETTY_FUNCTION__);
}
//取消按钮
- (void)back
{
    //取消按钮从视图中移除、释放
    [button_cancel removeFromSuperview];

    button_cancel = nil;
    
    //停止、将动画条释放、赋空
    [self stopAction];
    [self.udpSocket close];
    [self.hud removeFromSuperview];
    [bg removeFromSuperview];

    _hud = nil;
    
    [_View_config removeFromSuperview];
    
    [self enableUIAccess:YES];

    _View_config = nil;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//  teset.....
@end
