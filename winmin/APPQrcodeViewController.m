//
//  APPQrcodeViewController.m
//  winmin
//
//  Created by sdzg on 14-6-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "APPQrcodeViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#define kAddress @"http://pgyer.com/6L9J"

@interface APPQrcodeViewController ()<MFMailComposeViewControllerDelegate,
                                      MFMessageComposeViewControllerDelegate>
- (IBAction)smsShare:(id)sender;

- (IBAction)emailShare:(id)sender;
@end

@implementation APPQrcodeViewController

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
  self.navigationItem.title = @"APP下载链接";
  if ([UIViewController
          instancesRespondToSelector:@selector(edgesForExtendedLayout)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)smsShare:(id)sender {
  Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));

  if (messageClass != nil) {
    // Check whether the current device is configured for sending SMS messages
    if ([messageClass canSendText]) {
      [self displaySMSComposerSheet];
    } else {
      UIAlertView *alert =
          [[UIAlertView alloc] initWithTitle:@""
                                     message:@"设备不支持短信功能"
                                    delegate:self
                           cancelButtonTitle:@"确定"
                           otherButtonTitles:nil];
      [alert show];
    }
  } else {
  }
}

- (IBAction)emailShare:(id)sender {
  Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
  if (mailClass != nil) {
    if ([mailClass canSendMail]) {
      [self displayMailComposerSheet];
    } else {
      UIAlertView *alert =
          [[UIAlertView alloc] initWithTitle:@""
                                     message:@"设备不支持邮件功能"
                                    delegate:self
                           cancelButtonTitle:@"确定"
                           otherButtonTitles:nil];
      [alert show];
    }
  } else {
  }
}

- (void)displayMailComposerSheet {
  MFMailComposeViewController *picker =
      [[MFMailComposeViewController alloc] init];
  picker.mailComposeDelegate = self;
  [picker setSubject:@"分享无线开关APP下载地址"];
  // Set up recipients
  //  NSArray *toRecipients = [NSArray arrayWithObject:@"first@qq.com"];
  //  NSArray *ccRecipients =
  //      [NSArray arrayWithObjects:@"second@qq.com", @"third@qq.com", nil];
  //  NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@qq.com"];
  //
  //  [picker setToRecipients:toRecipients];
  //  [picker setCcRecipients:ccRecipients];
  //  [picker setBccRecipients:bccRecipients];
  //发送图片附件
  // NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy"
  // ofType:@"jpg"];
  // NSData *myData = [NSData dataWithContentsOfFile:path];
  //[picker addAttachmentData:myData mimeType:@"image/jpeg"
  // fileName:@"rainy.jpg"];
  //发送txt文本附件
  // NSString *path = [[NSBundle mainBundle] pathForResource:@"MyText"
  // ofType:@"txt"];
  // NSData *myData = [NSData dataWithContentsOfFile:path];
  //[picker addAttachmentData:myData mimeType:@"text/txt"
  // fileName:@"MyText.txt"];
  //发送doc文本附件
  // NSString *path = [[NSBundle mainBundle] pathForResource:@"MyText"
  // ofType:@"doc"];
  // NSData *myData = [NSData dataWithContentsOfFile:path];
  //[picker addAttachmentData:myData mimeType:@"text/doc"
  // fileName:@"MyText.doc"];
  //发送pdf文档附件
  /*
   NSString *path = [[NSBundlemainBundle]
   pathForResource:@"CodeSigningGuide"ofType:@"pdf"];
   NSData *myData = [NSDatadataWithContentsOfFile:path];
   [pickeraddAttachmentData:myData mimeType:@"file/pdf"fileName:@"rainy.pdf"];
   */
  // Fill out the email body text
  NSString *emailBody = [NSString
      stringWithFormat:@"分享无线开关APP下载地址%@", kAddress];
  [picker setMessageBody:emailBody isHTML:NO];
  [self presentModalViewController:picker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  // Notifies users about errors associated with the interface
  switch (result) {
  caseMFMailComposeResultCancelled:
    NSLog(@"Result: Mail sending canceled");
    break;
  caseMFMailComposeResultSaved:
    NSLog(@"Result: Mail saved");
    break;
  caseMFMailComposeResultSent:
    NSLog(@"Result: Mail sent");
    break;
  caseMFMailComposeResultFailed:
    NSLog(@"Result: Mail sending failed");
    break;
    default:
      NSLog(@"Result: Mail not sent");
      break;
  }
  [self dismissModalViewControllerAnimated:YES];
}

- (void)displaySMSComposerSheet {
  MFMessageComposeViewController *picker =
      [[MFMessageComposeViewController alloc] init];
  picker.messageComposeDelegate = self;
  NSString *smsBody = [NSString
      stringWithFormat:@"分享无线开关APP下载地址%@", kAddress];
  picker.body = smsBody;
  [self presentModalViewController:picker animated:YES];
}

- (void)messageComposeViewController:
            (MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
  [self dismissModalViewControllerAnimated:YES];
}
@end
