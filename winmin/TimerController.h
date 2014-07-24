//
//  TimerController.h
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerTableViewCell.h"
#import "AddTimerController.h"
#import "GCDAsyncUdpSocket.h"
@class CC3xSwitch;

@class GCDAsyncUdpSocket;
@class DevicesProfileController;

//@protocol TimerTaskDelegate <NSObject>
//
//- (void)timer:(id)sender;
//
//@end

@interface TimerController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,TimerTableViewCellDelegate,GCDAsyncUdpSocketDelegate>
{
    
    
//    id<TimerTaskDelegate> _delegate;
}
//@property (assign, nonatomic) id<TimerTaskDelegate> delegate;

@property (retain, nonatomic) UIView * content_view;
@property (retain, nonatomic) UITableView * timer_table;

@property (retain, nonatomic) CC3xSwitch *aSwitch;

@property (nonatomic, retain) TimerTableViewCell * selectedCell;

@property (retain, atomic) NSMutableArray *timerList;

@property (retain, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (atomic, assign) BOOL isSwitchToggleOk;

@property (atomic, assign) BOOL isRefresh;

@property (nonatomic, retain) UISwitch * selectedSwitch;

@property (nonatomic, retain) UIButton * addTimer_btn;

@property (nonatomic, retain) DevicesProfileController * deices;

- (void)backToDevicesWithTimer;

- (void)refreshTimerList;

- (void)toggleSwitch:(id)sender;

- (void)addTimer;

- (void)refresh;

- (void)godevices;

@end
