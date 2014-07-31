//
//  TemplateVC.m
//  winmin
//
//  Created by sdzg on 14-7-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TemplateVC.h"

@interface TemplateVC ()
@property(nonatomic, assign) NSUInteger lastSelectTag;
@property(nonatomic, strong) NSDictionary *imgDict;
- (IBAction)touchUpInside:(id)sender;
- (IBAction)save:(id)sender;

@end

@implementation TemplateVC

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
  self.navigationItem.title = @"无线开关";
  self.imgDict = @{
    @"902" : @"icon_ac",
    @"904" : @"icon_light",
    @"906" : @"icon_stb",
    @"908" : @"icon_plug",
    @"910" : @"icon_tv",
    @"912" : @"icon_v",
    @"914" : @"icon_ir"
  };
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)touchUpInside:(id)sender {
  UIButton *btn = (UIButton *)sender;
  NSUInteger imgTag;
  UIImageView *imgView;
  if (self.lastSelectTag == 0 || self.lastSelectTag == btn.tag) {
    imgTag = btn.tag + 1;
    imgView = (UIImageView *)[self.view viewWithTag:imgTag];
    if (imgView.hidden) {
      imgView.hidden = NO;
    }
  } else {
    imgTag = self.lastSelectTag + 1;
    imgView = (UIImageView *)[self.view viewWithTag:imgTag];
    if (!imgView.hidden) {
      imgView.hidden = YES;
    }
    imgTag = btn.tag + 1;
    imgView = (UIImageView *)[self.view viewWithTag:imgTag];
    imgView.hidden = !imgView.hidden;
  }
  self.lastSelectTag = btn.tag;
}

- (IBAction)save:(id)sender {
  if (self.lastSelectTag != 0) {
    NSString *tagKey =
        [NSString stringWithFormat:@"%d", self.lastSelectTag + 1];
    NSString *imgName = [self.imgDict objectForKey:tagKey];
    [self.delegate passValue:imgName];
  }
  [self.navigationController popViewControllerAnimated:YES];
}
@end
