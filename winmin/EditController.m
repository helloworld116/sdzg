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
@interface EditController ()

@end

@implementation EditController
@synthesize image_btn,lock_btn,imagePicker,filePath,content_view,name_text;

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
    self.navigationItem.title = self.aSwitch.switchName;
    //background
    UIImageView * background_imageView = [[UIImageView alloc]initWithFrame:[self.view frame]];
    background_imageView.image = [UIImage imageNamed:@"background.png"];
    [super.view addSubview:background_imageView];
    
    //navi
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [left setFrame:CGRectMake(0, 2, 28, 28)];
    
    [left setImage:[UIImage imageNamed:@"back_button"] forState:UIControlStateNormal];
    
    [left addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:left];
    
    self.navigationItem.leftBarButtonItem = leftButton;
      //content
    
    CGRect frame = CGRectMake(5, 34, DEVICE_WIDTH-20, DEVICE_HEIGHT-74);
    content_view = [[UIView alloc]initWithFrame:frame];
    [self.view addSubview:content_view];
    UIImageView * content_bg = [[UIImageView alloc]initWithFrame:frame];
    content_bg.image = [UIImage imageNamed:@"window_background"];
    [content_view addSubview:content_bg];
    content_view.layer.cornerRadius = 5.0;
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(115, 40, 100, 20)];
    label.text = @"设备信息";
    label.textColor = [UIColor whiteColor];
    [content_view addSubview:label];
    
    image_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [image_btn addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [image_btn setBackgroundImage:self.aSwitch.image forState:UIControlStateNormal];
    [image_btn setFrame:CGRectMake(100, 95, 100, 100)];
    [content_view addSubview:image_btn];
    
    lock_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lock_btn addTarget:self action:@selector(lockDevice) forControlEvents:UIControlEventTouchUpInside];
    [lock_btn setBackgroundImage:[UIImage imageNamed:@"device_unlock"] forState:UIControlStateNormal];
    [lock_btn setFrame:CGRectMake(110, 220, 80, 80)];
    [content_view addSubview:lock_btn];
    
    UIImageView * name_bg = [[UIImageView alloc]initWithFrame:CGRectMake(38, 310, 240, 30)];
    name_bg.image = [UIImage imageNamed:@"cylinder_background"];
    [content_view addSubview:name_bg];
    
     UILabel * name_label = [[UILabel alloc]initWithFrame:CGRectMake(42, 310, 58, 30)];
    name_label.text = @"名称";
    [content_view addSubview:name_label];
  
    
    name_text = [[UITextField alloc]initWithFrame:CGRectMake(110, 312, 150, 25)];
    name_text.delegate = self;
    name_text.text = self.aSwitch.switchName;
    name_text.borderStyle = UITextBorderStyleRoundedRect;
    [content_view addSubview:name_text];
    
    
    
    UIButton * save_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [save_btn setFrame:CGRectMake(38, 380, 240, 30)];
    [save_btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [save_btn setTitle:@"保存" forState:UIControlStateNormal];
    [save_btn setBackgroundImage:[UIImage imageNamed:@"save_button_image"] forState:UIControlStateNormal];
    [content_view addSubview:save_btn];
}

