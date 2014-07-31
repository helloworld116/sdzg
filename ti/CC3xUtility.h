/*
 * File: CC3xUtility.h
 * Copyright © 2013, Texas Instruments Incorporated - http://www.ti.com/
 * All rights reserved.
 */

#import <UIKit/UIKit.h>

#import "CC3xAPManager.h"
#import "CC3xHeader.h"
#import <QuartzCore/QuartzCore.h>
#import "GCDAsyncUdpSocket.h"
#import "DDLog.h"

#define xmlFile @"switch.xml"

#define REPEATE_TIME 3

#define SSID_TAG 100
#define PASSWORD_TAG 101
#define GATEWAY_TAG 102
#define KEY_TAG 103
#define DEVICE_NAME_TAG 104

#define SERVER_IP @"server.itouchco.com"
//"183.63.35.203:18080"
// 115.28.178.252
#define SERVER_PORT 20001
// 21845
#define APP_PORT 43690

#define DEVICE_PORT 56797

#define EXPORT_PORT 43709

#define BIND_PORT 43710

#define REFRESH_DEV_TIME 15

#define DEFAULT_NAME NSLocalizedString(@"Smart switch", nil)
#define DEFAULT_IMAGENAME @"icon_plug"

#define BROADCAST_ADDRESS @"255.255.255.255"

#define kShake @"SHAKE_KEY"

#define GLOBAL_QUEUE \
  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// Log
#define LogAsync NO
#define LogContext 65535

#define LogObjc(flg, frmt, ...) \
  LOG_OBJC_MAYBE(LogAsync, logLevel, flg, LogContext, frmt, ##__VA_ARGS__)
#define LogC(flg, frmt, ...) \
  LOG_C_MAYBE(LogAsync, logLevel, flg, LogContext, frmt, ##__VA_ARGS__)

#define LogError(frmt, ...) \
  LogObjc(LOG_FLAG_ERROR, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)
#define LogWarn(frmt, ...) \
  LogObjc(LOG_FLAG_WARN, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)
#define LogInfo(frmt, ...) \
  LogObjc(LOG_FLAG_INFO, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)
#define LogVerbose(frmt, ...) \
  LogObjc(LOG_FLAG_VERBOSE, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)

#define LogCError(frmt, ...) \
  LogC(LOG_FLAG_ERROR, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)
#define LogCWarn(frmt, ...) \
  LogC(LOG_FLAG_WARN, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)
#define LogCInfo(frmt, ...) \
  LogC(LOG_FLAG_INFO, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)
#define LogCVerbose(frmt, ...) \
  LogC(LOG_FLAG_VERBOSE, (@"%@: " frmt), THIS_FILE, ##__VA_ARGS__)

#define LogTrace() LogObjc(LOG_FLAG_VERBOSE, @"%@: %@", THIS_FILE, THIS_METHOD)
#define LogCTrace() LogC(LOG_FLAG_VERBOSE, @"%@: %s", THIS_FILE, __FUNCTION__)

// Log levels : off, error, warn, info, verbose
static const int logLevel = LOG_LEVEL_VERBOSE;

enum {
  P2P_INFO_TAG_0,
  P2P_READ_INFO_TAG_0,
};

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

@interface CC3xUtility : NSObject {
}

/// methods

/*!!!
 Singleton instance
 return: static allocated instance of self
 */
+ (CC3xUtility *)sharedInstance;

/*!!!
  Destroy the static singleton instance
 */
+ (void)destroy;

+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

+ (void)setupUdpSocket:(GCDAsyncUdpSocket *)socket port:(uint16_t)aPort;

+ (void)networkNotReachableAlert;

+ (NSString *)xmlFilePath;

+ (BOOL)checkNetworkStatus;

/*
 Prepare a cell that is created with respect to the indexpath
 @param cell is an object of UITableViewcell which is newly created
 @param indexpath  is respective indexpath of the cell of the row.
 */
- (UITableViewCell *)prepareCell:(UITableViewCell *)cell
                     atIndexPath:(NSIndexPath *)indexPath;

/*
 Creates label with its defined properties and add it on the provider view.
 @param view is the provider view where label needs to be added.
 @param text set text property
 @param alignment set alignment property
 @param color set color property
 @return label returns the created label for any custom property settings.
 */
- (UILabel *)createLabelWithFrame:(CGRect)rect
                           onView:(UIView *)view
                         withText:(NSString *)text
                        alignment:(NSTextAlignment)textAlignment
                            color:(UIColor *)color;

/*
 Roatating the spinning wheel when app starts transmitting data
 @param: Spinner which suppose to rotate with CAAnimation
 @param: The start button on which it appears
 @param: Bool value for start or stop the animation
 */
- (void)rotateSpinner:(UIImageView *)spinner
             onButton:(UIButton *)button
              isStart:(BOOL)start;

@end
