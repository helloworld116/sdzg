//
//  SendResponseHandler.h
//  winmin
//
//  Created by sdzg on 14-7-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendResponseHandler : NSObject
@property(atomic, strong) NSData *responseDataA;
@property(atomic, strong) NSData *responseDataC;
@property(atomic, strong) NSData *responseDataE;
@property(atomic, strong) NSMutableDictionary *responseDictE;  //{@"mac":"data"}
@property(atomic, strong) NSData *responseDataCOrE;
@property(atomic, strong) NSData *responseData12Or14;
@property(atomic, strong) NSData *responseData18Or1A;
@property(atomic, strong) NSData *responseData1EOr20;
@property(atomic, strong) NSData *responseData26Or28;
@property(atomic, strong) NSData *responseData3AOr3C;
@property(atomic, strong) NSData *responseData40Or42;
@property(atomic, strong) NSData *responseData48Or4A;
@property(atomic, strong) NSData *responseData4EOr50;
@property(atomic, strong) NSData *responseData54Or56;
@property(atomic, strong) NSData *responseData5A;
+ (instancetype)shareInstance;

/**
 *  指定时间后检查响应数据是否已经被填充
 *
 *  @param tag 请求编号
 */
- (void)checkResponseDataAfterSettingIntervalWithTag:(long)tag;
@end
