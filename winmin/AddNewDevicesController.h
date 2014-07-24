//
//  AddNewDevicesController.h
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "FirstTimeConfig.h"
#include <time.h>
#import "GCDAsyncUdpSocket.h"
#import "CC3xHeader.h"
#import "CC3xUtility.h"
#include "MBProgressHUD.h"

@class FirstTimeConfig;
@class GCDAsyncReadPacket;


@interface AddNewDevicesViewController : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate,GCDAsyncUdpSocketDelegate>
{
    
    UITextField * textfield_wifi;
    UITextField * textfield_password;
    NSString * string_wifi;
    NSString * string_password;
    BOOL showPassword;
    UIButton * button_startconfig;
    UILabel * label_showpassword;
    UISwitch * switch_showpassword;
    FirstTimeConfig * config;
    Reachability * wifiReachability;
    UIImageView * bg;
    UIButton *button_cancel;
    
}
@property (retain, nonatomic) NSString *wifiAddressStr;
@property (retain, nonatomic) NSString *passwordStr;
@property (nonatomic,retain)UIView * View_config;
@property (nonatomic,retain)GCDAsyncUdpSocket * udpSocket;
@property (nonatomic,assign)BOOL showPasswordStr;
@property (nonatomic,retain)UIView * networkConfigView;
@property (nonatomic,assign)BOOL isRunning;
@property (nonatomic,retain)MBProgressHUD * hud;
@property (retain, nonatomic) NSMutableDictionary *switchesDict;

- (void)touchToAdd:(UIButton *)sender;
- (void)startConfig;
- (void)dismissConfigView;
- (void)enableUIAccess:(BOOL)isEnable;
- (void)wifiStatusChanged:(NSNotification *)notification;

- (void)networkNotReachableAlert;
- (void)stopAction;
- (void)switched:(id)sender;

- (void)back;
@end
