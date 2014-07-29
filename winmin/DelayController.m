//
//  DelayController.m
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DelayController.h"
#import "GCDAsyncUdpSocket.h"
#import "CC3xUtility.h"
#import "CC3xSwitch.h"
#import "CC3xMessage.h"
@interface DelayController ()<UDPDelegate>
@property(nonatomic, strong) UIButton *
    btnOfTextfeildSide;  // textfeild旁边的按钮，用于text选中输入时，选中按钮切换到此按钮
@end

@implementation DelayController
@synthesize currentButton, content_view, field, delayTime, countDownTimer,
    startSwitch, doneButton;
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
  if ([UIViewController
          instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }
  self.navigationItem.title = self.aSwitch.switchName;

  UIImageView *background_imageView =
      [[UIImageView alloc] initWithFrame:[self.view bounds]];
  background_imageView.image = [UIImage imageNamed:@"background.png"];
  [super.view addSubview:background_imageView];

  UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];

  [left setFrame:CGRectMake(0, 2, 28, 28)];

  [left setImage:[UIImage imageNamed:@"back_button"]
        forState:UIControlStateNormal];

  [left addTarget:self
                action:@selector(back)
      forControlEvents:UIControlEventTouchUpInside];

  UIBarButtonItem *leftButton =
      [[UIBarButtonItem alloc] initWithCustomView:left];

  self.navigationItem.leftBarButtonItem = leftButton;

  self.isRefresh = NO;

  CGRect frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
  content_view = [[UIView alloc] initWithFrame:frame];
  content_view.backgroundColor = [UIColor clearColor];
  [self.view addSubview:content_view];
  UIImageView *content_bg = [[UIImageView alloc]
      initWithFrame:CGRectMake(
                        0, 0, DEVICE_WIDTH,
                        DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT)];
  content_bg.image = [UIImage imageNamed:@"window_background"];
  //    [content_bg setBounds:CGRectMake(0, 0, 260, DEVICE_HEIGHT-STATUS_HEIGHT
  //    - NAVIGATION_HEIGHT)];
  [content_view addSubview:content_bg];
  content_view.layer.cornerRadius = 5.0;

  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 160, 20)];
  label.text = @"定时任务列表";
  label.backgroundColor = [UIColor clearColor];
  label.textAlignment = NSTextAlignmentCenter;
  //    [label setBounds:CGRectMake(100 , 20, 60, 20)];
  label.textColor = [UIColor whiteColor];
  [content_view addSubview:label];

  NSArray *label_name_array =
      [NSArray arrayWithObjects:@"5分钟", @"10分钟", @"30分钟", @"60分钟",
                                @"90分钟", @"120分钟", nil];
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 2; j++) {
      UIButton *swithBtn = [UIButton buttonWithType:UIButtonTypeCustom];
      [swithBtn setFrame:CGRectMake(49 + j * 104, 67 + i * 56, 30, 30)];
      [swithBtn setImage:[UIImage imageNamed:@"unselected"]
                forState:UIControlStateNormal];
      [swithBtn setImage:[UIImage imageNamed:@"selected"]
                forState:UIControlStateSelected];
      swithBtn.tag = i * 2 + j + 300;
      [swithBtn addTarget:self
                    action:@selector(ButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
      [content_view addSubview:swithBtn];

      UILabel *label = [[UILabel alloc]
          initWithFrame:CGRectMake(79 + j * 109, 72 + i * 56, 62, 21)];
      label.text = [label_name_array objectAtIndex:i * 2 + j];
      label.textAlignment = NSTextAlignmentLeft;
      label.adjustsFontSizeToFitWidth = YES;
      label.adjustsLetterSpacingToFitWidth = YES;
      label.backgroundColor = [UIColor clearColor];
      [content_view addSubview:label];
    }
  }

  //    [label_name_array release];
  UIButton *switchBthLast = [UIButton buttonWithType:UIButtonTypeCustom];
  [switchBthLast setFrame:CGRectMake(49, 235, 30, 30)];
  switchBthLast.tag = 306;
  [switchBthLast setImage:[UIImage imageNamed:@"unselected"]
                 forState:UIControlStateNormal];
  [switchBthLast setImage:[UIImage imageNamed:@"selected"]
                 forState:UIControlStateSelected];
  //默认选中改按钮
  [switchBthLast setSelected:YES];
  self.currentButton = switchBthLast;
  self.btnOfTextfeildSide = switchBthLast;
  [switchBthLast addTarget:self
                    action:@selector(ButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
  [content_view addSubview:switchBthLast];

  field = [[UITextField alloc] initWithFrame:CGRectMake(87, 235, 63, 30)];
  field.textAlignment = UITextAlignmentCenter;
  field.enabled = YES;
  field.delegate = self;
  field.backgroundColor = [UIColor whiteColor];
  field.layer.masksToBounds = YES;
  field.layer.borderWidth = 0.5;
  field.layer.cornerRadius = 10;
  field.keyboardType = UIKeyboardTypeNumberPad;
  field.returnKeyType = UIReturnKeyDone;
  field.opaque = YES;

  [content_view addSubview:field];

  UILabel *lastLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(170, 239, 42, 21)];
  lastLabel.text = @"分钟";
  lastLabel.backgroundColor = [UIColor clearColor];
  lastLabel.textColor = [UIColor blackColor];
  [content_view addSubview:lastLabel];

  UILabel *startLabel =
      [[UILabel alloc] initWithFrame:CGRectMake(49, 296, 42, 21)];
  startLabel.text = @"操作";
  startLabel.backgroundColor = [UIColor clearColor];
  startLabel.textColor = [UIColor whiteColor];
  [content_view addSubview:startLabel];
  startSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(89, 291, 51, 31)];
  startSwitch.on = YES;
  [startSwitch addTarget:self
                  action:@selector(onOrOff)
        forControlEvents:UIControlEventValueChanged];
  [content_view addSubview:startSwitch];

  UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [saveButton setFrame:CGRectMake(40, 360, 240, 30)];
  [saveButton addTarget:self
                 action:@selector(saveDelay)
       forControlEvents:UIControlEventTouchUpInside];
  [saveButton setBackgroundImage:[UIImage imageNamed:@"save_button_image"]
                        forState:UIControlStateNormal];
  [saveButton setTitle:@"保存" forState:UIControlStateNormal];
  [content_view addSubview:saveButton];

  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(numbKeyboardWillShow:)
             name:UIKeyboardWillShowNotification
           object:self.view.window];
  [UdpSocketUtil shareInstance].delegate = self;
  [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                     aSwitch:self.aSwitch];
}