- (void)changeImage
{
    UIActionSheet * action = [[UIActionSheet alloc]initWithTitle:@"图片选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    [action addButtonWithTitle:@"从模板中获取"];
    [action addButtonWithTitle:@"拍照"];
    [action addButtonWithTitle:@"从手机相册中获取"];
    [action addButtonWithTitle:@"取消"];
    UIImageView * bg = [[UIImageView alloc]initWithFrame:action.frame];
    bg.image = [UIImage imageNamed:@"actionsheet_background"];
    [action addSubview:bg];

    
    [action showFromRect:CGRectMake(0, DEVICE_HEIGHT/3, 320, DEVICE_HEIGHT*2/3) inView:self.view animated:YES];
}

- (void)lockDevice
{
    NSString * lockName = !self.aSwitch.isLocked ? @"device_unlock" : @"device_lock";
    UIImage * image = [UIImage imageNamed:lockName];
    if (self.aSwitch.isLocked)
    {
        self.aSwitch.isLocked = NO;
    }else
    {
        self.aSwitch.isLocked = YES;
    }
    [lock_btn setImage:image forState:UIControlStateNormal];
    
    
    
    
    
}

- (void)save
{
    //save data
    
    name_text.text = [name_text.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([name_text.text  isEqual: @""])
    {
        self.aSwitch.switchName = name_text.placeholder;
        
    }else
    {
        self.aSwitch.switchName = name_text.text;
    }
    UIImage * image = [UIImage imageWithContentsOfFile:filePath];
    self.aSwitch.image = image;
    [image_btn setImage:image forState:UIControlStateNormal];
    NSLog(@"图片abc的%@",image_btn.imageView.image);
    if (self.view.frame.origin.y < 0)
    {
        
        [self setViewMoveUp:NO];
        [name_text resignFirstResponder];
    }
    
    //备份设备名到服务端
    if (_udpSocket.isClosed == YES || _udpSocket == nil)
    {
        [CC3xUtility setupUdpSocket:self.udpSocket
                               port:APP_PORT];
    }
    dispatch_apply(REPEATE_TIME, GLOBAL_QUEUE, ^(size_t index){
        if (self.aSwitch.status == SWITCH_LOCAL ||
            self.aSwitch.status == SWITCH_LOCAL_LOCK) {
            [self.udpSocket sendData:[CC3xMessageUtil getP2dMsg3F:name_text.text]
                              toHost:self.aSwitch.ip
                                port:self.aSwitch.port
                         withTimeout:10
                                 tag:P2D_SET_NAME_REQ_3F];
        } else if (self.aSwitch.status == SWITCH_REMOTE ||
                   self.aSwitch.status == SWITCH_REMOTE_LOCK) {
            [self.udpSocket sendData:
             [CC3xMessageUtil getP2sMsg41:self.aSwitch.macAddress
                                     name:name_text.text]
                              toHost:SERVER_IP
                                port:SERVER_PORT
                         withTimeout:10
                                 tag:P2S_SET_NAME_REQ_41];
            NSLog(@" editcontroller   191：\n发送名字 %@ 到服务器",name_text.text);
        }
    });
    
    
//    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark ---------- ActionSheetDelegate----
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    switch (buttonIndex)
    {
        case 0:
//            self presentModalViewController:<#(UIViewController *)#> animated:<#(BOOL)#>
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

#pragma mark ---获取图片
- (void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
//        [picker release];
        [self presentModalViewController:picker animated:YES];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

- (void)localPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];

}

#pragma mark ---txetfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:name_text])
    {
        if (self.view.frame.origin.y >=0)
        {
            [self setViewMoveUp:YES];
        }
        
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:name_text])
    {
        if (self.view.frame.origin.y < 0)
        {
            [self setViewMoveUp:NO];
        }
    }
}


- (void)setViewMoveUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -=kOFFSET_FOR_KEYBOARD;
//        rect.origin.y +=kOFFSET_FOR_KEYBOARD;
    }else
    {
        rect.origin.y +=kOFFSET_FOR_KEYBOARD;
//        rect.origin.y -=kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([name_text isFirstResponder] && self.view.frame.origin.y >= 0)
    {
        [self setViewMoveUp:YES];
    } else if (![name_text isFirstResponder] && self.view.frame.origin.y < 0)
    {
        [self setViewMoveUp:NO];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //初始化udpsocket，绑定接收端口
//    _udpSocket = [[GCDAsyncUdpSocket alloc]
//                  initWithDelegate:self
//                  delegateQueue:GLOBAL_QUEUE];
//    [CC3xUtility setupUdpSocket:self.udpSocket
//                           port:APP_PORT];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    if (self.udpSocket)
    {
        [self.udpSocket close];
    }
    
}

#pragma mark -----imagePicker
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    NSString *type= [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        
        //得到选择后沙盒中图片的完整路径
        filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        
        //关闭相册界面
        [picker dismissModalViewControllerAnimated:YES];
        
//        //创建一个选择后图片的小图标放在下方
//        //类似微薄选择图后的效果
//        UIImageView *smallimage = [[[UIImageView alloc] initWithFrame:CGRectMake(50, 120, 40, 40)] autorelease];
//        
//        smallimage.image = image;
//        //加在视图中
//        [self.view addSubview:smallimage];
//        [image_btn setImage:image forState:UIControlStateNormal];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissModalViewControllerAnimated:YES];
}




- (void)back
{
    
    
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --------udp delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    if (data)
    {
        CC3xMessage * msg = (CC3xMessage *)filterContext;
        if (msg.msgId == 0x40)
        {
            NSLog(@"本地设置设备名");
        }
        if (msg.msgId == 0x42) {
            NSLog(@"远程设置设备名");
        }
    }
    
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"msg %ld  has sent", tag);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    
    NSLog(@"edit UDP has been closed, %@",error);
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
