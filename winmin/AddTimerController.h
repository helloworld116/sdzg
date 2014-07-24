//
//  AddTimerController.h
//  winmin
//
//  Created by sdzg on 14-5-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
//@class CC3xSwitch;
//@class CC3xTimerTask;

@class TimerController;
@protocol AddTimerDelegate <NSObject>

- (void)changeTimerList:(id)sender;

@end

@interface AddTimerController : UIViewController<UIActionSheetDelegate,GCDAsyncUdpSocketDelegate>

{
    
//    id<AddTimerDelegate> _delegate;
}
@property (retain, nonatomic) UIView * content_View;

//@property (assign, nonatomic) id<AddTimerDelegate> delegate;

@property (retain, nonatomic) CC3xSwitch *aSwitch;

@property (retain, nonatomic) CC3xTimerTask *timerTask;

@property (retain, nonatomic) NSMutableArray *timerList;

@property (retain, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (retain, nonatomic)  UIButton *mondayButton;

@property (retain, nonatomic)  UIButton *tuesdayButton;

@property (retain, nonatomic)  UIButton *wensdayButton;

@property (retain, nonatomic)  UIButton *thursdayButton;

@property (retain, nonatomic)  UIButton *fridayButton;

@property (retain, nonatomic)  UIButton *saturdayButton;

@property (retain, nonatomic)  UIButton *sundayButton;

@property (retain, nonatomic)  UILabel *startTimeLabel;

@property (retain, nonatomic)  UIButton *startTimeButton;

@property (retain, nonatomic)  UIButton *startTimeSwitch;

@property (retain, nonatomic)  UILabel *endTimeLabel;

@property (retain, nonatomic)  UIButton *endTimeButton;

@property (retain, nonatomic)  UIButton *endTimeSwtich;

@property (retain, nonatomic)  UIDatePicker *datePicker;

@property (retain, nonatomic)  UIView *timePickerView;

@property (retain, nonatomic)  UIButton *saveButton;

@property (retain, nonatomic) TimerController * timer;

- (void)selectDayOfWeek:(id)sender;

- (void)showTimePickerView:(id)sender;

- (void)timeButtonSelected:(id)sender;


- (void)timePickerCancel:(id)sender;


- (void)timePickerDone:(id)sender;

- (void)saveTimer:(id)sender;

- (void)back;
@end
