//
//  EditController.h
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncUdpSocket.h"
@class CC3xSwitch;
@interface EditController
    : UIViewController<UITextFieldDelegate, UIActionSheetDelegate,
                       UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate,
                       GCDAsyncUdpSocketDelegate>

@property(nonatomic, assign) id<PassValueDelegate> passValueDelegate;
@property(nonatomic, retain) UIView* content_view;
@property(nonatomic, retain) UITextField* name_text;

@property(nonatomic, retain) CC3xSwitch* aSwitch;
@property(nonatomic, retain) UIButton* image_btn;
@property(nonatomic, retain) UIButton* lock_btn;
@property(nonatomic, retain) UIImagePickerController* imagePicker;
@property(nonatomic, retain) NSString* filePath;
@property(nonatomic, retain) GCDAsyncUdpSocket* udpSocket;

- (void)changeImage;

- (void)lockDevice;

- (void)save;

- (void)back;

- (void)takePhoto;

- (void)localPhoto;

@end
