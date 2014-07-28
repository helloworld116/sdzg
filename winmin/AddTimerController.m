//
//  AddTimerController.m
//  winmin
//
//  Created by sdzg on 14-5-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AddTimerController.h"
#import "GCDAsyncUdpSocket.h"
#import "CC3xUtility.h"
#import "CC3xTimerTask.h"
#import "CC3xMessage.h"
#import "CC3xSwitch.h"
#import "Reachability.h"
@interface AddTimerController ()<UDPDelegate>
@property(nonatomic, strong) NSString *startTime,
    *endTime;  //保存开始时间和结束时间，以便弹出时间选择器时选中该时间
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation AddTimerController
@synthesize mondayButton, tuesdayButton, wensdayButton, thursdayButton,
    fridayButton, saturdayButton, sundayButton, startTimeLabel, startTimeButton,
    startTimeSwitch, endTimeLabel, endTimeButton, endTimeSwtich, saveButton,
    content_View;
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

  self.navigationItem.title = @"定时任务";

  // background 背景图片
  UIImageView *background_imageView =
      [[UIImageView alloc] initWithFrame:[self.view frame]];
  background_imageView.image = [UIImage imageNamed:@"background.png"];
  [super.view addSubview:background_imageView];

  // navi 导航栏左按钮，
  UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];

  [left setFrame:CGRectMake(0, 2, 28, 28)];

  [left setImage:[UIImage imageNamed:@"back_button"]
        forState:UIControlStateNormal];
  //按钮触发back方法返回上一页面
  [left addTarget:self
                action:@selector(back)
      forControlEvents:UIControlEventTouchUpInside];

  UIBarButtonItem *leftButton =
      [[UIBarButtonItem alloc] initWithCustomView:left];

  self.navigationItem.leftBarButtonItem = leftButton;

  //任务列表背景图片，及范围
  CGRect frame = CGRectMake(0, STATUS_HEIGHT + NAVIGATION_HEIGHT, DEVICE_WIDTH,
                            DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT);
  content_View = [[UIView alloc] initWithFrame:frame];
  content_View.backgroundColor = [UIColor clearColor];
  [self.view addSubview:content_View];
  UIImageView *content_bg = [[UIImageView alloc]
      initWithFrame:CGRectMake(
                        0, 0, DEVICE_WIDTH,
                        DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT)];
  content_bg.image = [UIImage imageNamed:@"window_background"];
  //    //    [content_bg setBounds:CGRectMake(0, 0, 260,
  //    DEVICE_HEIGHT-STATUS_HEIGHT - NAVIGATION_HEIGHT)];
  [content_View addSubview:content_bg];
  content_View.layer.cornerRadius = 5.0;

  //定时任务label的创建，文字格式等，
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 160, 20)];
  label.text = @"编辑任务";
  label.textAlignment = NSTextAlignmentCenter;
  //    [label setBounds:CGRectMake(100 , 20, 60, 20)];
  label.textColor = [UIColor whiteColor];
  [content_View addSubview:label];

  //重复星期选择按钮Mon.-Sun.
  mondayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [mondayButton setFrame:CGRectMake(48, 90, 33, 32)];
  [mondayButton addTarget:self
                   action:@selector(selectDayOfWeek:)
         forControlEvents:UIControlEventTouchUpInside];
  [mondayButton setTitle:@"一" forState:UIControlStateNormal];
  mondayButton.selected = NO;
  [mondayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:mondayButton];

  tuesdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [tuesdayButton setFrame:CGRectMake(81, 90, 33, 32)];
  [tuesdayButton addTarget:self
                    action:@selector(selectDayOfWeek:)
          forControlEvents:UIControlEventTouchUpInside];
  [tuesdayButton setTitle:@"二" forState:UIControlStateNormal];
  tuesdayButton.selected = NO;
  [tuesdayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:tuesdayButton];

  wensdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [wensdayButton setFrame:CGRectMake(114, 90, 33, 32)];
  [wensdayButton addTarget:self
                    action:@selector(selectDayOfWeek:)
          forControlEvents:UIControlEventTouchUpInside];
  [wensdayButton setTitle:@"三" forState:UIControlStateNormal];
  wensdayButton.selected = NO;
  [wensdayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:wensdayButton];

  thursdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [thursdayButton setFrame:CGRectMake(147, 90, 33, 32)];
  [thursdayButton addTarget:self
                     action:@selector(selectDayOfWeek:)
           forControlEvents:UIControlEventTouchUpInside];
  [thursdayButton setTitle:@"四" forState:UIControlStateNormal];
  thursdayButton.selected = NO;
  [thursdayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:thursdayButton];

  fridayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [fridayButton setFrame:CGRectMake(180, 90, 33, 32)];
  [fridayButton addTarget:self
                   action:@selector(selectDayOfWeek:)
         forControlEvents:UIControlEventTouchUpInside];
  [fridayButton setTitle:@"五" forState:UIControlStateNormal];
  fridayButton.selected = NO;
  [fridayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:fridayButton];

  saturdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [saturdayButton setFrame:CGRectMake(213, 90, 33, 32)];
  [saturdayButton addTarget:self
                     action:@selector(selectDayOfWeek:)
           forControlEvents:UIControlEventTouchUpInside];
  [saturdayButton setTitle:@"六" forState:UIControlStateNormal];
  saturdayButton.selected = NO;
  [saturdayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:saturdayButton];

  sundayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [sundayButton setFrame:CGRectMake(246, 90, 33, 32)];
  [sundayButton addTarget:self
                   action:@selector(selectDayOfWeek:)
         forControlEvents:UIControlEventTouchUpInside];
  [sundayButton setTitle:@"日" forState:UIControlStateNormal];
  sundayButton.selected = NO;
  [sundayButton
      setBackgroundImage:[UIImage imageNamed:@"smartplug_timer_week_button_nor"]
                forState:UIControlStateNormal];
  [content_View addSubview:sundayButton];

  //重复label
  UILabel *repeat_label =
      [[UILabel alloc] initWithFrame:CGRectMake(40, 60, 80, 25)];
  repeat_label.text = @"重复";
  [content_View addSubview:repeat_label];

  //重复背景
  UIImageView *repeat_bg =
      [[UIImageView alloc] initWithFrame:CGRectMake(30, 53, 260, 80)];
  repeat_bg.image = [UIImage imageNamed:@"smartplug_timer_repeat_background"];
  [content_View insertSubview:repeat_bg atIndex:1];

  //开始时间label
  startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 167, 81, 21)];
  startTimeLabel.text = @"开启时间";
  [content_View addSubview:startTimeLabel];

  //开始时间button，button触发时间选择器，button的titlelabel.text属性显示当前时间（后面设置）
  startTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [startTimeButton setFrame:CGRectMake(110, 162, 120, 30)];
  [startTimeButton.layer setMasksToBounds:YES];
  startTimeButton.layer.borderWidth = 0.8;
  startTimeButton.layer.cornerRadius = 10;
  startTimeButton.opaque = YES;
  [startTimeButton addTarget:self
                      action:@selector(showTimePickerView:)
            forControlEvents:UIControlEventTouchUpInside];
  [content_View addSubview:startTimeButton];
  // TODO:时间选择button确定开始时间是否有效，selected属性确定
  startTimeSwitch = [UIButton buttonWithType:UIButtonTypeCustom];
  [startTimeSwitch setFrame:CGRectMake(254, 162, 30, 30)];
  [startTimeSwitch addTarget:self
                      action:@selector(timeButtonSelected:)
            forControlEvents:UIControlEventTouchUpInside];
  [content_View addSubview:startTimeSwitch];

  //    UIImageView * start_bg = [[UIImageView
  //    alloc]initWithFrame:CGRectMake(30, 150, 260, 40)];
  //    start_bg.image = [UIImage
  //    imageNamed:@"smartplug_timer_repeat_background"];
  //    [content_View insertSubview:start_bg atIndex:1];

  //关闭时间同上
  endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 230, 81, 21)];
  endTimeLabel.text = @"关闭时间";
  [content_View addSubview:endTimeLabel];

  endTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [endTimeButton setFrame:CGRectMake(110, 225, 120, 30)];
  [endTimeButton addTarget:self
                    action:@selector(showTimePickerView:)
          forControlEvents:UIControlEventTouchUpInside];
  [endTimeButton.layer setMasksToBounds:YES];
  endTimeButton.layer.borderWidth = 0.8;
  endTimeButton.layer.cornerRadius = 10;
  endTimeButton.opaque = YES;
  [content_View addSubview:endTimeButton];

  endTimeSwtich = [UIButton buttonWithType:UIButtonTypeCustom];
  [endTimeSwtich setFrame:CGRectMake(254, 225, 30, 30)];
  [endTimeSwtich addTarget:self
                    action:@selector(timeButtonSelected:)
          forControlEvents:UIControlEventTouchUpInside];
  [content_View addSubview:endTimeSwtich];

  //    UIImageView * end_bg = [[UIImageView alloc]initWithFrame:CGRectMake(30,
  //    216, 260, 40)];
  //    end_bg.image = [UIImage
  //    imageNamed:@"smartplug_timer_repeat_background"];
  //    [content_View insertSubview:end_bg atIndex:1];

  //保存按钮，触发保存时间列表，发送udp
  saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [saveButton setFrame:CGRectMake(40, 363, 240, 30)];
  [saveButton addTarget:self
                 action:@selector(saveTimer:)
       forControlEvents:UIControlEventTouchUpInside];
  [saveButton setBackgroundImage:[UIImage imageNamed:@"save_button_image"]
                        forState:UIControlStateNormal];
  [saveButton setTitle:@"保存" forState:UIControlStateNormal];
  [content_View addSubview:saveButton];

  //给定时间列表数组8个内存
  if (!self.timerList) {
    // timerlist为空
    self.timerList = [NSMutableArray arrayWithCapacity:8];
  }
  //设置公用的时间选择器
  self.dateFormatter = [[NSDateFormatter alloc] init];
  [self.dateFormatter setDateFormat:@"HH:mm"];
  if (self.timerTask) {
    //选中星期，条件控制选择后触发方法selectDayOfWeek
    self.timerTask.week &MONDAY ? [self selectDayOfWeek:self.mondayButton]
                                : nil;
    self.timerTask.week &TUESDAY ? [self selectDayOfWeek:self.tuesdayButton]
                                 : nil;
    self.timerTask.week &WENSDAY ? [self selectDayOfWeek:self.wensdayButton]
                                 : nil;
    self.timerTask.week &THURSDAY ? [self selectDayOfWeek:self.thursdayButton]
                                  : nil;
    self.timerTask.week &FRIDAY ? [self selectDayOfWeek:self.fridayButton]
                                : nil;
    self.timerTask.week &SATURDAY ? [self selectDayOfWeek:self.saturdayButton]
                                  : nil;
    self.timerTask.week &SUNDAY ? [self selectDayOfWeek:self.sundayButton]
                                : nil;
    //让开始button显示当前时间
    self.startTime =
        [NSString stringWithFormat:@"%02d:%02d", _timerTask.startTime / 3600,
                                   (_timerTask.startTime % 3600) / 60];
    [startTimeButton setTitle:self.startTime forState:UIControlStateNormal];
    //让结束button显示当前时间
    self.endTime =
        [NSString stringWithFormat:@"%02d:%02d", _timerTask.endTime / 3600,
                                   (_timerTask.endTime % 3600) / 60];
    [endTimeButton setTitle:self.endTime forState:UIControlStateNormal];
    //
    if (self.timerTask.isStartTimeOn) {
      self.startTimeSwitch.selected = YES;
      [self.startTimeSwitch setImage:[UIImage imageNamed:@"selected.png"]
                            forState:UIControlStateNormal];
    } else {
      self.startTimeSwitch.selected = NO;
      [self.startTimeSwitch setImage:[UIImage imageNamed:@"unselected.png"]
                            forState:UIControlStateNormal];
    }
    if (self.timerTask.isEndTimeOn) {
      self.endTimeSwtich.selected = YES;
      [self.endTimeSwtich setImage:[UIImage imageNamed:@"selected.png"]
                          forState:UIControlStateNormal];
    } else {
      self.endTimeSwtich.selected = NO;
      [self.endTimeSwtich setImage:[UIImage imageNamed:@"unselected.png"]
                          forState:UIControlStateNormal];
    }
  } else {
    //默认打开
    startTimeSwitch.selected = YES;
    [startTimeSwitch setImage:[UIImage imageNamed:@"selected"]
                     forState:UIControlStateNormal];
    endTimeSwtich.selected = YES;
    [endTimeSwtich setImage:[UIImage imageNamed:@"selected"]
                   forState:UIControlStateNormal];

    //获取时间显示
    self.startTime = [self.dateFormatter
        stringFromDate:[NSDate dateWithTimeIntervalSinceNow:5 * 60]];
    self.endTime = [self.dateFormatter
        stringFromDate:[NSDate dateWithTimeIntervalSinceNow:15 * 60]];
    if (self.startTimeSwitch.selected) {
      [self.startTimeButton setTitle:self.startTime
                            forState:UIControlStateNormal];
    }
    if (self.endTimeSwtich.selected) {
      [self.endTimeButton setTitle:self.endTime forState:UIControlStateNormal];
    }
  }
  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [UdpSocketUtil shareInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
  [UdpSocketUtil shareInstance].delegate = nil;
  [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
  // layel层视图，主要是时间选择视图
  CGRect frame = self.timePickerView.frame;
  frame.origin.y = self.view.frame.size.height;
  self.timePickerView.frame = frame;
  LogInfo(@"%@", NSStringFromCGRect(self.timePickerView.frame));
}

//选中重复的星期，图片选择判断
- (void)selectDayOfWeek:(id)sender {
  UIButton *button = (UIButton *)sender;
  button.selected = !button.selected;
  if (button.selected) {
    [button setBackgroundImage:[UIImage imageNamed:@"edit_week_select"]
                      forState:UIControlStateNormal];
  } else {
    [button setBackgroundImage:[UIImage imageNamed:@"edit_week_unselect"]
                      forState:UIControlStateNormal];
  }
}
//弹出时间选择视图
- (void)showTimePickerView:(id)sender {
  //创建timePicker视图
  self.timePickerView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 328, 320, DEVICE_HEIGHT - 328 / 2.0)];
  self.timePickerView.layer.cornerRadius = 10.0;
  self.timePickerView.backgroundColor = [UIColor whiteColor];
  //添加主视图到window上
  UIApplication *app = [UIApplication sharedApplication];
  [app.keyWindow addSubview:self.timePickerView];
  //添加toolbar 用来确定选择时间和取消视图
  UIToolbar *toolBar =
      [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

  toolBar.barStyle = UIBarStyleBlackOpaque;

  // toolbar上得按钮及分别触发的方法
  UIBarButtonItem *doneButton =
      [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(timePickerDone:)];

  UIBarButtonItem *cancelButton =
      [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(timePickerCancel:)];

  NSArray *tool_array =
      [[NSArray alloc] initWithObjects:doneButton, cancelButton, nil];
  [toolBar setItems:tool_array];
  [self.timePickerView addSubview:toolBar];

  //时间选择
  _datePicker = [[UIDatePicker alloc]
      initWithFrame:CGRectMake(0, 44, 320, DEVICE_HEIGHT - 372)];
  _datePicker.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  _datePicker.datePickerMode = UIDatePickerModeTime;
  [self.timePickerView addSubview:_datePicker];

  if (sender == self.startTimeButton) {
    self.datePicker.tag = 1;
    NSDate *defaultDate = [self.dateFormatter dateFromString:self.startTime];
    _datePicker.date = defaultDate;
  } else {
    self.datePicker.tag = 2;
    NSDate *defaultDate = [self.dateFormatter dateFromString:self.endTime];
    _datePicker.date = defaultDate;
  }
  CGRect frame = self.timePickerView.frame;
  frame.origin.y =
      self.view.frame.size.height - self.timePickerView.frame.size.height;
  [UIView animateWithDuration:0.3
                   animations:^{ self.timePickerView.frame = frame; }];
}
//开启 / 关闭图片选择显示
- (void)timeButtonSelected:(id)sender {
  UIButton *button = (UIButton *)sender;
  button.selected = !button.selected;
  if (button.isSelected) {
    [button setImage:[UIImage imageNamed:@"selected.png"]
            forState:UIControlStateSelected];
  } else {
    [button setImage:[UIImage imageNamed:@"unselected.png"]
            forState:UIControlStateNormal];
  }
}

