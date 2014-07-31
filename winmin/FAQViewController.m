//
//  FAQViewController.m
//  winmin
//
//  Created by sdzg on 14-6-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FAQViewController.h"

@interface FAQViewController ()

@end

@implementation FAQViewController

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
  self.navigationItem.title = @"常见问题";
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
  UIWebView *web = [[UIWebView alloc]
      initWithFrame:CGRectMake(
                        0, 0, DEVICE_WIDTH,
                        DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT)];
  //    web.scalesPageToFit = YES;
  web.delegate = self;
  //    web.pageLength = 2400;
  NSURL *url =
      [NSURL URLWithString:@"http://server.itouchco.com:18080/faq.html"];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [web loadRequest:request];

  //尝试是web的字体不缩小，自适应换行
  //    NSString* str1 =[NSString
  //    stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust=
  //    '%f%%'",100.0];
  //    [web stringByEvaluatingJavaScriptFromString:str1];

  [self.view addSubview:web];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)goTopVC {
  [self.navigationController popViewControllerAnimated:YES];
}
@end
