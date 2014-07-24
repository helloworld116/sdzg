//
//  CustomCell.h
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
{
    
    
    
    
}

@property (nonatomic ,retain) UIImageView * device_imageV;
@property (nonatomic ,retain) UILabel * name_label;
@property (nonatomic ,retain) UILabel * macAddress_label;
@property (nonatomic ,retain) UIImageView * status_imageV;

@property (nonatomic ,copy) NSString * name;
@property (nonatomic ,copy) NSString * macAddress;
@property (nonatomic ,retain) UIImage * devices_image;
@property (nonatomic ,retain) UIImage * status_image;

- (void)setDevices_image:(UIImage *)devices_image;

- (void)setName:(NSString *)name;

- (void)setMacAddress:(NSString *)macAddress;

- (void)setStatus_image:(UIImage *)status_image;

@end
