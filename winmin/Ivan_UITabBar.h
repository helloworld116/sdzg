//
//  Ivan_UITabBar.h
//  JustForTest
//
//  Created by Ivan on 11-5-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIBadgeView;

@interface Ivan_UITabBar : UITabBarController {
	NSMutableArray *buttons;
	int currentSelectedIndex;
	UIImageView *slideBg;
	UIView *cusTomTabBarView;
	UIImageView *backGroundImageView;
    NSDictionary *dictBtnImg;
    UIBadgeView *badgeViewGet;
}

@property (nonatomic, assign) int currentSelectedIndex;

@property (nonatomic,retain) NSMutableArray *buttons;
@property (nonatomic,retain) NSDictionary *dictBtnImg;

- (void)hideRealTabBar;
- (void)customTabBar;
- (void)selectedTab:(UIButton *)button;
- (void)hiddenTabBar:(BOOL)hide;

@end
