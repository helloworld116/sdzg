//
//  CC3xMessage.m
//  CC3x
//
//  Created by hq on 3/24/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import "CC3xMessage.h"
#import "CC3xUtility.h"
#import "CC3xTimerTask.h"
#import "CRC.h"

#define B2D(bytes) ([NSData dataWithBytes:&bytes length:sizeof(bytes)]);

#define int2charArray(array, value)    \
  do {                                 \
    array[0] = ((value >> 24) & 0xff); \
    array[1] = ((value >> 16) & 0xff); \
    array[2] = ((value >> 8) & 0xff);  \
    array[3] = ((value >> 0) & 0xff);  \
  } while (0);

#define charArray2int(array, value) \
  do {                              \
    value += array[0] << 24;        \
    value += array[1] << 16;        \
    value += array[2] << 8;         \
    value += array[3] << 0;         \
  } while (0);

@implementation CC3xMessageUtil
;

/* HEADER, P2D_SCAN_DEV_REQ 0x9 == P2D_STATE_INQUIRY 0xb
 * P2D_GET_TIMER_REQ 0x17 == P2D_GET_PROPERTY_REQ 0x25
 */
#pragma pack(1)

typedef struct {
  unsigned short msgLength;
  unsigned char msgId;
  unsigned char msgDir;
} msgHeader;

// D2P_CONFIG_RESULT 0x02

typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  unsigned short crc;
} d2pMsg02;

// P2D_SERVER_INFO 0x05
typedef struct {
  msgHeader header;
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned short crc;
} p2dMsg05;

// P2D_SERVER_RESP 0x07
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} p2dMsg06;

// P2D_SCAN_DEV_REQ 0x09
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg09;

// D2P_SCAN_DEV_RESP 0x0a
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned char FWVersion;
  char isLocked;
  unsigned short crc;
} d2pMsg0A;

// P2D_SCAN_DEV_REQ 0x09
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg0B;

// D2P_STATE_RESP 0x0c
typedef struct {
  msgHeader header;
  char state;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned char deviceLockState;
  unsigned char FWVersion;
  unsigned short pm;
  unsigned char temperatureHigh;
  unsigned char temperatureLow;
  unsigned char humidity;  //湿度
  unsigned short power;
  unsigned char airTag;  //空气质量代号
  unsigned short crc;
} d2pMsg0C;

// P2S_STATE_INQUIRY 0xd
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg0D;

// D2P_STATE_RESP 0x0E

typedef struct {
  msgHeader header;
  char state;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned char deviceLockState;
  unsigned char FWVersion;
  unsigned short crc;
} d2pMsg0E;

// P2D_CONTROL_REQ 0x11
typedef struct {
  msgHeader header;
  unsigned char on;
  unsigned short crc;
} p2dMsg11;

// D2P_CONTROL_RESP 0x12
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg12;

// P2S_CONTROL_REQ 0x13
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char on;
  unsigned short crc;
} p2sMsg13;

// S2P_CONTROL_RESP 0x14
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg14;

// P2D_GET_TIMER_REQ 0x17
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg17;

// Timer related structure
typedef struct {
  char week;
  unsigned char startTime[4];
  unsigned char endTime[4];
  char timeDetail;
} timerTask;
// D2P_GET_TIMER_RESP 0x18
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char currentTime[4];
  unsigned char timerNumber;
  timerTask timerList[8];
  unsigned short crc;
} d2pMsg18;

// P2S_CONTROL_REQ 0x19
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg19;

// S2P_GET_TIMER_RESP 0x1A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char currentTime[4];
  unsigned char timerNumber;
  timerTask *timerList;
  unsigned short crc;
} s2pMsg1A;

// P2D_SET_TIMER_REQ 0x1D
typedef struct {
  msgHeader header;
  unsigned char currentTimer[4];
  unsigned char timerNumber;
  timerTask *timerList;
  unsigned short crc;
} p2dMsg1D;

// D2P_SET_TIMER_RESP 0x1E
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg1E;

// P2S_SET_TIMER_REQ 0x1F
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char currentTime[4];
  unsigned char timerNumber;
  timerTask *timerList;
  unsigned short crc;
} p2sMsg1F;

// S2P_CONTROL_RESP 0x20
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg20;

