//
//  EditController.m
//  winmin
//
//  Created by sdzg on 14-5-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "EditController.h"
#import "CC3xSwitch.h"
#import "CC3xUtility.h"
#import "CC3xMessage.h"
#import "TemplateVC.h"
@interface EditController ()<UDPDelegate, UIAlertViewDelegate,
                             PassValueDelegate>
@property(nonatomic, strong) NSString *imageName;  //保存图片设置后的名称
@property(nonatomic, strong) NSString *deviceName;  //保存修改后的名称
@end

@implementation EditController
@synthesize image_btn, lock_btn, imagePicker, filePath, content_view, name_text;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  if ([UIViewController
          instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }
  self.navigationItem.title = self.aSwitch.switchName;
  // background
  UIImageView *background_imageView =
      [[UIImageView alloc] initWithFrame:[self.view bounds]];
  background_imageView.image = [UIImage imageNamed:@"background.png"];
  [super.view addSubview:background_imageView];

  // navi
  UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
  [left setFrame:CGRectMake(0, 2, 28, 28)];
  [left setImage:[UIImage imageNamed:@"back_button"]
        forState:UIControlStateNormal];
  [left addTarget:self
                action:@selector(back)
      forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *leftButton =
      [[UIBarButtonItem alloc] initWithCustomView:left];
  self.navigationItem.leftBarButtonItem = leftButton;
  // content

  CGRect frame = CGRectMake(5, 5, DEVICE_WIDTH - 20, DEVICE_HEIGHT - 74);
  content_view = [[UIView alloc] initWithFrame:frame];
  [self.view addSubview:content_view];
  UIImageView *content_bg = [[UIImageView alloc] initWithFrame:frame];
  content_bg.image = [UIImage imageNamed:@"window_background"];
  [content_view addSubview:content_bg];
  content_view.layer.cornerRadius = 5.0;

  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(115, 10, 100, 20)];
  label.text = @"设备信息";
  label.backgroundColor = [UIColor clearColor];
  label.textColor = [UIColor whiteColor];
  [content_view addSubview:label];

  image_btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [image_btn addTarget:self
                action:@selector(changeImage)
      forControlEvents:UIControlEventTouchUpInside];
  UIImage *image = [self.aSwitch getImageByImageName:self.aSwitch.imageName];
  [image_btn setImage:image forState:UIControlStateNormal];
  [image_btn setFrame:CGRectMake(100, 55, 100, 100)];
  [content_view addSubview:image_btn];

  NSString *deviceStateImgName =
      self.aSwitch.isLocked ? @"device_lock" : @"device_unlock";
  lock_btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [lock_btn addTarget:self
                action:@selector(lockDevice)
      forControlEvents:UIControlEventTouchUpInside];
  [lock_btn setImage:[UIImage imageNamed:deviceStateImgName]
            forState:UIControlStateNormal];
  [lock_btn setFrame:CGRectMake(110, 180, 80, 80)];
  [content_view addSubview:lock_btn];

  UIImageView *name_bg =
      [[UIImageView alloc] initWithFrame:CGRectMake(38, 270, 240, 30)];
  name_bg.image = [UIImage imageNamed:@"cylinder_background"];
  [content_view addSubview:name_bg];

  UILabel *name_label =
      [[UILabel alloc] initWithFrame:CGRectMake(42, 270, 58, 30)];
  name_label.text = @"名称";
  name_label.backgroundColor = [UIColor clearColor];
  [content_view addSubview:name_label];

  name_text = [[UITextField alloc] initWithFrame:CGRectMake(110, 272, 150, 25)];
  name_text.delegate = self;
  name_text.text = self.aSwitch.switchName;
  name_text.clearButtonMode = UITextFieldViewModeAlways;
  name_text.borderStyle = UITextBorderStyleRoundedRect;
  [content_view addSubview:name_text];

  UIButton *save_btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [save_btn setFrame:CGRectMake(38, 340, 240, 30)];
  [save_btn addTarget:self
                action:@selector(save)
      forControlEvents:UIControlEventTouchUpInside];
  [save_btn setTitle:@"保存" forState:UIControlStateNormal];
  [save_btn setBackgroundImage:[UIImage imageNamed:@"save_button_image"]
                      forState:UIControlStateNormal];
  [content_view addSubview:save_btn];
  self.udpSocket = [UdpSocketUtil shareInstance].udpSocket;
}

- (void)changeImage {
  UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"图片选择"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];
  [action addButtonWithTitle:@"从模板中获取"];
  [action addButtonWithTitle:@"拍照"];
  [action addButtonWithTitle:@"从手机相册中获取"];
  [action addButtonWithTitle:@"取消"];
  UIImageView *bg = [[UIImageView alloc] initWithFrame:action.frame];
  bg.image = [UIImage imageNamed:@"actionsheet_background"];
  [action addSubview:bg];
  [action
      showFromRect:CGRectMake(0, DEVICE_HEIGHT / 3, 320, DEVICE_HEIGHT * 2 / 3)
            inView:self.view
          animated:YES];
}

