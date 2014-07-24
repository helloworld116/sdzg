//
//  DevicesProfileController.m
//  winmin
//
//  Created by sdzg on 14-5-14.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DevicesProfileController.h"
#import "EditController.h"
#import "TimerController.h"
#import "DelayController.h"

#import "CC3xMessage.h"
#import "CC3xSwitch.h"
#import "CC3xUtility.h"

#import "Reachability.h"

#import "GCDAsyncUdpSocket.h"
#import <AudioToolbox/AudioToolbox.h>
@interface DevicesProfileController ()
@property (nonatomic,strong) UIImageView *body_btn_imgView;
@end

@implementation DevicesProfileController
@synthesize isSwitchOn,edit_btn,timer_btn,delay_btn,body_btn,body_imageV,lamp_imageV,delay_label2,background_imageView;
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
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //添加导航栏左按钮
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [left setFrame:CGRectMake(0, 2, 28, 28)];
    
    [left setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    
    [left addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:left];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    
    //右按钮
    UIButton *right = [UIButton buttonWithType:UIButtonTypeCustom];
    //设置按钮再导航栏中的位置
    [right setFrame:CGRectMake(290, 2, 28, 28)];
    //设置按钮图片
    [right setImage:[UIImage imageNamed:@"refresh_button"] forState:UIControlStateNormal];
    //添加触发事件
    [right addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:right];
    //barbuttonitem覆盖系统按钮
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //添加背景图片
    background_imageView = [[UIImageView alloc]initWithFrame:[self.view frame]];
//    background_imageView.image = [UIImage imageNamed:@"background.png"];
    [super.view addSubview:background_imageView];
    //‘编辑’按钮，点击触发跳转到编辑页面
    edit_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    edit_btn.frame = CGRectMake( 20, DEVICE_HEIGHT - 55, 40, 40);
    [edit_btn setImage:[UIImage imageNamed:@"edit_nor.png"] forState:UIControlStateNormal];
    [edit_btn addTarget:self action:@selector(editView) forControlEvents:UIControlEventTouchUpInside];
    //将按钮放在当前视图上，作为子视图添加
    [self.view addSubview:edit_btn];
    
    //同上,‘定时’按钮
    timer_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    timer_btn.frame = CGRectMake(3, 150, 140, 85);
    [timer_btn setImage:[UIImage imageNamed:@"smartplug_timer_task_display_background.png"] forState:UIControlStateNormal];
    [timer_btn addTarget:self action:@selector(timerView) forControlEvents:UIControlEventTouchUpInside];
    
    //定时按钮表面数字,四个imageView,
    UIImageView * time_image1 = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 35, 50)];
    time_image1.image = [UIImage imageNamed:@"digit_0"];
    time_image1.opaque = 0.4;
    UIImageView * time_image2 = [[UIImageView alloc]initWithFrame:CGRectMake(34, 5, 35, 50)];
    time_image2.image = [UIImage imageNamed:@"digit_0"];
    time_image2.opaque = 0.4;
    UIImageView * time_image3 = [[UIImageView alloc]initWithFrame:CGRectMake(67, 5, 35, 50)];
    time_image3.image = [UIImage imageNamed:@"digit_0"];
    time_image3.opaque = 0.4;
    UIImageView * time_image4 = [[UIImageView alloc]initWithFrame:CGRectMake(94, 5, 35, 50)];
    time_image4.image = [UIImage imageNamed:@"digit_0"];
    time_image4.opaque = 0.4;
    //定时按钮标题Label
    UILabel * timer_label = [[UILabel alloc]initWithFrame:CGRectMake(0, 60, 130, 24)];
    timer_label.textAlignment = NSTextAlignmentCenter;
    timer_label.text = @"预执行";
    timer_label.textColor = [UIColor redColor];
    [timer_btn addSubview:timer_label];
    [timer_btn addSubview:time_image1];
    [timer_btn addSubview:time_image2];
    [timer_btn addSubview:time_image3];
    [timer_btn addSubview:time_image4];
    [self.view addSubview:timer_btn];

    //同上，‘延时’按钮
    delay_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    delay_btn.frame = CGRectMake(3, 270, 100, 100);
    [delay_btn setImage:[UIImage imageNamed:@"delay_task.png"] forState:UIControlStateNormal];
    [delay_btn addTarget:self action:@selector(delayView) forControlEvents:UIControlEventTouchUpInside];
    //延时按钮标题Label
    UILabel * delay_label1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 17, 42, 21)];
    delay_label1.text = @"延迟时间";
    delay_label1.textColor = [UIColor whiteColor];
    delay_label1.font = [UIFont systemFontOfSize:10];
    //延时按钮时间动态显示Label
    delay_label2 = [[UILabel alloc]initWithFrame:CGRectMake(30, 39, 54, 41)];