- (void)viewWillDisappear:(BOOL)animated {
  [UdpSocketUtil shareInstance].delegate = nil;
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
  [super viewWillDisappear:animated];
}

- (void)ButtonAction:(UIButton *)sender {
  if (sender != currentButton) {
    currentButton.selected = NO;
    currentButton = sender;
  }
  if (sender != self.btnOfTextfeildSide) {
    [self doneButton:nil];
  } else {
    [field becomeFirstResponder];
  }
  currentButton.selected = YES;
}

- (void)onOrOff {
  //    if (startSwitch.on == YES)
  //    {
  //        self.aSwitch.isOn = YES;
  //    }else
  //    {
  //        self.aSwitch.isOn = NO;
  //    }
}

#pragma mark---timeOut
//- (void)timerOut
//{
//    __block int timeout = delayTime * 60; //倒计时时间
//    dispatch_queue_t queue =
//    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_source_t _timer =
//    dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
//    dispatch_source_set_timer(_timer,dispatch_walltime(NULL,
//    0),60.0*NSEC_PER_SEC, 0); //每60秒执行
//    dispatch_source_set_event_handler(_timer, ^{
//        if(timeout<=0){ //倒计时结束，关闭
//            dispatch_source_cancel(_timer);
//            dispatch_release(_timer);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //设置界面的按钮显示 根据自己需求设置
//
//                self.aSwitch.isOn = YES;
//
//            });
//        }else
//        {
//            int hours = timeout / 3600;
//            int minutes = (timeout / 60) % 60;
//         NSString *strTime = [NSString stringWithFormat:@"%.2d时%.2d分",hours,
//         minutes];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //设置界面的按钮显示 根据自己需求设置
//                NSLog(@"strTime %@",strTime);
//                NSLog(@"timeOut %d",timeout);
//            });
//            timeout--;
//
//        }
//    });
//    dispatch_resume(_timer);
//
//}

