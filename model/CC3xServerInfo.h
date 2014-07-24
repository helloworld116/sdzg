//
//  CC3xServerInfo.h
//  CC3x
//
//  Created by hq on 4/27/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CC3xServerInfo : NSObject


@property (nonatomic, retain) NSString *ip;
@property (nonatomic, assign) unsigned short port;
@property (nonatomic, retain) NSString *deviceName;

- (id) initWithIp:(NSString *)aIp
             port:(unsigned short)aPort
       deviceName:(NSString *)aDeviceName;

@end
