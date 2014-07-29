//
//  AppDelegate.m
//  winmin
//
//  Created by sdzg on 14-5-12.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AppDelegate.h"

#import "SockerAndFileController.h"
#import "MoreSettingsViewController.h"
//判断设备是否4寸屏幕

#define iPhone5                                                      \
  ([UIScreen instancesRespondToSelector:@selector(currentMode)]      \
       ? CGSizeEqualToSize(CGSizeMake(640, 1136),                    \
                           [[UIScreen mainScreen] currentMode].size) \
       : NO)

//判断设备是否iOS7

#define IOS7                                                    \
  ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != \
   NSOrderedAscending)
@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  SockerAndFileController *device_c = [[SockerAndFileController alloc] init];
  UINavigationController *device_nc =
      [[UINavigationController alloc] initWithRootViewController:device_c];

  device_c = nil;
  device_nc.tabBarItem.image = [UIImage imageNamed:@"tabbar_smartplug_sel"];
  device_nc.tabBarItem.title = @"设备";

  MoreSettingsViewController *more_c =
      [[MoreSettingsViewController alloc] init];
  UINavigationController *more_nc =
      [[UINavigationController alloc] initWithRootViewController:more_c];

  more_c = nil;
  more_nc.tabBarItem.image = [UIImage imageNamed:@"tabbar_more_sel"];
  more_nc.tabBarItem.title = @"更多";

  NSArray *array = [[NSArray alloc] initWithObjects:device_nc, more_nc, nil];

  more_nc = nil;

  device_nc = nil;
  UITabBarController *tabBar = [[UITabBarController alloc] init];
  tabBar.viewControllers = array;

  array = nil;
  //  [tabBar.tabBar setBackgroundImage:[UIImage
  //  imageNamed:@"tabbar_background"]];

  //  //导航栏
  //  float systemVersion = [[[UIDevice currentDevice] systemVersion]
  //  floatValue];
  //  UIImage *backgroundImage =
  //      [UIImage imageNamed:@"navigation_background"]; //获取图片
  //
  //  self.navigationController.navigationBar.translucent = NO;
  //  self.navigationController.extendedLayoutIncludesOpaqueBars = YES;
  //
  //  if (systemVersion >= 5.0) {
  //    CGSize titleSize = self.navigationController.navigationBar.bounds
  //                           .size; //获取Navigation Bar的位置和大小
  //    backgroundImage =
  //        [self scaleToSize:backgroundImage
  //                     size:titleSize]; //设置图片的大小与Navigation Bar相同
  //    [self.navigationController.navigationBar
  //        setBackgroundImage:backgroundImage
  //             forBarMetrics:UIBarMetricsDefault]; //设置背景
  //    NSLog(@"systemVersion=%f", systemVersion);
  //  } else {
  //    [self.navigationController.navigationBar
  //        insertSubview:[[UIImageView alloc] initWithImage:backgroundImage]
  //              atIndex:1];
  //    NSLog(@"systemVersion=%f", systemVersion);
  //  }
  //  backgroundImage = nil;
  //    //设置背景样式可用通过设置tintColor来设置
  //    self.navigationController.navigationBar.tintColor = [UIColor
  //    colorWithRed:50/255.0 green:138/255.0 blue:233/255.0
  //    alpha:1.0];//改变navigation的背景颜色
  //状态栏显示

  //设置导航栏背景图片
  //  [[UINavigationBar appearance]
  //      setBackgroundImage:[UIImage imageNamed:@"navigation_background.png"]
  //           forBarMetrics:UIBarMetricsDefault];

  self.window.rootViewController = tabBar;

  tabBar = nil;
  //    [self.window addSubview:tabBar.view];
  [self.window makeKeyAndVisible];
  UIStoryboard *storyboard =
      [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  self.mainStoryboard = storyboard;
  kSharedAppliction.networkStatus = ReachableViaWiFi;
  return YES;
}

//调整图片大小
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return scaledImage;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
  [[UdpSocketUtil shareInstance].udpSocket close];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

@end
