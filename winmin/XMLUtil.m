//
//  XMLUtil.m
//  winmin
//
//  Created by sdzg on 14-7-31.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "XMLUtil.h"
#import "GDataXMLNode.h"

@implementation XMLUtil
+ (instancetype)sharedInstance {
  static XMLUtil *xmlUtil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ xmlUtil = [[XMLUtil alloc] init]; });
  return xmlUtil;
}

- (NSArray *)loadSwitches {
  NSString *xmlPath = [CC3xUtility xmlFilePath];
  NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:xmlPath];
  NSError *error;
  GDataXMLDocument *doc =
      [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
  if (doc == nil) {
    return nil;
  }

  NSArray *switchArray = [doc.rootElement elementsForName:@"switch"];
  NSMutableArray *switches =
      [NSMutableArray arrayWithCapacity:switchArray.count];
  NSLog(@"xml读出设备数:%lu", (unsigned long)[switchArray count]);
  for (GDataXMLElement *aSwitch in switchArray) {
    NSString *mac = nil;
    NSString *name = nil;
    NSString *ip = nil;
    unsigned short port = 0;
    switchStatus state = SWITCH_UNKNOWN;
    BOOL local = NO;
    BOOL locked = NO;
    BOOL on = NO;
    NSString *imageName;
    NSMutableArray *timerList = nil;
    mac = [[aSwitch attributeForName:@"id"] stringValue];
    NSArray *names = [aSwitch elementsForName:@"name"];
    if (names.count > 0) {
      GDataXMLElement *firstName = (GDataXMLElement *)names[0];
      name = firstName.stringValue;
    }

    NSArray *ips = [aSwitch elementsForName:@"ip"];
    if (ips.count > 0) {
      GDataXMLElement *firstIp = (GDataXMLElement *)ips[0];
      ip = firstIp.stringValue;
    }

    NSArray *ports = [aSwitch elementsForName:@"port"];
    if (ports.count > 0) {
      GDataXMLElement *firstPort = (GDataXMLElement *)ports[0];
      port = [firstPort.stringValue intValue];
    }

    NSArray *states = [aSwitch elementsForName:@"state"];
    if (states.count > 0) {
      GDataXMLElement *firstState = (GDataXMLElement *)states[0];
      state = firstState.stringValue.boolValue;
    }

    NSArray *locks = [aSwitch elementsForName:@"locked"];
    if (locks.count > 0) {
      GDataXMLElement *firstLocked = (GDataXMLElement *)locks[0];
      locked = firstLocked.stringValue.boolValue;
    }

    NSArray *locals = [aSwitch elementsForName:@"local"];
    if (locals.count > 0) {
      GDataXMLElement *firstLocal = (GDataXMLElement *)locals[0];
      local = firstLocal.stringValue.boolValue;
    }

    NSArray *ons = [aSwitch elementsForName:@"on"];
    if (ons.count > 0) {
      GDataXMLElement *firstOn = (GDataXMLElement *)ons[0];
      NSString *onValue = firstOn.stringValue;
      if ([onValue isEqualToString:@"true"]) {
        on = YES;
      } else {
        on = NO;
      }
    }

    NSArray *imageNames = [aSwitch elementsForName:@"imageName"];
    if (imageNames.count > 0) {
      GDataXMLElement *firstImageName = (GDataXMLElement *)imageNames[0];
      imageName = firstImageName.stringValue;
    }

    //定时列表，待添加
    //        NSArray *timerLists = [aSwitch elementsForName:@"timerList"];
    //        if (timerLists.count > 0) {
    //            GDataXMLElement *firstTimerList = (GDataXMLElement
    //            *)timerLists[0];
    //            timerList = firstTimerList ;
    //        }

    CC3xSwitch *bSwitch = [[CC3xSwitch alloc] initWithName:name
                                                macAddress:mac
                                                    status:state
                                                        ip:ip
                                                      port:port
                                                  isLocked:locked
                                                      isOn:on
                                                 timerList:timerList
                                                 imageName:imageName];
    [switches addObject:bSwitch];
  }

  return switches;
}

- (BOOL)saveXmlWithList:(NSArray *)switchArray {
  GDataXMLElement *switches = [GDataXMLNode elementWithName:@"switches"];
  for (CC3xSwitch *aSwitch in switchArray) {
    NSString *mac = aSwitch.macAddress;
    NSString *portString = [NSString stringWithFormat:@"%d", aSwitch.port];
    GDataXMLElement *switchElement = [GDataXMLNode elementWithName:@"switch"];
    GDataXMLElement *idAttribute =
        [GDataXMLElement attributeWithName:@"id" stringValue:mac];
    [switchElement addAttribute:idAttribute];
    GDataXMLElement *nameEelement =
        [GDataXMLElement elementWithName:@"name"
                             stringValue:aSwitch.switchName];
    GDataXMLElement *ipEelement =
        [GDataXMLElement elementWithName:@"ip" stringValue:aSwitch.ip];
    GDataXMLElement *portElement =
        [GDataXMLElement elementWithName:@"port" stringValue:portString];
    GDataXMLElement *stateElement =
        [GDataXMLElement elementWithName:@"state" stringValue:@"0"];
    GDataXMLElement *lockedEelement =
        [GDataXMLElement elementWithName:@"locked"
                             stringValue:aSwitch.isLocked ? @"true" : @"false"];
    NSString *localStr = nil;
    if (aSwitch.status == SWITCH_LOCAL || aSwitch.status == SWITCH_LOCAL_LOCK) {
      localStr = @"true";
    } else {
      localStr = @"false";
    }
    GDataXMLElement *localElement =
        [GDataXMLElement elementWithName:@"local" stringValue:localStr];
    GDataXMLElement *onElement =
        [GDataXMLElement elementWithName:@"on"
                             stringValue:aSwitch.isOn ? @"true" : @"false"];
    GDataXMLElement *imageNameElement =
        [GDataXMLElement elementWithName:@"imageName"
                             stringValue:aSwitch.imageName];
    GDataXMLElement *timerListElement =
        [GDataXMLElement elementWithName:@"timerList"];
    [switchElement addChild:timerListElement];

    [switchElement addChild:nameEelement];
    [switchElement addChild:ipEelement];
    [switchElement addChild:portElement];
    [switchElement addChild:stateElement];
    [switchElement addChild:lockedEelement];
    [switchElement addChild:localElement];
    [switchElement addChild:onElement];
    [switchElement addChild:imageNameElement];
    [switches addChild:switchElement];
  }

  GDataXMLDocument *document =
      [[GDataXMLDocument alloc] initWithRootElement:switches];
  NSData *xmlData = document.XMLData;
  NSString *xmlPath = [CC3xUtility xmlFilePath];
  return [xmlData writeToFile:xmlPath atomically:YES];
}

@end
