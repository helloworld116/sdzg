//
//  AboutViewController.m
//  winmin
//
//  Created by sdzg on 14-6-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@property(strong, nonatomic) IBOutlet UILabel *lblVersion;

- (IBAction)openPhone:(id)sender;
- (IBAction)openEmail:(id)sender;
- (IBAction)openWebsite:(id)sender;
@end

@implementation AboutViewController

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
  self.navigationItem.title = @"关于";
  UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
  [left setFrame:CGRectMake(0, 2, 28, 28)];
  [left setImage:[UIImage imageNamed:@"back_button"]
        forState:UIControlStateNormal];
  [left addTarget:self
                action:@selector(goTopVC)
      forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem *leftButton =
      [[UIBarButtonItem alloc] initWithCustomView:left];
  self.navigationItem.leftBarButtonItem = leftButton;
  //  [[UIApplication sharedApplication]
  //      openURL:[NSURL URLWithString:self.lblPhone.text]];
  //  NSString *appVersion =
  //      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSString *appVersionShortString = [[NSBundle mainBundle]
      objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  self.lblVersion.text = [@"V " stringByAppendingString:appVersionShortString];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (IBAction)openPhone:(id)sender {
  UIButton *btn = (UIButton *)sender;
  NSString *phoneNumFormatter =
      [@"tel://" stringByAppendingString:btn.currentTitle];
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:phoneNumFormatter]];
}

- (IBAction)openEmail:(id)sender {
  UIButton *btn = (UIButton *)sender;
  NSString *emailFormatter =
      [@"mailto://" stringByAppendingString:btn.currentTitle];
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:emailFormatter]];
}

- (IBAction)openWebsite:(id)sender {
  UIButton *btn = (UIButton *)sender;
  [[UIApplication sharedApplication]
      openURL:[NSURL URLWithString:btn.currentTitle]];
}

- (void)goTopVC {
  [self.navigationController popViewControllerAnimated:YES];
}
@end