//取消
- (void)timePickerCancel:(id)sender {
  CGRect frame = self.timePickerView.frame;
  frame.origin.y = self.view.frame.size.height;
  [UIView animateWithDuration:0.3
                   animations:^{ self.timePickerView.frame = frame; }];
  NSLog(@"取消视图");
}
//确定
- (void)timePickerDone:(id)sender {
  NSLog(@"开始算时间");
  //时间选择时，输出格式
  NSString *dateString =
      [self.dateFormatter stringFromDate:self.datePicker.date];
  if (self.datePicker.tag == 1) {
    [self.startTimeButton setTitle:dateString forState:UIControlStateNormal];
  } else {
    [self.endTimeButton setTitle:dateString forState:UIControlStateNormal];
  }
  [self timePickerCancel:nil];
}
//查询设备状态，如果状态为离线，返回根视图
- (void)checkSwitchStatus {
  if (self.aSwitch.status == SWITCH_UNKNOWN ||
      self.aSwitch.status == SWITCH_OFFLINE) {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}
//保存定时器列表，先将数据整理，保存形成task类，然后都放入timerList中
- (void)saveTimer:(id)sender {
  if (![CC3xUtility checkNetworkStatus]) {
    return;
  }
  [self checkSwitchStatus];
  //在定时器列表>=8的时候弹出警示框提示“最大定时数量为8”
  if (self.timerList.count >= 8 && !self.timerTask) {
    UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"Warning", nil)
                  message:NSLocalizedString(@"Max timer number is 8", nil)
                 delegate:nil
        cancelButtonTitle:NSLocalizedString(@"OK", nil)
        otherButtonTitles:nil, nil];
    [alert show];

    [self.navigationController popViewControllerAnimated:YES];
    return;
  }
  //创建定时，
  CC3xTimerTask *task = [[CC3xTimerTask alloc] init];
  if (self.timerTask) {
    task.week = self.timerTask.week;
    task.startTime = self.timerTask.startTime;
    [task setStartTimeON:self.timerTask.isStartTimeOn];
    task.endTime = self.timerTask.endTime;
    [task setEndTimeOn:self.timerTask.isEndTimeOn];
    [task setTaskOn:self.timerTask.isTaskOn];
  } else {
    [task setTaskOn:YES];
  }

  task.week =
      self.mondayButton.selected << 0 | self.tuesdayButton.selected << 1 |
      self.wensdayButton.selected << 2 | self.thursdayButton.selected << 3 |
      self.fridayButton.selected << 4 | self.saturdayButton.selected << 5 |
      self.sundayButton.selected << 6;
  //获取开始，停止时间，如果时间确定按钮为空，则置零时间
  if (self.startTimeSwitch.selected) {
    if (self.startTimeButton.titleLabel.text) {
      NSArray *time = [self.startTimeButton.titleLabel.text
          componentsSeparatedByString:@":"];
      task.startTime =
          [time[0] doubleValue] * 3600 + [time[1] doubleValue] * 60;
    }
  } else {
    task.startTime = 0xffff;
  }
  if (self.endTimeSwtich.selected) {
    if (self.endTimeButton.titleLabel.text) {
      NSArray *time =
          [self.endTimeButton.titleLabel.text componentsSeparatedByString:@":"];
      task.endTime = [time[0] doubleValue] * 3600 + [time[1] doubleValue] * 60;
    }
  } else {
    task.endTime = 0xffff;
  }
  //  NSLog(@"addtimer 481: \nstart time is %lu, end time is %lu",
  //        (unsigned long)task.startTime, (unsigned long)task.endTime);

  [task setStartTimeON:self.startTimeSwitch.selected];
  [task setEndTimeOn:self.endTimeSwtich.selected];
  //???:数组timelist的元素不见了，，，，

  //判断定时任务是不是列表里面的，如果是替换，不是这添加
  if (self.timerTask) {
    NSUInteger index = [self.timerList indexOfObject:self.timerTask];
    [self.timerList replaceObjectAtIndex:index withObject:task];
    //    NSLog(@"替换timerList数组元素%d", index);
  } else {
    [self.timerList addObject:task];
    //    NSLog(@"添加timerList元素");
  }
  [[MessageUtil shareInstance] sendMsg1DOr1F:self.udpSocket
                                     aSwitch:self.aSwitch
                                    timeList:self.timerList];
}

#pragma mark---action sheet
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
  NSString *dateString =
      [self.dateFormatter stringFromDate:self.datePicker.date];
  if (self.datePicker.tag == 1) {
    [self.startTimeButton setTitle:dateString forState:UIControlStateNormal];
  } else {
    [self.endTimeButton setTitle:dateString forState:UIControlStateNormal];
  }
  [self timePickerCancel:nil];
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UDPDelegate
- (void)responseMsgId1EOr20:(CC3xMessage *)msg {
  dispatch_async(dispatch_get_main_queue(), ^{
      [self.navigationController popViewControllerAnimated:YES];
  });
}

- (void)noResponseMsgId1EOr20 {
  [[MessageUtil shareInstance] sendMsg1DOr1F:self.udpSocket
                                     aSwitch:self.aSwitch
                                    timeList:self.timerList];
}

- (void)noSendMsgId17Or19 {
  [[MessageUtil shareInstance] sendMsg1DOr1F:self.udpSocket
                                     aSwitch:self.aSwitch
                                    timeList:self.timerList];
}
@end
