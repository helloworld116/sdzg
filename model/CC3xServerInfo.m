//
//  CC3xServerInfo.m
//  CC3x
//
//  Created by hq on 4/27/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import "CC3xServerInfo.h"

@implementation CC3xServerInfo

- (id) initWithIp:(NSString *)aIp
             port:(unsigned short)aPort
       deviceName:(NSString *)aDeviceName
{
   if ((self = [super init])) {
      self.ip = aIp;
      self.port = aPort;
      self.deviceName = aDeviceName;
   }

   return self;
}


@end
