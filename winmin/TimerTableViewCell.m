//
//  TimerTableViewCell.m
//  winmin
//
//  Created by sdzg on 14-5-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerTableViewCell.h"

#define kOpen_labelValue 100001
#define kOpen_status_labelValue 100002
#define kOpen_fieldValue 100003
#define kClose_labelValue 100004
#define kClose_status_labelValue 100005
#define kClose_fieldValue 100006
#define kRept_labelValue 100007




@implementation TimerTableViewCell
@synthesize open_field,open_label,open_status_label,close_field,close_label,close_status_label,set_switch,mondayButton,tuesdayButton,wensdayButton,thursdayButton,fridayButton,saturdayButton,sundayButton,repeat_label;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        open_label = [[UILabel alloc]initWithFrame:CGRectMake(15, 7, 39, 21)];
        open_label.text = @"打开";
        close_label = [[UILabel alloc]initWithFrame:CGRectMake(15, 41, 39, 21)];
        close_label.text = @"关闭";
        repeat_label = [[UILabel alloc]initWithFrame:CGRectMake(15, 79, 39, 21)];
        repeat_label.text = @"重复";
        open_field = [[UITextField alloc]initWithFrame:CGRectMake(56, 5, 97, 30)];
        open_field.enabled = NO;
        close_field = [[UITextField alloc]initWithFrame:CGRectMake(56, 39, 97, 30)];
        close_field.enabled = NO;
        open_status_label = [[UILabel alloc]initWithFrame:CGRectMake(124, 9, 64, 21)];
        open_status_label.text = @"未运行";
        close_status_label = [[UILabel alloc]initWithFrame:CGRectMake(124, 43, 64, 21)];
        close_status_label.text = @"未运行";
        
        open_label.tag = kOpen_labelValue;
        open_field.tag = kOpen_fieldValue;
        open_status_label.tag = kOpen_status_labelValue;
        repeat_label.tag = 28;
        
        close_label.tag = kClose_labelValue;
        close_field.tag = kClose_fieldValue;
        close_status_label.tag = kClose_status_labelValue;
        
        set_switch = [[UISwitch alloc]initWithFrame:CGRectMake(180, 31, 51, 31)];
        
        
        
        [self.contentView addSubview:set_switch];
        
        [self.contentView addSubview:open_label];
        [self.contentView addSubview:open_field];
        [self.contentView addSubview:open_status_label];
        
        [self.contentView addSubview:close_label];
        [self.contentView addSubview:close_field];
        [self.contentView addSubview:close_status_label];
        
        UIImage * image = [UIImage imageNamed:@"smartplug_timer_week_button_nor"];
        mondayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [mondayButton setFrame:CGRectMake(62, 75, 25, 25)];
        [mondayButton setBackgroundImage:image forState:UIControlStateNormal];
        mondayButton.tag = 21;
        [mondayButton setTitle:@"一" forState:UIControlStateNormal];
        [self.contentView addSubview:mondayButton];
        
        tuesdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tuesdayButton setFrame:CGRectMake(85, 75, 25, 25)];
        [tuesdayButton setBackgroundImage:image forState:UIControlStateNormal];
        [tuesdayButton setTitle:@"二" forState:UIControlStateNormal];
        tuesdayButton.tag = 22;
        [self.contentView addSubview:tuesdayButton];
        
        wensdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [wensdayButton setFrame:CGRectMake(110, 75, 25, 25)];
        [wensdayButton setBackgroundImage:image forState:UIControlStateNormal];
        wensdayButton.tag = 23;
        [wensdayButton setTitle:@"三" forState:UIControlStateNormal];
        [self.contentView addSubview:wensdayButton];
        
        thursdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [thursdayButton setFrame:CGRectMake(135, 75, 25, 25)];
        [thursdayButton setBackgroundImage:image forState:UIControlStateNormal];
        thursdayButton.tag = 24;
        [thursdayButton setTitle:@"四" forState:UIControlStateNormal];
        [self.contentView addSubview:thursdayButton];
        
        fridayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fridayButton setFrame:CGRectMake(160, 75, 25, 25)];
        [fridayButton setBackgroundImage:image forState:UIControlStateNormal];
        fridayButton.tag = 25;
        [fridayButton setTitle:@"五" forState:UIControlStateNormal];
        [self.contentView addSubview:fridayButton];
        
        saturdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [saturdayButton setFrame:CGRectMake(185, 75, 25, 25)];
        [saturdayButton setBackgroundImage:image forState:UIControlStateNormal];
        saturdayButton.tag = 26;
        [saturdayButton setTitle:@"六" forState:UIControlStateNormal];
        [self.contentView addSubview:saturdayButton];
        
        sundayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sundayButton setFrame:CGRectMake(210, 75, 25, 25)];
        [sundayButton setBackgroundImage:image forState:UIControlStateNormal];
        sundayButton.tag = 27;
        [sundayButton setTitle:@"日" forState:UIControlStateNormal];
        [self.contentView addSubview:sundayButton];
        
        
        
        
        
        //手势
        UILongPressGestureRecognizer *longPressGesture =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress1:)];
        longPressGesture.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPressGesture];

        
        
        
        NSLog(@"叫你开始画cell了");

        
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
}



