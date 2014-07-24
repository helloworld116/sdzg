//
//  DevicesListViewController.h
//  winmin
//
//  Created by sdzg on 14-5-12.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GCDAsyncUdpSocket;
@class CC3xSwitch;
@interface DevicesListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView * _tableView;
}

@property (retain, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (retain, nonatomic) CC3xSwitch *aSwitch;
@property (assign, atomic) BOOL isLockOK;

@end
