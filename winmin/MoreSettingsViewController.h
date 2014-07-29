//
//  MoreSettingsViewController.h
//  winmin
//
//  Created by sdzg on 14-5-12.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "CC3xUtility.h"
#import "CC3xAPManager.h"
#import "CC3xMoreAction.h"

@interface MoreSettingsViewController
    : UIViewController<UITableViewDataSource, UITableViewDelegate,
                       UIAlertViewDelegate, UIActionSheetDelegate,
                       GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate> {
}

@property(nonatomic, retain) UITableView* _tableView;
@property(nonatomic, retain) NSArray* cell_name_array;
@property(nonatomic, retain) NSArray* cell_image_array;
@property(nonatomic, assign) dispatch_queue_t socketQueue;

@property(nonatomic, retain) GCDAsyncSocket* tcpSocket;
@property(nonatomic, retain) GCDAsyncUdpSocket* udpSocket;
@property(nonatomic, retain) GCDAsyncUdpSocket* clientUdpSocket;
@property(nonatomic, assign) BOOL udpIsRunning;
@property(nonatomic, assign) BOOL tcpIsRunning;

@property(nonatomic, retain) NSMutableArray* connectedSockets;
@property(nonatomic, retain) NSTimer* sendInfoTimer;

//- (void)startToExport;
//
//- (void)broadAddress;
//
//- (void)sendInfo;
//
//- (void)stopBroadcast;

@end