- (void)lockDevice {
  NSString *message;
  NSString *toLockMessage = @"设" @"备"
      @"锁定之后，未添加该设备的终端将无法搜索到该设备"
      @"，确定锁定该设备？（确定后保存生效）";
  NSString *toUnLockMessage = @"设"
      @"备解锁之后，所有人都可搜索到该设备，可能会存在"
      @"安全隐患，确定解锁？（确定后保存生效）";
  self.aSwitch.isLocked ? (message = toUnLockMessage)
                        : (message = toLockMessage);
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:@"取消"
                                            otherButtonTitles:@"确定", nil];
  alertView.tag = 1000;
  [alertView show];
}

- (void)save {
  if (self.view.frame.origin.y < 0) {
    [self setViewMoveUp:NO];
    [name_text resignFirstResponder];
  }
  self.deviceName = [name_text.text stringByReplacingOccurrencesOfString:@"\n"
                                                              withString:@""];
  if ([self.deviceName isEqualToString:@""]) {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"提示"
                                   message:@"名称不能为空"
                                  delegate:self
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@"确定", nil];
    alertView.tag = 1001;
    [alertView show];
  } else {
    if (self.imageName) {
      NSArray *switchs = [[XMLUtil sharedInstance] loadSwitches];
      NSMutableArray *newSwitchs = [NSMutableArray arrayWithArray:switchs];
      for (int i = 0; i < newSwitchs.count; i++) {
        CC3xSwitch *aSwitch = [newSwitchs objectAtIndex:i];
        if ([aSwitch.macAddress isEqualToString:self.aSwitch.macAddress]) {
          aSwitch.imageName = self.imageName;
          aSwitch.switchName = self.deviceName;
        }
        [newSwitchs replaceObjectAtIndex:i withObject:aSwitch];
      }
      [[XMLUtil sharedInstance] saveXmlWithList:newSwitchs];
    } else {
      self.imageName = self.aSwitch.imageName;
    }
    [[MessageUtil shareInstance] sendMsg3FOr41:self.udpSocket
                                       aSwitch:self.aSwitch
                                          name:self.deviceName
                                      sendMode:ActiveMode];
  }
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (alertView.tag) {
    case 1000:
      if (buttonIndex == 1) {
        [[MessageUtil shareInstance] sendMsg47Or49:self.udpSocket
                                           aSwitch:self.aSwitch
                                            isLock:self.aSwitch.isLocked
                                          sendMode:ActiveMode];
      }
      break;
    case 1001:
      if (buttonIndex == 1) {
        [name_text becomeFirstResponder];
      }
    default:
      break;
  }
}

#pragma mark---------- ActionSheetDelegate----
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  switch (buttonIndex) {
    case 0: {
      TemplateVC *vc = [kSharedAppliction.mainStoryboard
          instantiateViewControllerWithIdentifier:@"TemplateVC"];
      vc.delegate = self;
      [self.navigationController pushViewController:vc animated:YES];
    } break;

    case 1:
      //调用相机
      [self takePhoto];

      break;
    case 2:
      //调用本地相册
      [self localPhoto];
      break;
    case 3:
      return;
      break;
    default:
      break;
  }
}

#pragma mark---txetfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if ([textField isEqual:name_text]) {
    if (self.view.frame.origin.y >= 0) {
      [self setViewMoveUp:YES];
    }
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([textField isEqual:name_text]) {
    if (self.view.frame.origin.y < 0) {
      [self setViewMoveUp:NO];
    }
  }
}

- (void)setViewMoveUp:(BOOL)movedUp {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.5];
  CGRect rect = self.view.frame;
  if (movedUp) {
    rect.origin.y -= kOFFSET_FOR_KEYBOARD;
    //        rect.origin.y +=kOFFSET_FOR_KEYBOARD;
  } else {
    rect.origin.y += kOFFSET_FOR_KEYBOARD;
    //        rect.origin.y -=kOFFSET_FOR_KEYBOARD;
  }
  self.view.frame = rect;
  [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification {
  if ([name_text isFirstResponder] && self.view.frame.origin.y >= 0) {
    [self setViewMoveUp:YES];
  } else if (![name_text isFirstResponder] && self.view.frame.origin.y < 0) {
    [self setViewMoveUp:NO];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillShow:)
             name:UIKeyboardWillShowNotification
           object:self.view.window];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [UdpSocketUtil shareInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
  [UdpSocketUtil shareInstance].delegate = nil;
  [super viewWillDisappear:animated];
}

#pragma mark---获取图片
- (void)takePhoto {
  UIImagePickerControllerSourceType sourceType =
      UIImagePickerControllerSourceTypeCamera;
  if ([UIImagePickerController
          isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //设置拍照后的图片可被编辑
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentModalViewController:picker animated:YES];
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"连接到图片库错误"
                                   message:@""
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil];
    [alert show];
  }
}

