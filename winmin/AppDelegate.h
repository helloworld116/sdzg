//
//  AppDelegate.h
//  winmin
//
//  Created by sdzg on 14-5-12.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject<UIApplicationDelegate>
{

    
}
@property (nonatomic ,strong) UIWindow * window;
@property (nonatomic ,strong) UIStoryboard *mainStoryboard;
@property (nonatomic ,retain) UINavigationController * navigationController;



@end