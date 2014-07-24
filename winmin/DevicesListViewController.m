//
//  DevicesListViewController.m
//  winmin
//
//  Created by sdzg on 14-5-12.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DevicesListViewController.h"
#import "DevicesProfileController.h"

#import "CustomCell.h"
@interface DevicesListViewController ()

@end

@implementation DevicesListViewController

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
    //设置导航栏背景图片
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation_background.png"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = @"设备";
    UIImageView * background_imageView = [[UIImageView alloc]initWithFrame:[self.view frame]];
    background_imageView.image = [UIImage imageNamed:@"background.png"];
    [super.view addSubview:background_imageView];
    
    self.tabBarItem.title = @"设备";
    [self.tabBarItem setSelectedImage:[UIImage imageNamed:@"tabbar_smartplug_sel.png"]];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, STATUS_HEIGHT + NAVIGATION_HEIGHT, DEVICE_WIDTH, DEVICE_HEIGHT - STATUS_HEIGHT - NAVIGATION_HEIGHT) style:UITableViewStylePlain];
    NSLog(@"%f",DEVICE_WIDTH);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    
    //设置分割线
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor redColor]];
    
    [self.view addSubview:_tableView];
    
    
}

#pragma mark -----tableViewdatasource代理------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;//??? 返回设备的数量
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifity = @"_cell";
    CustomCell * cell;
    cell = [tableView dequeueReusableCellWithIdentifier:identifity];
    if (cell == nil)
    {
//        NSArray * array = [[NSBundle mainBundle]loadNibNamed:@"customCell" owner:self options:nil];
//        cell = [array objectAtIndex:0];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        cell = [[CustomCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifity];
    }
    //TODO 单个cell所要显示的数据，状态
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableviewcell_background_nor"]];
    
    return cell;
}
//滑动cell出现删除按钮
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//


//点击触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///.......自定义推送，返回方法
    
    DevicesProfileController * profile = [DevicesProfileController new];
    //    UINavigationController * profileV = [[UINavigationController alloc]initWithRootViewController:profile];
    profile.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profile animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];//反选颜色变化

    
}
//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
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