// P2D_GET_PROPERTY_REQ 0X25
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg25;
// D2P_GET_PROPERTY_RESP 0X26
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg26;
// P2S_GET_PROPERTY_REQ 0X27
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg27;
// S2P_GET_PROPERTY_RESP 0X28
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg28;

// P2D_GET_POWER_INFO_REQ 	0X33
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg33;

// D2P_GET_POWER_INFO_RESP	0X34
typedef struct {
  msgHeader header;
  unsigned short crc;
} d2pMsg34;

// P2S_GET_POWER_INFO_REQ	 0X35
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg35;

// S2P_GET_POWER_INFO_resp	 0X36
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  char power;
  unsigned short crc;
} s2pMsg36;

// P2D_LOCATE_REQ 0x39

typedef struct {
  msgHeader header;
  unsigned char on;
  unsigned short crc;
} p2dMsg39;
// D2P_LOCATE_RESP 0x3A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg3A;

//  P2S_LOCATE_REQ 0x3B

typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char on;
  unsigned short crc;
} p2sMsg3B;

// S2P_LOCATE_RESP 0x3C
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg3C;

// P2D_SET_NAME_REQ 0x3F
typedef struct {
  msgHeader header;
  char name[32];
  unsigned short crc;
} p2dMsg3F;

// D2P_SET_NAME_RESP 0x40
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg40;

// P2S_SET_NAME_REQ 0x41
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char name[32];
  unsigned short crc;
} p2sMsg41;

// S2P_SET_NAME_RESP 0x42
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg42;

// P2D_DEV_LOCK_REQ 0x47
typedef struct {
  msgHeader header;
  char lock;
  unsigned short crc;
} p2dMsg47;

// D2P_DEV_LOCK_RESP 0x48
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg48;

// P2S_DEV_LOCK_REQ 0x49
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} p2sMsg49;

// S2P_DEV_LOCK_RESP 0x4A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg4A;

// P2D_SET_DELAY_REQ 0x4D
typedef struct {
  msgHeader header;
  unsigned short delay;
  char on;
  unsigned short crc;
} p2dMsg4D;

//
// D2P_SET_DELAY_RESP 0x4E
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg4E;

// P2S_SET_DELAY_REQ 0x4F
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short delay;
  char on;
  unsigned short crc;
} p2sMsg4F;
// S2P_SET_DELAY_RESP 0x50
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg50;

// P2D_GET_DELAY_REQ 0x53
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg53;

// D2P_GET_DELAY_RESP 0x54
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short delay;
  unsigned char on;
  unsigned short crc;
} d2pMsg54;

// P2S_GET_DELAY_REQ 0x55
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg55;

// P2S_PHONE_INIT_REQ 0x59
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char phoneType[20];
  char systemName[20];
  char appVersion[10];
  unsigned short crc;
} p2sMsg59;

// S2P_PHONE_INIT_RESP 0x5A
typedef struct {
  msgHeader header;
  char update;
  char updateUrl[100];
  unsigned short crc;
} s2pMsg5A;

#pragma pack()
#pragma mark - method implementation 将信息转换为Data ，用于发送

