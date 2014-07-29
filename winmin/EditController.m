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
@interface EditController ()<UDPDelegate>

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
  //  [image_btn setBackgroundImage:self.aSwitch.image
  //                       forState:UIControlStateNormal];
  [image_btn setImage:[UIImage imageNamed:@"icon_plug"]
             forState:UIControlStateNormal];
  [image_btn setFrame:CGRectMake(100, 55, 100, 100)];
  [content_view addSubview:image_btn];

  lock_btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [lock_btn addTarget:self
                action:@selector(lockDevice)
      forControlEvents:UIControlEventTouchUpInside];
  [lock_btn setImage:[UIImage imageNamed:@"device_unlock"]
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
  NSString *lockName =
      !self.aSwitch.isLocked ? @"device_lock" : @"device_unlock";
  UIImage *image = [UIImage imageNamed:lockName];
  if (self.aSwitch.isLocked) {
    self.aSwitch.isLocked = NO;
  } else {
    self.aSwitch.isLocked = YES;
  }
  [lock_btn setImage:image forState:UIControlStateNormal];
}

- (void)save {
  name_text.text = [name_text.text stringByReplacingOccurrencesOfString:@"\n"
                                                             withString:@""];
  if ([name_text.text isEqual:@""]) {
    self.aSwitch.switchName = name_text.text;
  } else {
    self.aSwitch.switchName = name_text.text;
  }
  UIImage *image = [UIImage imageWithContentsOfFile:filePath];
  self.aSwitch.image = image;
  [image_btn setImage:image forState:UIControlStateNormal];
  NSLog(@"图片abc的%@", image_btn.imageView.image);
  if (self.view.frame.origin.y < 0) {
    [self setViewMoveUp:NO];
    [name_text resignFirstResponder];
  }
  [[MessageUtil shareInstance] sendMsg3FOr41:self.udpSocket
                                     aSwitch:self.aSwitch
                                        name:name_text.text];
}

#pragma mark---------- ActionSheetDelegate----
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  switch (buttonIndex) {
    case 0:
      //            self presentModalViewController:<#(UIViewController *)#>
      //            animated:<#(BOOL)#>
      break;

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
  //初始化udpsocket，绑定接收端口
  //    _udpSocket = [[GCDAsyncUdpSocket alloc]
  //                  initWithDelegate:self
  //                  delegateQueue:GLOBAL_QUEUE];
  //    [CC3xUtility setupUdpSocket:self.udpSocket
  //                           port:APP_PORT];
  [UdpSocketUtil shareInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
  //    if (self.udpSocket){
  //        [self.udpSocket close];
  //    }
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

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark--------udp delegate
- (void)responseMsgId40Or42:(CC3xMessage *)msg {
}
@end
