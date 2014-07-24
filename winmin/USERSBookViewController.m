//
//  USERSBookViewController.m
//  winmin
//
//  Created by sdzg on 14-6-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "USERSBookViewController.h"

@interface USERSBookViewController ()

@end

@implementation USERSBookViewController

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
    self.navigationItem.title = @"用户手册";
    UIWebView * web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
//    web.scalesPageToFit = YES;
    web.delegate = self;
    
    
    
    NSURL * url = [NSURL URLWithString:@"http://server.itouchco.com:18080/mannual.html"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
    
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