//    delay_label2.text = @" -- hr   \n -- min";
    delay_label2.font = [UIFont systemFontOfSize:16] ;
    delay_label2.adjustsLetterSpacingToFitWidth = YES;
    delay_label2.numberOfLines = 2;
    [delay_btn addSubview:delay_label2];
    [delay_btn addSubview:delay_label1];
    [self.view addSubview:delay_btn];
    
    //lamp
    lamp_imageV = [[UIImageView alloc]initWithFrame:CGRectMake(143, 72, 177, 128)];
//    lamp_imageV.image = [UIImage imageNamed:@"lamp_light"];
    [self.view addSubview:lamp_imageV];
    
    
    //开关按钮
    body_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [body_btn setFrame:CGRectMake(143, 199, 177, 269)];
    self.body_btn_imgView = [[UIImageView alloc] initWithFrame:body_btn.frame];
    [self.view addSubview:self.body_btn_imgView];
//    [body_btn setBackgroundImage:[UIImage imageNamed:@"smartplug_open_button"] forState:UIControlStateNormal];
    [body_btn addTarget:self action:@selector(clickSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:body_btn];
    isSwitchOn = self.aSwitch.isOn;
    
    //根据开关状态初始化场景 开关/关闭
    if (isSwitchOn)
    {
        lamp_imageV.image = [UIImage imageNamed:@"lamp_light"];
        self.body_btn_imgView.image = [UIImage imageNamed:@"smartplug_open_button"];
//        [body_btn setBackgroundImage:[UIImage imageNamed:@"smartplug_open_button"] forState:UIControlStateNormal];
        
        background_imageView.image = [UIImage imageNamed:@"background.png"];
    }
    else if (!isSwitchOn)
    {
        lamp_imageV.image = [UIImage imageNamed:@"lamp_unlight"];
//        [body_btn setBackgroundImage:[UIImage imageNamed:@"smartplug_close_button"] forState:UIControlStateNormal];
        self.body_btn_imgView.image = [UIImage imageNamed:@"smartplug_close_button"];
        background_imageView.image = [UIImage imageNamed:@"background1.png"];
    }
    
    
    LogInfo(@"开关ip： %@ 接口： %d", self.aSwitch.ip, self.aSwitch.port);
    
    //添加观察者，检测isSwitchOn的值变化，让部分控件在值改变的同时进行动作
    [self addObserver:self
           forKeyPath:@"isSwitchOn"
              options:NSKeyValueObservingOptionNew
              context:nil];
    isSwitchOn = self.aSwitch.isOn;
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = self.aSwitch.switchName;
    
    //初始化udpsocket，绑定接收端口
    _udpSocket = [[GCDAsyncUdpSocket alloc]
                  initWithDelegate:self
                  delegateQueue:GLOBAL_QUEUE];
    
    if (_udpSocket.isClosed == YES || _udpSocket == nil)
    {
        [CC3xUtility setupUdpSocket:self.udpSocket
                               port:APP_PORT];
    } 
    //视图出现前添加通知观察者，（通知注册在DelayController）；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDelay:) name:@"Delay_Timer" object:nil];
}