- (void)awakeFromNib
{
    // Initialization code
}
//set
- (void)setOpen_label:(UILabel *)a
{
    if (![a isEqual:open_label])
    {
        open_label = [a copy];
        UILabel * open_label1 = (UILabel *)[self.contentView viewWithTag:kOpen_labelValue];
        open_label1 = open_label;
    }
}
- (void)setOpen_field:(UITextField *)a
{
    if (![a isEqual:open_field])
    {
        open_field = [a copy];
        UITextField * open_field1 = (UITextField *)[self.contentView viewWithTag:kOpen_fieldValue];
        open_field1 = open_field;
    }
}
- (void)setOpen_status_label:(UILabel *)a
{
    if (![a isEqual:open_status_label])
    {
        open_status_label = [a copy];
        UILabel * open_status_label1 = (UILabel *)[self.contentView viewWithTag:kOpen_status_labelValue];
        open_status_label1 = open_status_label;
    }
}
- (void)setClose_label:(UILabel *)a
{
    if (![a isEqual:close_label])
    {
        close_label = [a copy];
        UILabel * close_label1 = (UILabel *)[self.contentView viewWithTag:kClose_labelValue];
        close_label1 = close_label;
    }
}
- (void)setClose_field:(UITextField *)a
{
    if (![a isEqual:close_field])
    {
        close_field = [a copy];
        UITextField * close_field1 = (UITextField *)[self.contentView viewWithTag:kClose_fieldValue];
        close_field1 = close_field;
    }
}
- (void)setClose_status_label:(UILabel *)a
{
    if (![a isEqual:close_status_label])
    {
        close_status_label = [a copy];
        UILabel * close_status_label1 = (UILabel *)[self.contentView viewWithTag:kClose_status_labelValue];
        close_status_label1 = close_status_label;
    }
}

- (void)setMondayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:21];
        button = mondayButton;
    }
}
- (void)setTuesdayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:22];
        button = mondayButton;
    }
}
- (void)setWensdayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:23];
        button = mondayButton;
    }
}
- (void)setThursdayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:24];
        button = mondayButton;
    }
}
- (void)setFridayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:25];
        button = mondayButton;
    }
}
- (void)setSaturdayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:26];
        button = mondayButton;
    }
}
- (void)setSundayButton:(UIButton *)a
{
    if (![a isEqual:mondayButton])
    {
        mondayButton = [a copy];
        UIButton * button = (UIButton *)[self.contentView viewWithTag:27];
        button = mondayButton;
    }
}

- (void)setRepeat_label:(UILabel *)a
{
    if (![a isEqual:repeat_label])
    {
        repeat_label = [a copy];
        UILabel * repeat_label1= (UILabel *)[self.contentView viewWithTag:28];
        repeat_label1 = repeat_label;
    }
}


- (void)handleLongPress1:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.aDelegate timerListCell:self
                   didHandleLongPress:recognizer];
    }

}






- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
