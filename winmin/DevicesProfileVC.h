//
//  DevicesProfileVC.h
//  winmin
//
//  Created by sdzg on 14-7-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CC3xSwitch.h"

@interface DevicesProfileVC : UIViewController
@property(strong, nonatomic) CC3xSwitch *aSwitch;
@property(nonatomic, assign) id<PassValueDelegate> passValueDelegate;
@end