//	P2D_SERVER_INFO  0X05
+ (NSData *)getP2dMsg05 {
  p2dMsg05 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x5;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));

  char *ipadd = "";
  struct hostent *h = gethostbyname([SERVER_IP UTF8String]);
  if (h != NULL) {
    ipadd = inet_ntoa(*((struct in_addr *)h->h_addr_list[0]));
  }
  //    NSLog(@"serverIp=%s\n",ipadd);

  Byte *bytes = [CC3xMessageUtil
      ip2HexBytes:[NSString stringWithCString:ipadd
                                     encoding:NSUTF8StringEncoding]];

  memcpy(msg.ip, bytes, sizeof(msg.ip));
  free(bytes);
  const char *defaultName = [DEFAULT_NAME UTF8String];
  msg.port = SERVER_PORT;
  memset(msg.deviceName, 0, 32);
  memcpy(msg.deviceName, defaultName, strlen(defaultName));

  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);

  NSData *ndMsg = B2D(msg);
  //    NSLog(@"发送0x05:%@",[self hexString:ndMsg]);

  return ndMsg;
}
// P2D_SCAN_DEV_REQ	0X09
+ (NSData *)getP2dMsg09 {
  p2dMsg09 msg;
  memset(&msg, 0, sizeof(msgHeader));
  msg.header.msgId = 0x9;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_STATE_INQUIRY	0X0B
+ (NSData *)getP2dMsg0B {
  p2dMsg0B msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0xB;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  // NSLog(@"msg11 = %d",msg.header.msgLength);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_STATE_INQUIRY	0X0D
+ (NSData *)getP2SMsg0D:(NSString *)mac {
  p2sMsg0D msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0xD;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = ntohs(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));

  free(macBytes);

  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_CONTROL_REQ	0X11
+ (NSData *)getP2dMsg11:(BOOL)on {
  p2dMsg11 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x11;
  msg.header.msgDir = 0xAD;
  msg.on = on;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_CONTROL_REQ	0X13
+ (NSData *)getP2sMsg13:(NSString *)mac aSwitch:(BOOL)on {
  p2sMsg13 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x13;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.on = on;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_GET_TIMER_REQ	0X17
+ (NSData *)getP2dMsg17 {
  p2dMsg17 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x17;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_TIMER_REQ	0X19
+ (NSData *)getP2SMsg19:(NSString *)mac {
  p2sMsg19 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.header.msgId = 0x19;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);

  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SET_TIMER_REQ	0X1D
+ (NSData *)getP2dMsg1D:(NSUInteger)currentTime
               timerNum:(NSUInteger)num
              timerList:(NSArray *)timerList {
  NSUInteger bufLen = 11 + num * 10;
  //    Byte msgBuf[bufLen];

  Byte header[9];
  header[0] = (Byte)(bufLen >> 8);
  header[1] = (Byte)bufLen;
  header[2] = (Byte)0x1D;
  header[3] = (Byte)0xAD;
  //    memcpy(header + 4, &currentTime, 4);
  header[4] = (Byte)(currentTime >> 24);
  header[5] = (Byte)(currentTime >> 16);
  header[6] = (Byte)(currentTime >> 8);
  header[7] = (Byte)(currentTime);
  header[8] = (Byte)num;

  NSMutableData *msg = [[NSMutableData alloc] initWithCapacity:bufLen];
  [msg appendBytes:header length:9];
  for (int i = 0; i < num; i++) {
    CC3xTimerTask *task = timerList[i];
    Byte item[10];
    item[0] = (Byte)task.week;
    item[1] = (Byte)(task.startTime >> 24);
    item[2] = (Byte)(task.startTime >> 16);
    item[3] = (Byte)(task.startTime >> 8);
    item[4] = (Byte)task.startTime;
    item[5] = (Byte)(task.endTime >> 24);
    item[6] = (Byte)(task.endTime >> 16);
    item[7] = (Byte)(task.endTime >> 8);
    item[8] = (Byte)task.endTime;
    item[9] = (Byte)task.timeDetail;
    [msg appendBytes:item length:10];
  }
  Byte *byteData = (Byte *)[msg bytes];
  unsigned short crc = CRC16((unsigned char *)byteData, bufLen - 2);
  Byte cc[2];
  cc[1] = (Byte)(crc >> 8);
  cc[0] = (Byte)crc;
  [msg appendBytes:cc length:2];
  return msg;
}
// P2S_SET_TIMER_REQ	0X1F
+ (NSData *)getP2SMsg1F:(NSUInteger)currentTime
               timerNum:(NSUInteger)num
              timerList:(NSArray *)timerList
                    mac:(NSString *)aMac {
  NSUInteger bufLen = 17 + num * 10;
  //    Byte msgBuf[bufLen];

  Byte header[15];
  header[0] = (Byte)(bufLen >> 8);
  header[1] = (Byte)bufLen;
  header[2] = (Byte)0x1F;
  header[3] = (Byte)0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:aMac];
  memcpy(header + 4, macBytes, 6);
  free(macBytes);
  //    memcpy(header + 10, &currentTime, 4);
  header[10] = (Byte)(currentTime >> 24);
  header[11] = (Byte)(currentTime >> 16);
  header[12] = (Byte)(currentTime >> 8);
  header[13] = (Byte)(currentTime);
  header[14] = (Byte)num;

  NSMutableData *msg = [[NSMutableData alloc] initWithCapacity:bufLen];
  [msg appendBytes:header length:15];
  for (int i = 0; i < num; i++) {
    CC3xTimerTask *task = timerList[i];
    Byte item[10];
    item[0] = (Byte)task.week;
    item[1] = (Byte)(task.startTime >> 24);
    item[2] = (Byte)(task.startTime >> 16);
    item[3] = (Byte)(task.startTime >> 8);
    item[4] = (Byte)task.startTime;
    item[5] = (Byte)(task.endTime >> 24);
    item[6] = (Byte)(task.endTime >> 16);
    item[7] = (Byte)(task.endTime >> 8);
    item[8] = (Byte)task.endTime;
    item[9] = (Byte)task.timeDetail;
    [msg appendBytes:item length:10];
  }
  Byte *byteData = (Byte *)[msg bytes];
  unsigned short crc = CRC16((unsigned char *)byteData, bufLen - 2);
  Byte cc[2];
  cc[1] = (Byte)(crc >> 8);
  cc[0] = (Byte)crc;
  [msg appendBytes:cc length:2];
  return msg;
}

// P2D_GET_PROPERTY_REQ	0X25
+ (NSData *)getP2dMsg25 {
  p2dMsg25 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x25;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_PROPERTY_REQ	0X27
+ (NSData *)getP2SMsg27:(NSString *)mac {
  p2sMsg27 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x27;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_GET_POWER_INFO_REQ 	0X33
+ (NSData *)getP2DMsg33 {
  p2dMsg33 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x33;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_POWER_INFO_REQ	 0X35
+ (NSData *)getP2SMsg35:(NSString *)mac {
  p2sMsg35 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x35;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_LOCATE_REQ 0x39
+ (NSData *)getP2dMsg39:(BOOL)on {
  p2dMsg39 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x39;
  msg.header.msgDir = 0xAD;
  msg.on = on;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_LOCATE_REQ 0x3b
+ (NSData *)getP2SMsg3B:(NSString *)mac on:(BOOL)on {
  p2sMsg3B msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x3b;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  msg.on = on;
  free(macBytes);
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SET_NAME_REQ 0x3f
+ (NSData *)getP2dMsg3F:(NSString *)name {
  p2dMsg3F msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x3f;
  msg.header.msgDir = 0xAD;
  NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];

  memcpy(&msg.name, [nameData bytes], [nameData length]);

  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_SET_NAME_REQ 0x41
+ (NSData *)getP2sMsg41:(NSString *)mac name:(NSString *)name {
  p2sMsg41 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x41;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));

  NSData *nameData =
      [name dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  memcpy(&msg.name, [nameData bytes], sizeof(msg.name));
  free(macBytes);
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_DEV_LOCK_REQ	 0X47
+ (NSData *)getP2dMsg47:(BOOL)isLock {
  p2dMsg47 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x47;
  msg.header.msgDir = 0xAD;
  msg.lock = isLock;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_DEV_LOCK_REQ 	0X49
+ (NSData *)getP2sMsg49:(NSString *)mac lock:(BOOL)isLock {
  p2sMsg49 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x49;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.state = isLock;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SET_DELAY_REQ 0x4D
+ (NSData *)getP2dMsg4D:(NSInteger)delay on:(BOOL)on {
  p2dMsg4D msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x4D;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.delay = ntohs(delay);
  msg.on = on;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);

  return B2D(msg);
}

// P2S_SET_DELAY_REQ 0x4F
+ (NSData *)getP2SMsg4F:(NSString *)mac delay:(NSInteger)delay on:(BOOL)on {
  p2sMsg4F msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x4F;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = ntohs(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.delay = ntohs(delay);
  msg.on = on;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);

  return B2D(msg);
}

// P2D_GET_DELAY_REQ 0x53
+ (NSData *)getP2dMsg53 {
  p2dMsg53 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x53;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = ntohs(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_DELAY_REQ 0x55
+ (NSData *)getP2SMsg55:(NSString *)mac {
  p2sMsg55 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x55;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = ntohs(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_PHONE_INIT_REQ 0x59
+ (NSData *)getP2SMsg59:(NSString *)mac {
  p2sMsg59 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x59;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = ntohs(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  const char *name = [[[UIDevice currentDevice] name] UTF8String];
  const char *systemName =
      [[[UIDevice currentDevice] systemVersion] UTF8String];
  if (sizeof(name) > 20) {
    memcpy(msg.phoneType, name, 20);
  } else {
    strcpy(msg.phoneType, name);
  }
  if (sizeof(systemName) > 20) {
    memcpy(msg.systemName, systemName, 20);
  } else {
    strcpy(msg.systemName, systemName);
  }
  strcpy(msg.appVersion, "2.0");
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

#pragma mark - response message 解析收到的data数据，转为其他数据类型

+ (CC3xMessage *)parseD2P02:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg02 msg;
  [aData getBytes:&msg length:sizeof(d2pMsg02)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];

  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = msg.port;
  message.crc = msg.crc;

  return message;
}

+ (CC3xMessage *)parseD2P0A:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg0A msg;
  [aData getBytes:&msg length:sizeof(msg)];

  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];

  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = msg.port;

  message.deviceName = [[NSString alloc] initWithBytes:msg.deviceName
                                                length:sizeof(msg.deviceName)
                                              encoding:NSUTF8StringEncoding];
  message.version = msg.FWVersion;
  message.isLocked = msg.isLocked;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseD2P0C:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg0C msg;
  [aData getBytes:&msg length:sizeof(msg)];

  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];

  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = msg.port;

  NSString *deviceName = [[NSString alloc] initWithBytes:msg.deviceName
                                                  length:sizeof(msg.deviceName)
                                                encoding:NSUTF8StringEncoding];

  deviceName =
      [deviceName stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  message.deviceName = deviceName;
  message.version = msg.FWVersion;
  message.isLocked = msg.deviceLockState & (1 << 0);
  message.isOn = msg.deviceLockState & (1 << 1);
  message.state = msg.state;

  //有电量、空气质量数据才处理
  if ([aData length] == 61) {
    //赋值过程中，高低位互换了，后续查明原因
    message.pmTwoPointFive = (msg.pm >> 8 | msg.pm << 8);
    message.temperature =
        ((msg.temperatureHigh & 0x7f) * 256 + msg.temperatureLow) / 10.0f;
    if (msg.temperatureHigh & (1 << 7)) {
      message.temperature = -message.temperature;
    }
    message.humidity = msg.humidity;
    unsigned short power = (msg.power >> 8 | msg.power << 8);
    message.power = power == 0 ? 0.f : 53035.5f / power;
    message.airTag = msg.airTag;
  }
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseD2P12:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg12 msg;
  [aData getBytes:&msg length:sizeof(msg)];

  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02x-%02x-%02x-%02x-%02x-%02x",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.state = msg.state;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseS2P14:(NSData *)aData {
  CC3xMessage *message = [CC3xMessageUtil parseD2P12:aData];

  return message;
}

+ (CC3xMessage *)parseD2P18:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg18 aMsg;
  [aData getBytes:&aMsg length:sizeof(aMsg)];
  NSUInteger num = aMsg.timerNumber & 0xff;
  if (num == 0xff || num > 8) {
    return nil;
  }
  message = [[CC3xMessage alloc] init];
  NSUInteger size = sizeof(d2pMsg18) + sizeof(timerTask) * num;
  d2pMsg18 *msg = (d2pMsg18 *)malloc(size);
  [aData getBytes:msg length:size];
  message.currentTime = *(int *)msg->currentTime;
  message.msgId = msg->header.msgId;
  message.msgDir = msg->header.msgDir;
  message.timerTaskNumber = num;
  message.timerTaskList =
      [[NSMutableArray alloc] initWithCapacity:message.timerTaskNumber];
  for (int i = 0; i < message.timerTaskNumber; i++) {
    timerTask t = msg->timerList[i];
    CC3xTimerTask *task = [[CC3xTimerTask alloc] init];
    task.week = t.week;
    charArray2int(t.startTime, task.startTime);
    charArray2int(t.endTime, task.endTime);
    task.timeDetail = t.timeDetail;
    [message.timerTaskList addObject:task];
    ;
  }

  message.crc = msg->crc;
  free(msg);
  return message;
}

+ (CC3xMessage *)parseD2P34:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg34 *msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg->header.msgId;
  message.msgDir = msg->header.msgDir;
  message.msgLength = msg->header.msgLength;
  return message;
}

+ (CC3xMessage *)parseS2P36:(NSData *)aData {
  CC3xMessage *message = nil;
  s2pMsg36 *msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg->header.msgId;
  message.msgDir = msg->header.msgDir;
  message.msgLength = msg->header.msgLength;
  message.mac =
      [NSString stringWithFormat:@"%02x-%02x-%02x-%02x-%02x-%02x", msg->mac[0],
                                 msg->mac[1], msg->mac[2], msg->mac[3],
                                 msg->mac[4], msg->mac[5]];
  message.state = msg->state;
  message.power = msg->power;
  return message;
}

+ (CC3xMessage *)parseD2P54:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg54 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02x-%02x-%02x-%02x-%02x-%02x",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  //高低字节互换了
  message.delay =
      msg.delay / 256;  //这个地方不知道什么原因导致左移两位，放大了256倍
  message.isOn = msg.on;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseS2P6A:(NSData *)aData {
  CC3xMessage *message = nil;
  s2pMsg5A *msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg->header.msgId;
  message.msgDir = msg->header.msgDir;
  message.msgLength = msg->header.msgLength;
  message.update = msg->update;
  message.updateUrl =
      [NSString stringWithCString:msg->updateUrl encoding:NSUTF8StringEncoding];
  return message;
}

+ (CC3xMessage *)parseMessage:(NSData *)data {
  CC3xMessage *result = nil;
  msgHeader header;
  [data getBytes:&header length:sizeof(msgHeader)];

  switch (header.msgId) {
    case 0x2:
      result = [CC3xMessageUtil parseD2P02:data];
      break;
    case 0xc:
    case 0xe:
      result = [CC3xMessageUtil parseD2P0C:data];
      break;
    case 0xa:
      result = [CC3xMessageUtil parseD2P0A:data];
      break;
    case 0x18:
    case 0x1a:
      result = [CC3xMessageUtil parseD2P18:data];
      break;
    case 0x06:
    case 0x12:
    case 0x14:
    case 0x1e:
    case 0x20:
    case 0x26:
    case 0x28:
    case 0x3a:
    case 0x3c:
    case 0x40:
    case 0x42:
    case 0x48:
    case 0x49:
    case 0x4a:
    case 0x4e:
    case 0x50:
      result = [CC3xMessageUtil parseD2P12:data];
      break;
    case 0x54:
    case 0x56:
      result = [CC3xMessageUtil parseD2P54:data];
      break;
    case 0x6A:
      result = [CC3xMessageUtil parseS2P6A:data];
      break;
    case 0x34:
      result = [CC3xMessageUtil parseD2P34:data];
      break;
    case 0x36:
      result = [CC3xMessageUtil parseS2P36:data];
      break;
    default:
      break;
  }
  // TODO:本地crc对服务器报文进行校验
  //    unsigned short crc = [data CRC16];
  //    if (crc == result.crc)
  //    {
  //        return result;
  //    } else
  //    {
  //        dispatch_async(dispatch_get_main_queue(), ^{
  //            UIAlertView *alertView =
  //            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",
  //            nil)
  //                                       message:NSLocalizedString(@"Message
  //                                       error, please try again", nil)
  //                                      delegate:nil
  //                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
  //                             otherButtonTitles:nil, nil];
  //            [alertView show];
  //            [alertView release];
  //        });
  //        return nil;
  //    }

  return result;
}

#pragma mark - util method 数据转换方法

+ (NSData *)string2Data:(NSString *)aString {
  return [aString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (Byte *)mac2HexBytes:(NSString *)mac {
  NSArray *macArray = [mac componentsSeparatedByString:@":"];
  Byte *bytes = malloc(macArray.count);
  char byte_char[3] = {'\0', '\0', '\0'};
  for (int i = 0; i < macArray.count; i++) {
    NSString *str = macArray[i];
    byte_char[0] = [str characterAtIndex:0];
    byte_char[1] = [str characterAtIndex:1];
    bytes[i] = strtol(byte_char, NULL, 16);
  }
  return bytes;
}

+ (Byte *)ip2HexBytes:(NSString *)ip {
  NSArray *ipArray = [ip componentsSeparatedByString:@"."];
  Byte *bytes = malloc(ipArray.count);
  for (int i = 0; i < ipArray.count; i++) {
    NSString *item = ipArray[i];
    bytes[i] = (unsigned long)[item integerValue];
  }
  return bytes;
}

+ (NSString *)hexString2Ip:(NSString *)string {
  NSMutableString *res = [NSMutableString string];
  for (int i = 0; i < string.length; i += 2) {
    unsigned int value;
    NSRange range = NSMakeRange(i, 2);
    NSString *s1 = [string substringWithRange:range];
    NSScanner *pScaner = [NSScanner scannerWithString:s1];
    [pScaner scanHexInt:&value];
    NSString *s2 = [NSString stringWithFormat:@"%d", value];
    [res appendString:s2];
    if (i < string.length - 2) {
      [res appendString:@"."];
    }
  }

  return res;
}

+ (NSString *)data2Ip:(NSData *)data {
  NSString *str =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return [CC3xMessageUtil hexString2Ip:str];
}

+ (NSData *)hexString2Data:(NSString *)hexString {
  int j = 0;
  Byte bytes[128];
  for (int i = 0; i < [hexString length]; i++) {
    int int_ch;

    unichar hex_char1 = [hexString characterAtIndex:i];
    int int_ch1;
    if (hex_char1 >= '0' && hex_char1 <= '9')
      int_ch1 = (hex_char1 - '0') * 16;
    else if (hex_char1 >= 'A' && hex_char1 <= 'F')
      int_ch1 = (hex_char1 - 'A') * 16;
    else
      int_ch1 = (hex_char1 - 'a') * 16;
    i++;

    unichar hex_char2 = [hexString characterAtIndex:i];
    int int_ch2;
    if (hex_char2 >= '0' && hex_char2 <= '9')
      int_ch2 = (hex_char2 - 48);
    else if (hex_char1 >= 'A' && hex_char1 <= 'F')
      int_ch2 = hex_char2 - 'A';
    else
      int_ch2 = hex_char2 - 'a';

    int_ch = int_ch1 + int_ch2;
    LogInfo(@"int_ch=%d", int_ch);
    bytes[j] = int_ch;
    j++;
  }
  NSData *newData = [[NSData alloc] initWithBytes:bytes length:128];
  LogInfo(@"newData=%@", newData);
  return newData;
}

+ (NSString *)hexString:(NSData *)data {
  const unsigned char *dbytes = [data bytes];
  NSMutableString *hexStr =
      [NSMutableString stringWithCapacity:[data length] * 2];
  int i;
  for (i = 0; i < [data length]; i++) {
    [hexStr appendFormat:@"%02x ", dbytes[i]];
  }
  return [NSString stringWithString:hexStr];
}
/*
+ (NSData *)data2HexData:(NSData *)data
{
    char buf[3];
        buf[2] = '\0';
    int length = data.length;
        NSAssert(0 == length % 2, @"Hex strings should have an even number of
digits");
    Byte *bytes = (Byte *)[data bytes];
    unsigned char *newBytes = malloc(length/2);
    unsigned char *bp = newBytes;
        for (CFIndex i = 0; i < length; i += 2) {
                buf[0] = bytes[i];
                buf[1] = bytes[i+1];
                char *b2 = NULL;
                *bp++ = strtol(buf, &b2, 16);
                NSAssert(b2 == buf + 2, @"String should be all hex digits: (bad
digit around %ld)", i);
        }

        return [NSData dataWithBytesNoCopy:newBytes
                                length:length/2
                          freeWhenDone:YES];
}
*/
@end

@implementation CC3xMessage

- (id)init {
  self = [super init];
  return self;
}

- (void)setAirTag:(unsigned char)airTag {
  //  self.airTag = airTag;
  switch (airTag) {
    case 1:
      self.airDesc = @"优";
      break;
    case 2:
      self.airDesc = @"良";
      break;
    case 3:
      self.airDesc = @"轻度污染";
      break;
    case 4:
      self.airDesc = @"中度污染";
      break;
    default:
      self.airDesc = @"优";
      break;
  }
}
@end
