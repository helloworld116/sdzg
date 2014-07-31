//
//  XMLUtil.h
//  winmin
//
//  Created by sdzg on 14-7-31.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLUtil : NSObject
+ (instancetype)sharedInstance;
- (NSArray *)loadSwitches;
- (BOOL)saveXmlWithList:(NSArray *)switchArray;
@end
