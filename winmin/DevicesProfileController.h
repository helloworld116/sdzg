//
//  DevicesProfileController.h
//  winmin
//
//  Created by sdzg on 14-5-14.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerController.h"
#import "DelayController.h"



@class GCDAsyncUdpSocket;
@class CC3xSwitch;

@protocol ChangeDelegate <NSObject>

- (void)changeAswitch:(id)sender;

@end


@interface DevicesProfileController : UIViewController<UIAlertViewDelegate,GCDAsyncUdpSocketDelegate>
{

}

@property (nonatomic, retain) UIButton * timer_btn;
@property (nonatomic, retain) UIButton * edit_btn;
@property (nonatomic, retain) UIButton * delay_btn;
@property (nonatomic, retain) UIButton * body_btn;
@property (nonatomic, retain) UILabel * delay_label2;
@property (nonatomic, retain) UIImageView * body_imageV;
@property (nonatomic, retain) UIImageView * lamp_imageV;
@property (nonatomic, retain) UIImageView * background_imageView;

@property (nonatomic, assign) id<ChangeDelegate> delegate;
@property (nonatomic, assign) BOOL isSwitchOn;
@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * macAddress;
@property (nonatomic ,retain) UIImage * device_image;
@property (nonatomic ,retain) UIImage * status_image;



@property (retain, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (retain, nonatomic) CC3xSwitch *aSwitch;
@property (assign, atomic) BOOL isLockOK;




@property (nonatomic, retain) DelayController * delay;
@property (nonatomic, retain) NSTimer * delayTimer;
@property (nonatomic, assign) NSInteger delayTime;


@property (nonatomic, retain) TimerController * timer;


- (void)back;

- (void)refresh;

- (void)editView;

- (void)timerView;

- (void)delayView;

- (void)clickSwitch:(id) sender;

- (void)countDown:(int)count;

- (void)changeDelay:(NSNotification *)noti;

@end
