//
//  DelayController.h
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
@class GCDAsyncUdpSocket;
@class CC3xSwitch;

@protocol DelayDelegate <NSObject>


@end
@interface DelayController : UIViewController<UITextFieldDelegate,GCDAsyncUdpSocketDelegate>
{
}

@property (nonatomic, retain) UIView * content_view;
@property (nonatomic, retain) UITextField * field;
@property (nonatomic, retain) UIButton * doneButton;
@property (nonatomic, assign) NSInteger delayTime;
@property (nonatomic, retain) NSTimer * countDownTimer;
@property (nonatomic, retain) UISwitch * startSwitch;




@property (nonatomic, retain) GCDAsyncUdpSocket * udpSocket;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, retain) CC3xSwitch * aSwitch;
@property (nonatomic, assign) id<DelayDelegate> delegate;
@property (nonatomic, retain) NSMutableDictionary * swithDic;
@property (nonatomic, retain) UIButton * currentButton;
- (void)back;

- (void)saveDelay;

//- (void)timerOut;
- (void)onOrOff;

- (void)ButtonAction:(UIButton *)sender;

- (void)doneButton:(id)sender;

@end

