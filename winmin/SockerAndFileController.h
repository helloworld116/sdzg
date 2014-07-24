//
//  SockerAndFileController.h
//  winmin
//
//  Created by sdzg on 14-5-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomCell.h"

#import "CC3xSwitch.h"
#import "CC3xUtility.h"
#import "CC3xMessage.h"

#import "Reachability.h"
#import "GDataXMLNode.h"
#import "GCDAsyncUdpSocket.h"

#import "DevicesProfileController.h"
@interface SockerAndFileController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate,GCDAsyncUdpSocketDelegate,UITableViewDataSource,UITableViewDelegate,ChangeDelegate>
{
    
}
@property (nonatomic, retain) UITableView * tableView_DL;

@property (atomic, retain) NSMutableDictionary *switchDict;
@property (nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic) NSTimer *updateTimer;
 
@property (nonatomic, retain) CC3xSwitch *selectedSwitch;
@property (nonatomic, retain) CustomCell *selectedCell;
@property (nonatomic, assign) BOOL isAllowded;
@property (nonatomic, assign) unsigned short crc16CheckSum;

@end
