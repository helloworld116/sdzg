//
//  UdpSocketUtil.h
//  winmin
//
//  Created by 文正光 on 14-7-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ResponseDelegate<NSObject>
@optional
/**
 *  手机添加设备
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgIdA:(CC3xMessage *)msg;
/**
 *  手机查询开关状态
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgIdCOrE:(CC3xMessage *)msg;
/**
 *  手机控制开关“开或关”
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId12Or14:(CC3xMessage *)msg;
/**
 *  手机获取设备定时列表
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId18Or1A:(CC3xMessage *)msg;
/**
 *  手机设置设备定时列表
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId1EOr20:(CC3xMessage *)msg;
/**
 *  手机获取设备控制权限
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId26Or28:(CC3xMessage *)msg;
/**
 *  开关定位
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId3AOr3C:(CC3xMessage *)msg;
/**
 *  设置开关名字
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId40Or42:(CC3xMessage *)msg;
/**
 *  设备加锁
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId48Or4A:(CC3xMessage *)msg;
/**
 *  设置设备延时任务
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId4EOr50:(CC3xMessage *)msg;
/**
 *  查询设备延时任务
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId54Or56:(CC3xMessage *)msg;
/**
 *  手机开机上报基本信息
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId5A:(CC3xMessage *)msg;
@end

@interface UdpSocketUtil : NSObject
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, assign) id<ResponseDelegate> delegate;
+ (instancetype)shareInstance;
@end