//延时页面通知触发方法，用来时延时Label动态显示
- (void)changeDelay:(NSNotification *)noti
{
    NSDictionary * dic = [noti userInfo];
    NSString * value = [dic objectForKey:@"delayTime"];
    NSLog(@"value=%@",value);
    
    self.delayTime = [value intValue];
    
    if (!self.delayTimer)
    {
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    
    }
}


//倒计时显示，
- (void)countDown:(int)count
{
    
    self.delayTime -- ;
    NSLog(@"count = %d", count);
    if (self.delayTime <= 0)
    {
        [self.delayTimer invalidate];
        delay_label2.text = @" -- hr   \n -- min";
        NSLog(@"delay_label2.text = %@",delay_label2.text);
    }else if (self.delayTime > 0)
    {
        [self.delayTimer fire];
        int hour = self.delayTime/60;
        int min = self.delayTime%60;
        delay_label2.text = [NSString stringWithFormat:@" %0.2d hr   \n %0.2d min",hour,min];
        NSLog(@"delay_label2.text = %@",delay_label2.text);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.udpSocket!=nil && self.udpSocket) {
        [self.udpSocket close];
        _udpSocket=nil;
    }
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Delay_Timer" object:nil];
}




//通过检测isSwitchOn值变化，统一改变灯，人，背景图片
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"isSwitchOn"]) {
        BOOL on = [change[NSKeyValueChangeNewKey] boolValue];
        NSString *imageName = on ? @"lamp_light" :
        @"lamp_unlight";
        NSString * bodyName = on ? @"smartplug_open_button" :@"smartplug_close_button";
        NSString * bgName = on ? @"background.png" : @"background1.png";
        dispatch_async(dispatch_get_main_queue(), ^{
            lamp_imageV.image = [UIImage imageNamed:imageName];
            
//            self.body_btn_imgView.animationImages = @[[UIImage imageNamed:@"smartplug_loading_button"]];
//            //设定动画的播放时间
//            self.body_btn_imgView.animationDuration=0.1;
//            //设定重复播放次数
//            self.body_btn_imgView.animationRepeatCount=1;
//            
//            //开始播放动画
//            [self.body_btn_imgView startAnimating];
//            // 动画播放完成后，清空动画数组
//            
//            [self performSelector:@selector(setAnimationImages:) withObject:bodyName afterDelay:self.body_btn_imgView.animationDuration];
            
            self.body_btn_imgView.image = [UIImage imageNamed:bodyName];
            background_imageView.image = [UIImage imageNamed:bgName];
            
            NSLog(@"叫你换张光头来");
        });
    }
}

-(void)setAnimationImages:(NSString *)bodyName{
    self.body_btn_imgView.image = [UIImage imageNamed:bodyName];
}

