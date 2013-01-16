//
//  SettingsViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/19.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize menuItems,broadcastSocket,header,connection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
    NSLog(@"%@",self.slidingViewController);
}

#pragma mark -change View Controller Action

- (void)S_CellularViewControllerDidFinish:(S_CellularViewController *)controller
{

    [self dismissModalViewControllerAnimated:YES];
}
- (void)S_WiFiViewControllerDidFinish:(S_WiFiViewController *)controller
{

    [self dismissModalViewControllerAnimated:YES];
}
- (void)S_DeviceViewControllerDidFinish:(S_DeviceViewController *)controller
{

    [self dismissModalViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{


        if ([[segue identifier] isEqualToString:@"S_Cellular"]) {
            [[segue destinationViewController] setDelegate:self];
        }
        if ([[segue identifier] isEqualToString:@"S_WiFi"]) {
            [[segue destinationViewController] setDelegate:self];
        }
        if ([[segue identifier] isEqualToString:@"S_Device"]) {
            [[segue destinationViewController] setDelegate:self];
        }

}

/*********************
 * Decode SOCKET
 *********************/
#pragma mark - Decode SOCKET
-(char *)Decode_Str:(const char *)tmp_ch
{
    int len,passwordLen,msgLen;
    int *ptypeReq,typeReq;
    char *psztmp;
    int payloadSize;
    char type,version;
    
    
    char pwddata[] = "1234";
    passwordLen=strlen(pwddata);
    //char* newStr = [data bytes];
    
    
    
    //len =[tmp_ch length];
    
    memset(_decodeDate,0,sizeof(_decodeDate));
    
    
    memcpy(&version,tmp_ch,1);
    memcpy(&type,tmp_ch+1,1);
    payloadSize=0;
    memcpy(&payloadSize,tmp_ch+2,2);
    len = payloadSize;
    msgLen=len+4;
    if(payloadSize>65500) return @"";
    memcpy(_decodeDate,tmp_ch,msgLen);
    
    typeReq=0;
    ptypeReq=&typeReq;
    
    [header msgDecodeType:ptypeReq msgData:_decodeDate msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];
    psztmp=_decodeDate+4;
    NSString *Decode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d decode msg:%s",version,type,payloadSize,psztmp];
    NSLog(@"Tcp out Decod %@",Decode_str);
    return psztmp;
}

@end
