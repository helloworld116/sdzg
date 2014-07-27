//
//  NetUtil.m
//  winmin
//
//  Created by 文正光 on 14-7-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "NetUtil.h"
#import "Reachability.h"

#define kCheckNetworkWebsite @"www.baidu.com"

@implementation NetUtil
+ (instancetype)sharedInstance {
  static NetUtil *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ instance = [[NetUtil alloc] init]; });
  return instance;
}

- (void)addNetWorkChangeNotification {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reachabilityChanged:)
             name:kReachabilityChangedNotification
           object:nil];
  Reachability *hostReach =
      [Reachability reachabilityWithHostName:kCheckNetworkWebsite];
  [hostReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)note {
  Reachability *curReach = [note object];
  NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
  NetworkStatus status = [curReach currentReachabilityStatus];
  switch (status) {
    case NotReachable:
      kSharedAppliction.networkStatus = NotReachable;
      break;
    case ReachableViaWiFi:
      kSharedAppliction.networkStatus = ReachableViaWiFi;
      break;
    case ReachableViaWWAN:
      kSharedAppliction.networkStatus = ReachableViaWWAN;
      break;
    default:
      kSharedAppliction.networkStatus = NotReachable;
      break;
  }
}

@end