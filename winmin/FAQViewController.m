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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"常见问题";
    UIWebView * web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
//    web.scalesPageToFit = YES;
    web.delegate = self;
    web.pageLength = 2400;
    NSLog(@"常见问题");
    
    NSURL * url = [NSURL URLWithString:@"http://server.itouchco.com:18080/faq.html"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];

    //尝试是web的字体不缩小，自适应换行
//    NSString* str1 =[NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%f%%'",100.0];
//    [web stringByEvaluatingJavaScriptFromString:str1];
    
    [self.view addSubview:web];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