- (void)sendMsg17
{
    //发送消息之前检测网络状态
    NetworkStatus reach = [[Reachability reachabilityForInternetConnection]
                           currentReachabilityStatus];
    //如果网络状态为没有链接，弹出提示框
    if (reach == NotReachable) {
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                   message:NSLocalizedString(@"The switch is offline", nil)
                                  delegate:self
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    //发送消息包之前检测udpsocket的状态，
    if (_udpSocket.isClosed == YES || _udpSocket == nil)
    {
        _udpSocket = [[GCDAsyncUdpSocket alloc]
                      initWithDelegate:self
                      delegateQueue:GLOBAL_QUEUE];
        [CC3xUtility setupUdpSocket:self.udpSocket
                               port:APP_PORT];
    }
    
    //根据不同的网络环境，发送 本地/远程 消息
    if (self.aSwitch.status == SWITCH_LOCAL ||
        self.aSwitch.status == SWITCH_LOCAL_LOCK) {
        //将消息初始化为data数据
        NSData *msg =
        [CC3xMessageUtil getP2dMsg11:!isSwitchOn];
        dispatch_apply(REPEATE_TIME, GLOBAL_QUEUE, ^(size_t index){
            //发送本地消息包
            [self.udpSocket sendData:msg
                              toHost:self.aSwitch.ip
                                port:self.aSwitch.port
                         withTimeout:10
                                 tag:P2D_CONTROL_REQ_11];
            
            sleep(0.1);
        });
    } else if (self.aSwitch.status == SWITCH_REMOTE ||
               self.aSwitch.status == SWITCH_REMOTE_LOCK) {
        //初始化消息为data数据
        NSData *msg =
        [CC3xMessageUtil getP2sMsg13:self.aSwitch.macAddress
                             aSwitch:!isSwitchOn];
        dispatch_apply(REPEATE_TIME, GLOBAL_QUEUE, ^(size_t index){
            //将消息包发送到服务器端
            [self.udpSocket sendData:msg
                              toHost:SERVER_IP
                                port:SERVER_PORT
                         withTimeout:10
                                 tag:P2S_SET_TIMER_REQ_1F];
        });
    }
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)checkSwitchStatus
{
   //检测网络状态
    if (self.aSwitch.status == SWITCH_OFFLINE ||
        self.aSwitch.status == SWITCH_UNKNOWN) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
//点击开关触发
- (void)clickSwitch:(id)sender
{
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
    BOOL shake =
    [[[NSUserDefaults standardUserDefaults] valueForKey:kShake] boolValue];
    if (shake) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

#pragma mark ----udp delegate
//接受到得udp数据，进行data数据的解析
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSLog(@"收到数据，慢慢跑############");
    if (data)
    {
        CC3xMessage *msg = (CC3xMessage *)filterContext;
        if (msg.msgId == 0x12 || msg.msgId == 0x14) {
            if (msg.state == 0 && !self.isLockOK) {
                self.isLockOK = YES;
                [self setValue:[NSNumber numberWithBool:!isSwitchOn]
                        forKey:@"isSwitchOn"];
                self.aSwitch.isOn = isSwitchOn;
            }
        }
        
    }
}

//查看消息包是否发送
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
didSendDataWithTag:(long)tag
{
    NSLog(@"msg %ld is sent", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
       dueToError:(NSError *)error
{
    NSLog(@"Error happens %@", error);
}
//socket是否关闭
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"DevicesProfileController UDP has Closed");
}

#pragma mark ----跳转
//跳转‘编辑’
- (void)editView
{
    EditController * edit_C = [[EditController alloc]init];
    edit_C.aSwitch = self.aSwitch;
    [self.navigationController pushViewController:edit_C animated:YES];

}

//跳转‘定时’
- (void)timerView
{
    if (self.udpSocket) {
        [self.udpSocket close];
    }
    
    TimerController * time_C = [[TimerController alloc]init];
    time_C.aSwitch = self.aSwitch;
    time_C.timerList = self.aSwitch.timerList;
//    time_C.delegate = self;
    
    CATransition * animation = [CATransition animation];
    animation.duration = 0.7f;
    animation.delegate = self;
    animation.type = @"rippleEffect";
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    
    [self.navigationController pushViewController:time_C animated:YES];

    NSLog(@"跳跳跳跳跳。。。。");
}
//跳转‘延时’
- (void)delayView
{
    DelayController * delay_C = [[DelayController alloc]init];
    delay_C.aSwitch = self.aSwitch;
    
    CATransition * animation = [CATransition animation];
    animation.duration = 0.7f;
    animation.delegate = self;
    animation.type = @"rippleEffect";
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    
    [self.navigationController pushViewController:delay_C animated:YES];

}
//返回SocketAndFileController，代理传值
- (void)back
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeAswitch:)])
    {
        [self.delegate changeAswitch:self.aSwitch];

        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}

//- (void)timer:(id)sender
//{
//    self.aSwitch.timerList = sender;
//    [self viewDidLoad];
//}





//刷新按钮
- (void)refresh
{
    NSLog(@"刷新");
    [super reloadInputViews];
    self.aSwitch.isOn = isSwitchOn;
    
    [self viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc{
//    [self addObserver:self
//           forKeyPath:@"isSwitchOn"
//              options:NSKeyValueObservingOptionNew
//              context:nil];
    [self removeObserver:self forKeyPath:@"isSwitchOn" context:nil];
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

@end
