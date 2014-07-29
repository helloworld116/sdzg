//
//  CustomCell.m
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "CustomCell.h"

#define kNameValueTag 1
#define kDeviceImageValueTag 2
#define kMacAddressValueTag 3
#define kStatusImageValueTag 4

@implementation CustomCell
@synthesize name;
@synthesize devices_image;
@synthesize macAddress;
@synthesize status_image;
@synthesize device_imageV, status_imageV, name_label, macAddress_label;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    self.contentView.frame = self.frame;
    device_imageV =
        [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 53, 53)];
    device_imageV.image = self.devices_image;
    device_imageV.tag = kDeviceImageValueTag;
    [self.contentView addSubview:device_imageV];

    name_label = [[UILabel alloc] initWithFrame:CGRectMake(64, 5, 139, 23)];
    name_label.text = self.name;
    name_label.textAlignment = NSTextAlignmentLeft;
    name_label.tag = kNameValueTag;
    name_label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:name_label];

    macAddress_label =
        [[UILabel alloc] initWithFrame:CGRectMake(64, 37, 139, 21)];
    macAddress_label.text = self.macAddress;
    macAddress_label.textAlignment = NSTextAlignmentLeft;
    [macAddress_label setFont:[UIFont fontWithName:@"Monaco" size:3.0f]];
    macAddress_label.tag = kMacAddressValueTag;
    macAddress_label.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:macAddress_label];

    status_imageV =
        [[UIImageView alloc] initWithFrame:CGRectMake(265, 10, 44, 44)];
    status_imageV.image = self.status_image;
    status_imageV.tag = kStatusImageValueTag;
    [self.contentView addSubview:status_imageV];

    self.backgroundView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"tableviewcell_background_nor"]];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
}

- (void)setStatus_image:(UIImage *)s {
  if (![s isEqual:status_image]) {
    status_image = [s copy];
    UIImageView *status_imageV1 =
        (UIImageView *)[self.contentView viewWithTag:kStatusImageValueTag];
    status_imageV1.image = status_image;
  }
}

- (void)setName:(NSString *)n {
  if (![n isEqualToString:name]) {
    name = [n copy];
    UILabel *name_label1 =
        (UILabel *)[self.contentView viewWithTag:kNameValueTag];
    name_label1.text = name;
  }
}

- (void)setMacAddress:(NSString *)m {
  if (![m isEqualToString:macAddress]) {
    macAddress = [m copy];
    UILabel *macAddress_label1 =
        (UILabel *)[self.contentView viewWithTag:kMacAddressValueTag];
    macAddress_label1.text = macAddress;
  }
}

- (void)setDevices_image:(UIImage *)d {
  if (![d isEqual:devices_image]) {
    devices_image = [d copy];
    UIImageView *devices_imageV1 =
        (UIImageView *)[self.contentView viewWithTag:kDeviceImageValueTag];
    devices_imageV1.image = devices_image;
  }
}

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
