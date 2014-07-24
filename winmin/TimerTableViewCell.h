//
//  TimerTableViewCell.h
//  winmin
//
//  Created by sdzg on 14-5-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimerTableViewCell;
@protocol TimerTableViewCellDelegate <NSObject>

- (void)timerListCell:(TimerTableViewCell *)cell didHandleLongPress:(UIGestureRecognizer *)recognizer;

@end



@interface TimerTableViewCell : UITableViewCell
{
 
    
//    UIImageView * imageV1;
//    UIImageView * imageV2;
//    UIImageView * imageV3;
//    UIImageView * imageV4;
//    UIImageView * imageV5;
//    UIImageView * imageV6;
//    UIImageView * imageV7;
    
    
}
@property (nonatomic, retain) id<TimerTableViewCellDelegate> aDelegate;

@property (retain, nonatomic) UILabel * open_label;
@property (retain, nonatomic) UILabel * close_label;
@property (retain, nonatomic) UILabel * repeat_label;
@property (retain, nonatomic) UITextField * open_field;
@property (retain, nonatomic) UITextField * close_field;
@property (retain, nonatomic) UILabel * open_status_label;
@property (retain, nonatomic) UILabel * close_status_label;
@property (retain, nonatomic) UISwitch * set_switch;









@property (retain, nonatomic) UIButton * mondayButton;
@property (retain, nonatomic) UIButton * tuesdayButton;
@property (retain, nonatomic) UIButton * wensdayButton;
@property (retain, nonatomic) UIButton * thursdayButton;
@property (retain, nonatomic) UIButton * fridayButton;
@property (retain, nonatomic) UIButton * saturdayButton;
@property (retain, nonatomic) UIButton * sundayButton;






- (void)handleLongPress1:(UIGestureRecognizer *)recognizer;



@end
