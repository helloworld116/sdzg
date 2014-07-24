//
//  CC3xMoreAction.h
//  CC3x
//
//  Created by hq on 3/14/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CC3xMoreAction : NSObject


@property (nonatomic, retain) UIImage *moreActionImage;
@property (nonatomic, copy) NSString *moreActionTitle;


-(id)init;
-(id)initWithName:(NSString *)aName
         imageName:(NSString *)imageName;


@end