- (void)localPhoto {
  if ([UIImagePickerController
          isSourceTypeAvailable:
              UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"连接到图片库错误"
                                   message:@""
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil];
    [alert show];
  }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
  }
  UIImage *theImage =
      [self imageWithImageSimple:image scaledToSize:CGSizeMake(160.0, 160.0)];
  NSString *str =
      [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  NSString *name = [[[str componentsSeparatedByString:@"."] objectAtIndex:0]
      stringByAppendingString:@".png"];
  [self saveImage:theImage withName:name];
  self.imageName = name;
  NSString *imagePath =
      [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
          stringByAppendingPathComponent:name];
  [image_btn setImage:[UIImage imageWithContentsOfFile:imagePath]
             forState:UIControlStateNormal];
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark 保存图片到document
- (void)saveImage:(UIImage *)tempImage withName:(NSString *)imageName {
  NSData *imageData = UIImagePNGRepresentation(tempImage);
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  // Now we get the full path to the file
  NSString *fullPathToFile =
      [documentsDirectory stringByAppendingPathComponent:imageName];
  // and then we write it out
  [imageData writeToFile:fullPathToFile atomically:NO];
}

#pragma mark 压缩图片
- (UIImage *)imageWithImageSimple:(UIImage *)image
                     scaledToSize:(CGSize)newSize {
  // Create a graphics image context
  UIGraphicsBeginImageContext(newSize);

  // Tell the old image to draw in this new context, with the desired
  // new size
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

  // Get the new image from the context
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  // End the context
  UIGraphicsEndImageContext();

  // Return the new image.
  return newImage;
}

#pragma mark 传值delegate
- (void)passValue:(id)value {
  self.imageName = (NSString *)value;
  [image_btn setImage:[UIImage imageNamed:value] forState:UIControlStateNormal];
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark--------udp delegate
- (void)responseMsgId40Or42:(CC3xMessage *)msg {
  if (msg.state == 0) {
    NSDictionary *switchInfo = @{
      @"name" : self.deviceName,
      @"imageName" : self.imageName,
      @"mac" : self.aSwitch.macAddress
    };
    [self.passValueDelegate passValue:switchInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
    //    dispatch_async(dispatch_get_main_queue(),
    //                   ^{  //        [UIView animateWithDuration:0.3
    //                       //                         animations:^(void) {
    //        //                             self.view.frame = CGRectMake(0,
    //        //                             DEVICE_HEIGHT, 0, 0);
    //        //                         }];
    //        //        dispatch_after(
    //        //            dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 *
    //        //            NSEC_PER_SEC)),
    //        //            dispatch_get_main_queue(),
    //        //            ^{ [self.navigationController
    //        //            popViewControllerAnimated:NO]; });
    //        UIViewController *vc =
    //            [self.navigationController popViewControllerAnimated:YES];
    //        vc.navigationItem.title = self.deviceName;
    //    });
  }
}

- (void)noResponseMsgId40Or42 {
  [[MessageUtil shareInstance] sendMsg3FOr41:self.udpSocket
                                     aSwitch:self.aSwitch
                                        name:self.deviceName
                                    sendMode:PassiveMode];
  if ([MessageUtil shareInstance].msg3FOr41SendCount == kTryCount - 1) {
    [[ViewUtil sharedInstance]
        showMessageInViewController:
            self message:@"修改失败，请检查设备网络是否正常"];
  }
}

- (void)noSendMsgId3FOr41 {
  [[MessageUtil shareInstance] sendMsg3FOr41:self.udpSocket
                                     aSwitch:self.aSwitch
                                        name:self.deviceName
                                    sendMode:PassiveMode];
}

- (void)responseMsgId48Or4A:(CC3xMessage *)msg {
  if (msg.state == 0) {
    dispatch_async(dispatch_get_main_queue(), ^{
        //加锁或解锁成功
        self.aSwitch.isLocked = !self.aSwitch.isLocked;
        NSString *lockName =
            self.aSwitch.isLocked ? @"device_lock" : @"device_unlock";
        UIImage *image = [UIImage imageNamed:lockName];
        [lock_btn setImage:image forState:UIControlStateNormal];
    });
  }
}

- (void)noResponseMsgId48Or4A {
  [[MessageUtil shareInstance] sendMsg47Or49:self.udpSocket
                                     aSwitch:self.aSwitch
                                      isLock:self.aSwitch.isLocked
                                    sendMode:PassiveMode];
  if ([MessageUtil shareInstance].msg47Or49SendCount == kTryCount - 1) {
    NSString *message;
    if (self.aSwitch.isLocked) {
      message = @"解锁失败，";
    } else {
      message = @"加锁失败，";
    }
    message = [message
        stringByAppendingString:@"请" @"检" @"查设备网络是否正常"];
    [[ViewUtil sharedInstance] showMessageInViewController:self
                                                   message:message];
  }
}

- (void)noSendMsgId47Or49 {
  [[MessageUtil shareInstance] sendMsg47Or49:self.udpSocket
                                     aSwitch:self.aSwitch
                                      isLock:self.aSwitch.isLocked
                                    sendMode:PassiveMode];
}
@end
