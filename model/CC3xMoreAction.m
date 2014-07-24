//
//  CC3xMoreAction.m
//  CC3x
//
//  Created by hq on 3/14/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import "CC3xMoreAction.h"

@implementation CC3xMoreAction

- (id) init
{
   if (self = [super init]) {
      self.moreActionImage = nil;
      self.moreActionTitle = nil;
   }

   return self;
}


- (id)initWithName:(NSString *)aName
         imageName:(NSString *)imageName
{
   [self init];
   self.moreActionTitle = aName;
   self.moreActionImage = [UIImage imageNamed:imageName];

   return self;
}


- (void)dealloc
{
   [_moreActionImage release];
   [_moreActionTitle release];

   [super dealloc];
}


@end