#pragma mark---txetfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if ([textField isEqual:field]) {
    [self ButtonAction:self.btnOfTextfeildSide];
    if (self.view.frame.origin.y >= 0) {
      [self setViewMoveUp:YES];
    }
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([textField isEqual:field]) {
    if (self.view.frame.origin.y < 0) {
      [self setViewMoveUp:NO];
    }
  }
}

- (void)setViewMoveUp:(BOOL)movedUp {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.5];
  CGRect rect = self.view.frame;
  if (movedUp) {
    rect.origin.y -= 70;
  } else {
    rect.origin.y += 70;
  }
  self.view.frame = rect;
  [UIView commitAnimations];
}

- (void)numbKeyboardWillShow:(NSNotification *)notification {
  doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [doneButton setFrame:CGRectMake(0, DEVICE_HEIGHT - 53, 106, 53)];
  doneButton.adjustsImageWhenHighlighted = NO;
  [doneButton setImage:[UIImage imageNamed:@"btn_done_up"]
              forState:UIControlStateNormal];
  [doneButton setImage:[UIImage imageNamed:@"btn_done_down"]
              forState:UIControlStateHighlighted];
  [doneButton addTarget:self
                 action:@selector(doneButton:)
       forControlEvents:UIControlEventTouchUpInside];

  UIWindow *tempWindow =
      [[[UIApplication sharedApplication] windows] objectAtIndex:1];
  if (doneButton.superview == nil) {
    [tempWindow addSubview:doneButton];
  }

  if ([field isFirstResponder] && self.view.frame.origin.y >= 0) {
    [self setViewMoveUp:YES];
  } else if (![field isFirstResponder] && self.view.frame.origin.y < 0) {
    [self setViewMoveUp:NO];
  }
}
- (void)doneButton:(id)sender {
  [field resignFirstResponder];
  [doneButton removeFromSuperview];
  doneButton = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)saveDelay {
  switch (currentButton.tag) {
    case 300:
      delayTime = 5;
      break;
    case 301:
      delayTime = 10;
      break;
    case 302:
      delayTime = 30;
      break;
    case 303:
      delayTime = 60;
      break;
    case 304:
      delayTime = 90;
      break;
    case 305:
      delayTime = 120;
      break;
    case 306:
      delayTime = [field.text intValue];
      break;

    default:
      break;
  }
  [[MessageUtil shareInstance] sendMsg4DOr4F:self.udpSocket
                                     aSwitch:self.aSwitch
                                   delayTime:delayTime
                                    switchOn:startSwitch.on];

  //    [self timerOut];
}

- (void)back {
  if (doneButton) {
    [doneButton removeFromSuperview];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UDPDelegate
- (void)responseMsgId4EOr50:(CC3xMessage *)msg {
  if (msg.state == 0) {
    dispatch_async(dispatch_get_main_queue(), ^{ [self back]; });
  }
}

- (void)noResponseMsgId4EOr50 {
  [[MessageUtil shareInstance] sendMsg4DOr4F:self.udpSocket
                                     aSwitch:self.aSwitch
                                   delayTime:delayTime
                                    switchOn:startSwitch.on];
}

- (void)noSendMsgId4DOr4F {
  [[MessageUtil shareInstance] sendMsg4DOr4F:self.udpSocket
                                     aSwitch:self.aSwitch
                                   delayTime:delayTime
                                    switchOn:startSwitch.on];
}

- (void)responseMsgId54Or56:(CC3xMessage *)msg {
  if (msg.delay > 0) {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.field.text = [NSString stringWithFormat:@"%u", msg.delay];
        self.startSwitch.on = msg.isOn;
        UIButton *btn = (UIButton *)[self.content_view viewWithTag:306];
        btn.selected = YES;
    });
  }
}

- (void)noResponseMsgId54Or56 {
  [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                     aSwitch:self.aSwitch];
}

- (void)noSendMsgId53Or55 {
  [[MessageUtil shareInstance] sendMsg53Or55:self.udpSocket
                                     aSwitch:self.aSwitch];
}
@end
