//
//  UdpSocketUtil.h
//  winmin
//
//  Created by 文正光 on 14-7-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  请求响应后的处理
 */
@protocol UDPDelegate<NSObject>
#pragma mark 请求响应后的处理
@optional
/**
 *  手机添加设备响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgIdA:(CC3xMessage *)msg;
/**
 *  手机内网查询开关状态响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgIdC:(CC3xMessage *)msg;
/**
 *  手机外网查询开关状态响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgIdE:(CC3xMessage *)msg;
/**
 *  手机查询开关状态响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgIdCOrE:(CC3xMessage *)msg;
/**
 *  手机控制开关“开或关”响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId12Or14:(CC3xMessage *)msg;
/**
 *  手机获取设备定时列表响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId18Or1A:(CC3xMessage *)msg;
/**
 *  手机设置设备定时列表响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId1EOr20:(CC3xMessage *)msg;
/**
 *  手机获取设备控制权限响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId26Or28:(CC3xMessage *)msg;
/**
 *  开关定位响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId3AOr3C:(CC3xMessage *)msg;
/**
 *  设置开关名字响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId40Or42:(CC3xMessage *)msg;
/**
 *  设备加锁响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId48Or4A:(CC3xMessage *)msg;
/**
 *  设置设备延时任务响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId4EOr50:(CC3xMessage *)msg;
/**
 *  查询设备延时任务响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId54Or56:(CC3xMessage *)msg;
/**
 *  手机开机上报基本信息响应后的处理
 *
 *  @param msg 响应报文经过包装后的对象
 */
- (void)responseMsgId5A:(CC3xMessage *)msg;

#pragma mark 请求没响应后的处理
/**
 *  手机添加设备请求无响应处理
 */
- (void)noResponseMsgIdA;
/**
 *  手机查询开关状态请求无响应处理
 */
- (void)noResponseMsgIdCOrE;
/**
 *  手机内网查询开关状态请求无响应处理
 */
- (void)noResponseMsgIdC;
/**
 *  手机外网查询开关状态请求无响应处理
 */
- (void)noResponseMsgIdE;
/**
 *  手机外网查询开关状态请求无响应处理
 *
 *  @param mac 开关的mac值
 */
- (void)noResponseMsgIdE:(NSString *)mac;
/**
 *  手机控制开关“开或关”请求无响应处理
 */
- (void)noResponseMsgId12Or14;
/**
 *  手机获取设备定时列表请求无响应处理
 */
- (void)noResponseMsgId18Or1A;
/**
 *  手机设置设备定时列表请求无响应处理
 */
- (void)noResponseMsgId1EOr20;
/**
 *  手机获取设备控制权限请求无响应处理
 */
- (void)noResponseMsgId26Or28;
/**
 *  开关定位请求无响应处理
 */
- (void)noResponseMsgId3AOr3C;
/**
 *  设置开关名字请求无响应处理
 */
- (void)noResponseMsgId40Or42;
/**
 *  设备加锁请求无响应处理
 */
- (void)noResponseMsgId48Or4A;
/**
 *  设置设备延时任务请求无响应处理
 */
- (void)noResponseMsgId4EOr50;
/**
 *  查询设备延时任务请求无响应处理
 */
- (void)noResponseMsgId54Or56;
/**
 *  手机开机上报基本信息请求无响应处理
 */
- (void)noResponseMsgId5A;

#pragma mark 请求没有发送的处理
/**
 *  UDP请求发送失败后的处理
 */
- (void)noSendMsgId5;
/**
 *  手机添加设备UDP请求发送失败后的处理
 */
- (void)noSendMsgId9;
/**
 *  手机内网查询开关状态UDP请求发送失败后的处理
 */
- (void)noSendMsgIdB;
/**
 *  手机外网查询开关状态UDP请求发送失败后的处理
 */
- (void)noSendMsgIdD;
/**
 *  手机查询开关状态UDP请求发送失败后的处理
 */
- (void)noSendMsgIdBOrD;
/**
 *  手机查询开关状态UDP请求发送失败后的处理
 *
 *  @param mac 开关的mac值
 */
- (void)noSendMsgIdBOrD:(NSString *)mac;
/**
 *  手机控制开关“开或关”UDP请求发送失败后的处理
 */
- (void)noSendMsgId11Or13;
/**
 *  手机获取设备定时列表UDP请求发送失败后的处理
 */
- (void)noSendMsgId17Or19;
/**
 *  手机设置设备定时列表UDP请求发送失败后的处理
 */
- (void)noSendMsgId1DOr1F;
/**
 *  手机获取设备控制权限UDP请求发送失败后的处理
 */
- (void)noSendMsgId25Or27;
/**
 *  UDP请求发送失败后的处理
 */
- (void)noSendMsgId33Or35;
/**
 *  开关定位UDP请求发送失败后的处理
 */
- (void)noSendMsgId39Or3B;
/**
 *  设置开关名字UDP请求发送失败后的处理
 */
- (void)noSendMsgId3FOr41;
/**
 *  设备加锁UDP请求发送失败后的处理
 */
- (void)noSendMsgId47Or49;
/**
 *  设置设备延时任务UDP请求发送失败后的处理
 */
- (void)noSendMsgId4DOr4F;
/**
 *  查询设备延时任务UDP请求发送失败后的处理
 */
- (void)noSendMsgId53Or55;
/**
 *  手机开机上报基本信息UDP请求发送失败后的处理
 */
- (void)noSendMsgId59;
@end

@interface UdpSocketUtil : NSObject
@property(nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property(nonatomic, assign) id<UDPDelegate> delegate;
+ (instancetype)shareInstance;
@end
