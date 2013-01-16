//
//  MainViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/3.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import "MainViewController.h"
#import "Message_Define.h"

#define SRV_CONNECTED 0
#define SRV_CONNECT_SUC 1
#define SRV_CONNECT_FAIL 2
@interface MainViewController ()

@end

@implementation MainViewController
@synthesize broadcastSocket,header,scanningView,connection;
@synthesize menuItems,Devicename,menu,Device_list,b_Refresh;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //Set bundle version
    //self.Device_list.delegate = self;
   
    Devicename = [[NSString alloc] init];
    
    self.Devicename = @"No Device Connect";

    
    Devide_password = [[NSUserDefaults standardUserDefaults] stringForKey:@"DevicePassword"];
    if (Devide_password) {
        default_password = Devide_password;
    }else
    {
        default_password = @"1234";
        Devide_password = default_password;
        [[NSUserDefaults standardUserDefaults] setObject:default_password forKey:@"DevicePassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    header=[ZyXELAPPLib new];

    
    send_tag = 0;



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [self performSelector:@selector(sendBroadcastUDP) withObject:Nil afterDelay:0.5]; 

}

- (IBAction)revealMenu:(id)sender
{
    [connection disconnect];
    [connection release];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)Reflash:(id)sender
{
    NSError* error;
    self.scanningView.hidden = NO;
    [scanningView setHidden:NO];
    [broadcastSocket enableBroadcast:NO error:&error];
    [connection disconnect];
    [connection release];
   [self sendBroadcastUDP];
    send_tag = 0;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (void)dealloc
{
    [_flipsidePopoverController release];
    [super dealloc];
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

/*********************
 * UDP broadcast
 *********************/
#pragma mark - UDP broadcast
-(void) sendBroadcastUDP{
    scanningView.hidden = NO;
    broadcastSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [broadcastSocket setDelegate:self];
    
    NSError *error = nil;

	if (![broadcastSocket bindToPort:0 error:&error])
	{
		NSLog(@"Error binding: %@", error);
		return;
	}
    int len,passwordLen,msgLen;
    char *psztmp;
    char type,version;
    int payloadSize;
    //char *transmit = "{\"InternetGatewayDevice\":{\"X_ZyXEL_Ext\":{\"AppInfo\":{\"MagicNum\":\"Z3704\",\"AppVersion\":1}}}}";
    //char *transmit = "{\"Device\":{\"X_ZyXEL_Ext\":{\"AppInfo\":{\"MagicNum\":\"Z3704\",\"AppVersion\":1}}}}";
 
    NSString *mystr=[NSString stringWithFormat:DeviceDiscoverReq];
    char *transmit = [mystr UTF8String];
    
    
    [broadcastSocket enableBroadcast:YES error:&error];
    
    len=strlen(transmit);

    memset(_encodeData,0,sizeof(_encodeData));
    memcpy(_encodeData+4,transmit,len);
    msgLen=len+4;
    
    
    const char *pwddata = [default_password UTF8String];
    passwordLen=[default_password length];

    
    int backheader = [header msgEncodeType:msgType_DiscoverReq msgData:_encodeData msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];

    psztmp=_encodeData+4;
    
    memcpy(&version,_encodeData,1);
    memcpy(&type,_encodeData+1,1);
    payloadSize=0;
    memcpy(&payloadSize,_encodeData+2,2);
    NSString *Encode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d encode msg:%s",version,type,payloadSize,psztmp];
    
    //[broadcastSocket bindToAddress:broascastHost port:DISCOVERY_PORT error:nil];

    NSData* data = [[NSData alloc] initWithBytes:_encodeData length:msgLen];
    [broadcastSocket sendData:data toHost:broascastHost port:263 withTimeout:-1 tag:0];
    [broadcastSocket receiveWithTimeout:-1 tag:0];
    //[data release];
    

    
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    if([host isEqualToString:routerHost])
       {
           
           [self ReadJason:[self Decode_Str:[data bytes]]];
           //[broadcastSocket receiveWithTimeout:-1 tag:0];
           
           send_tag =0;
           [self.view addGestureRecognizer:self.slidingViewController.panGesture];
           menu.userInteractionEnabled=YES;
           self.scanningView.hidden = YES;
           [self performSelector:@selector(tablereload) withObject:Nil afterDelay:0.5];
           [self sendTCPData:msgType_ParameterGetReq sendtag:12];
           send_tag = 12;
       }

    
    /***********************
     *
     * Flow:
     * Check that connection is not own IP
     * Store host and device name in array
     * example connection: [tcpSocket connectToHost:host onPort:263 error:&error];
     */
    

    return NO;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	NSLog(@"Broadcast away!");
   //self.scanningView.hidden = YES;

}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"Broadcast error!");
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                      message:@"Not connected."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    menu.userInteractionEnabled=NO;
    self.scanningView.hidden = YES;

}


/*********************
 * TCP SOCKET
 *********************/
#pragma mark - TCP SOCKET
-(void) sendTCPData:(int)sendtype sendtag:(long)tmptag
{
    NSError *err;
    
    connection = [[AsyncSocket alloc] initWithDelegate:self];
    [connection setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    if (![connection connectToHost:routerHost onPort:263 error:&err]) {
        NSLog(@" %@",[err localizedDescription]);
        
        return;
    }
    int len,passwordLen,msgLen;
    char *psztmp;
    char type,version;
    int payloadSize;

    NSData *jsonData;
    
    if (tmptag == 11) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_Host]
                                                   options:0
                                                     error:&err];
    }else if (tmptag == 12)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self DevicePassword]
                                                   options:0
                                                     error:&err];
    }
    const char *transmit = [jsonData bytes];
    len = [jsonData length];

    memset(_encodeData,0,sizeof(_encodeData));
    memcpy(_encodeData+4,transmit,len);
    msgLen=len+4;
    
    
    const char *pwddata = [default_password UTF8String];
    passwordLen=[default_password length];

    
    int backheader = [header msgEncodeType:msgType_ParameterGetReq msgData:_encodeData msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];

    psztmp=_encodeData+4;
    
    memcpy(&version,_encodeData,1);
    memcpy(&type,_encodeData+1,1);
    payloadSize=0;
    memcpy(&payloadSize,_encodeData+2,2);
    NSString *Encode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d encode msg:%s",version,type,payloadSize,psztmp];


    NSData* data = [[NSData alloc] initWithBytes:_encodeData length:msgLen];
    
    [connection writeData:data withTimeout:-1 tag:tmptag];
    //[data release];
    
 
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected host = %@  port = %d",host,port);
    [connection readDataWithTimeout:-1 tag:send_tag];
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"willDisconnectWithError(错误):%p    %@",sock,err);
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSString *msg = @"Sorry this connect is failure";
    //[self showMessage:msg];
    [msg release];
    connection = nil;
}
- (void)onSocketDidSecure:(AsyncSocket *)sock{
    
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag

{
    
    NSLog(@"thread(%@),onSocket:%p didWriteDataWithTag:%ld",[[NSThread currentThread] name],
          
          sock,tag);
    
}

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{

    [self ReadJason:[self Decode_Str:[data bytes]]];
    //[connection readDataWithTimeout:-1 tag:0];
    [connection disconnect];
    [connection release];
   

}
/*********************
 * Encode SOCKET
 *********************/
#pragma mark - Encode SOCKET
-(char *)Encode_Str:(char *)tmp_ch
{
    int len,passwordLen,msgLen,retCode;
    char *psztmp;
    char type,version,*stop;
    int payloadSize;
    
    len=strlen(tmp_ch);
    memset(_encodeData,0,sizeof(_encodeData));
    memcpy(_encodeData+4,tmp_ch,len);
    msgLen=len+4;
    
    
    const char *pwddata = [default_password UTF8String];
    passwordLen=[default_password length];
    
    int backheader = [header msgEncodeType:msgType_SystemQueryReq msgData:_encodeData msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];

    psztmp=_encodeData+4;
    
    memcpy(&version,_encodeData,1);
    memcpy(&type,_encodeData+1,1);
    payloadSize=0;
    memcpy(&payloadSize,_encodeData+2,2);
    NSString *Encode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d encode msg:%s",version,type,payloadSize,psztmp];
    return _encodeData;

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
    
    
    const char *pwddata = [default_password UTF8String];
    passwordLen=[default_password length];
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
    return psztmp;
}

/*********************
 * PARAMETER Json
 *********************/
#pragma mark - PARAMETER Json
-(NSDictionary*)DevicePassword
{
    
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:Devide_password forKey:@"ConfigPassword"];
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:ThirdLevel forKey:@"LANConfigSecurity"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
    return TopLevel;
    
}
-(NSDictionary*)SystemInfo_3GPP
{
    
    NSMutableDictionary *data_Monthly = [[NSMutableDictionary alloc] init];
    [data_Monthly setValue:[NSNumber numberWithInteger:0] forKey:@"MonthlyLimit"];
    [data_Monthly setValue:@"" forKey:@"LastResetDate"];
    [data_Monthly setValue:[NSNumber numberWithInteger:1] forKey:@"ResetCounter"];
    if(0){
        [data_Monthly setValue:[NSNumber numberWithInteger:1] forKey:@"MonthlyResetEnable"];
        [data_Monthly setValue:[NSNumber numberWithInteger:0]  forKey:@"MonthlyResetDay"];
    }
    

    NSMutableDictionary *data_1 = [[NSMutableDictionary alloc] init];
    [data_1 setValue:[NSNumber numberWithInteger:0] forKey:@"BytesReceived"];
    [data_1 setValue:[NSNumber numberWithInteger:0] forKey:@"BytesSent"];
    [data_1 setValue:data_Monthly forKey:@"DataPlanManagement"];
    

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:[NSNumber numberWithInteger:0] forKey:@"SignalStrength"];
    [data setValue:@"" forKey:@"CellularMode"];
    [data setValue:@"" forKey:@"ServiceProvider"];
    [data setValue:data_1 forKey:@"Stats"];
    
    NSDictionary *i1Level = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSDictionary *faceLevel = [NSDictionary dictionaryWithObject:i1Level forKey:@"Interface"];
    NSDictionary *GPPLevel = [NSDictionary dictionaryWithObject:faceLevel forKey:@"X_ZyXEL_3GPP"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:GPPLevel forKey:@"Device"];
    return TopLevel;
}

-(NSDictionary*)SystemInfo_Battery
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:@"" forKey:@"ChargeStat"];
    [data setValue:[NSNumber numberWithInteger:0] forKey:@"TotalCapacity"];
    [data setValue:[NSNumber numberWithInteger:0] forKey:@"RemainCapacity"];
    
    NSDictionary *BatteryLevel = [NSDictionary dictionaryWithObject:data forKey:@"BatteryStatus"];
    NSDictionary *ExtLevel = [NSDictionary dictionaryWithObject:BatteryLevel forKey:@"X_ZyXEL_Ext"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:ExtLevel forKey:@"Device"];
    return TopLevel;
}
-(NSDictionary*)SystemInfo_WiFi_Entries
{
    NSDictionary *EntriesLevel = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:@"AssociatedDeviceNumberOfEntries"];
    NSDictionary *i1Level = [NSDictionary dictionaryWithObject:EntriesLevel forKey:@"i1"];
    NSDictionary *wAccessLevel = [NSDictionary dictionaryWithObject:i1Level forKey:@"AccessPoint"];
    NSDictionary *wifiLevel = [NSDictionary dictionaryWithObject:wAccessLevel forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:wifiLevel forKey:@"Device"];
     return TopLevel;
}

-(NSDictionary*)SystemInfo_WiFi
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:@"" forKey:@"SSID"];
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:@"" forKey:@"TransmitPowerSupported"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"TransmitPower"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"AutoChannelSupported"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"AutoChannelEnable"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"Channel"];
    NSDictionary *ThirdLevel_1 = [NSDictionary dictionaryWithObject:data2 forKey:@"i1"];
    
    
    NSMutableDictionary *data1 = [[NSMutableDictionary alloc] init];
    [data1 setValue:@"" forKey:@"PreShareKey"];
    [data1 setValue:@""  forKey:@"ModeEnabled"];
    [data1 setValue:@""  forKey:@"ModeSupported"];
    NSMutableDictionary *data1_1 = [[NSMutableDictionary alloc] init];
    [data1_1 setValue:data1 forKey:@"Security"];
    NSDictionary *ThirdLevel_2 = [NSDictionary dictionaryWithObject:data1_1 forKey:@"i1"];
    
    
    
    
    NSMutableDictionary *data_wifi = [[NSMutableDictionary alloc] init];
    [data_wifi setValue:ThirdLevel forKey:@"SSID"];
    [data_wifi setValue:ThirdLevel_1  forKey:@"Radio"];
    [data_wifi setValue:ThirdLevel_2  forKey:@"AccessPoint"];
    
    NSDictionary *wifiLevel = [NSDictionary dictionaryWithObject:data_wifi forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:wifiLevel forKey:@"Device"];
    return TopLevel;

}

-(NSDictionary*)SystemInfo_WiFiofEntries
{
    NSDictionary *numberLevel = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:@"AccessPointNumberOfEntries"];
    NSDictionary *HostLevel = [NSDictionary dictionaryWithObject:numberLevel forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:HostLevel forKey:@"Device"];
    return TopLevel;
}
-(NSDictionary*)SystemInfo_Host
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:@"" forKey:@"PhysAddress"];
    [data setValue:@"" forKey:@"HostName"];
    [data setValue:@"" forKey:@"X_ZyXEL_HostType"];
    
    NSDictionary *i1Level = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    NSDictionary *HostLevel = [NSDictionary dictionaryWithObject:i1Level forKey:@"Host"];
    NSDictionary *HostsLevel = [NSDictionary dictionaryWithObject:HostLevel forKey:@"Hosts"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:HostsLevel forKey:@"Device"];
    return TopLevel;
 
}
-(NSDictionary*)SystemInfo_HostofEntries
{
    NSDictionary *numberLevel = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:0] forKey:@"HostNumberOfEntries"];
    NSDictionary *HostLevel = [NSDictionary dictionaryWithObject:numberLevel forKey:@"Hosts"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:HostLevel forKey:@"Device"];
    return TopLevel;
}

-(NSDictionary*)CellularWanSetup
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:@"" forKey:@"AccessPointName"];
    [data setValue:@"" forKey:@"PPPAuthenticationProtocol"];
    [data setValue:@"" forKey:@"Username"];
    [data setValue:@"" forKey:@"Password"];
    
    NSDictionary *i1Level = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSDictionary *faceLevel = [NSDictionary dictionaryWithObject:i1Level forKey:@"Interface"];
    NSDictionary *GPPLevel = [NSDictionary dictionaryWithObject:faceLevel forKey:@"X_ZyXEL_3GPP"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:GPPLevel forKey:@"Device"];
    return TopLevel;
}

-(NSDictionary*)WiFiSetup
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:@"" forKey:@"SSID"];
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:@"" forKey:@"TransmitPowerSupported"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"TransmitPower"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"AutoChannelSupported"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"AutoChannelEnable"];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"Channel"];
    NSDictionary *ThirdLevel_1 = [NSDictionary dictionaryWithObject:data2 forKey:@"i1"];

    
    NSMutableDictionary *data1 = [[NSMutableDictionary alloc] init];
    [data1 setValue:@"" forKey:@"PreShareKey"];
    [data1 setValue:@""  forKey:@"ModeEnabled"];
    [data1 setValue:@""  forKey:@"ModeSupported"];
    NSMutableDictionary *data1_1 = [[NSMutableDictionary alloc] init];
    [data1_1 setValue:data1 forKey:@"Security"];
    NSDictionary *ThirdLevel_2 = [NSDictionary dictionaryWithObject:data1_1 forKey:@"i1"];

    

    
    NSMutableDictionary *data_wifi = [[NSMutableDictionary alloc] init];
    [data_wifi setValue:ThirdLevel forKey:@"SSID"];
    [data_wifi setValue:ThirdLevel_1  forKey:@"Radio"];
    [data_wifi setValue:ThirdLevel_2  forKey:@"AccessPoint"];
    
    NSDictionary *wifiLevel = [NSDictionary dictionaryWithObject:data_wifi forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:wifiLevel forKey:@"Device"];
    return TopLevel;
}

-(NSDictionary*)GuestWLAN
{
    

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:[NSNumber numberWithInteger:0] forKey:@"Enable"];
    [data setValue:@"" forKey:@"PreShareKey"];
    [data setValue:@"" forKey:@"SSID"];

    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"X_ZyXEL_GuestAP"];
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:ThirdLevel forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
    return TopLevel;
    
}

-(NSDictionary*)Notify
{
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:[NSNumber numberWithInteger:0] forKey:@"timestamp"];
    [data2 setValue:@"" forKey:@"alert"];    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:data2 forKey:@"aps"];


    NSMutableDictionary *sys_data1 = [[NSMutableDictionary alloc] init];
    [sys_data1 setValue:@"" forKey:@"SystemName"];
    
    NSMutableDictionary * info_data= [[NSMutableDictionary alloc] init];
    [info_data setValue:@"" forKey:@"MagicNum"];
    [info_data setValue:[NSNumber numberWithInteger:0] forKey:@"AppVersion"];
    
    NSMutableDictionary *appinfo_data1 = [[NSMutableDictionary alloc] init];
    [appinfo_data1 setValue:info_data forKey:@"AppInfo"];
    [appinfo_data1 setValue:sys_data1 forKey:@"SystemInfo"];
    [appinfo_data1 setValue:data forKey:@"Notify"];

    
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:appinfo_data1 forKey:@"X_ZyXEL_Ext"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
    return TopLevel;
    
}


/*********************
 * JasonParser
 *********************/
#pragma mark - JasonParser
- (NSDictionary *)JsonPaser:(char *) jas_str{
    //char *transmit = "{\"Device\":{\"X_ZyXEL_Ext\":{\"AppInfo\":{\"MagicNum\":\"Z3704\",\"AppVersion\":num}}}}";
    NSData* data = [[NSData alloc] initWithBytes:jas_str length:strlen(jas_str)];
    
    NSError *error;
    //加载一个NSURL对象
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *JasonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *JasonDevice = [JasonDic objectForKey:@"Device"];
    NSDictionary *JasonX_ZyXEL_Ext = [JasonDevice objectForKey:@"X_ZyXEL_Ext"];
    NSDictionary *JasonAppInfo = [JasonX_ZyXEL_Ext objectForKey:@"AppInfo"];
     
     NSLog(@"%@",[[[JasonDic objectForKey:[DISCOVERY_System_Keys objectAtIndex:0]] objectForKey:[DISCOVERY_System_Keys objectAtIndex:1]] objectForKey:[DISCOVERY_System_Keys objectAtIndex:2]]);
     NSLog(@"%@",[[[JasonDic objectForKey:[DISCOVERY_System_Keys objectAtIndex:0]] objectForKey:[DISCOVERY_System_Keys objectAtIndex:1]] objectForKey:[DISCOVERY_System_Keys objectAtIndex:2]]);
    return JasonAppInfo;

}


- (void)ReadJason:(char*) json_str{
    NSData* data = [[NSData alloc] initWithBytes:json_str length:strlen(json_str)];
    //NSData* jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *JasonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"Error message:%@",error);
    
    NSDictionary *json = (NSDictionary *)JasonDic;


    if (send_tag == 0) {
        self.Devicename = [[[json objectForKey:@"Device"]
                         objectForKey:@"DeviceInfo"]
                        objectForKey:@"ModelName"]
                       ;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"MainViewController" object:nil];
        
    }else if(send_tag == 12)
    {
//        Devide_password = [[[json objectForKey:@"Device"]
//                            objectForKey:@"LANConfigSecurity"]
//                           objectForKey:@"ConfigPassword"];
//        [[NSUserDefaults standardUserDefaults] setObject:Devide_password forKey:@"DeviceKey"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }



    
}

-(void)reloadTable {
    dispatch_async(dispatch_get_main_queue(),^{
        [self.Device_list reloadData];
    });
}

-(void)tablereload
{
    [Device_list reloadData];
    //        [self.Device_list performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    scanningView.hidden = YES;

}


-(void)testPetch:(NSString*) json forDeep:(int) level

{
    NSString* result = @"";
    NSString* prevChar = @"";
    NSUInteger slen = [json length];
    BOOL needrec = NO;
    
    
    NSString* lStr = @"";
    
    for (int i=0; i < slen; i++) {
        NSString* sc = [json substringWithRange:NSMakeRange(i,1)];
        
        if ([sc isEqualToString:@"{"] && (!needrec))
        {
            if ([result length]>0) {
                // delete left and right space
                [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([[result substringWithRange:NSMakeRange(0,1)] isEqualToString:@","])
                {
                    result = [result substringWithRange:NSMakeRange(1,[result length]-1)];
                }
                NSLog(@"add (%d)deep json object :%@ ",level,result);
                result = @"";
            }
            else
            {
                NSLog(@"add (%d)deep json object : object name is null",level);
            }
            
            lStr = [json substringWithRange:NSMakeRange(i+1,slen-i-1)];
            break;
        }
        
        if ([sc isEqualToString:@"["] && (!needrec))
        {
            if ([result length]>0) {
                // delete left and right space
                [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([[result substringWithRange:NSMakeRange(0,1)] isEqualToString:@","])
                {
                    result = [result substringWithRange:NSMakeRange(1,[result length]-1)];
                }
                NSLog(@"add (%d)deep json array : %@",level,result);
                result = @"";
            }
            else
            {
                NSLog(@"add (%d)deep json array : array name is null",level);
            }
            
            lStr = [json substringWithRange:NSMakeRange(i+1,slen-i-1)];
            break;
        }
        
        if ([sc isEqualToString:@"}"] && (!needrec))
        {
            NSLog(@"Add (%d) a member%@",level,result);
            level = level -1;
            result = @"";
            continue;
        }
        
        if ([sc isEqualToString:@"]"] && (!needrec))
        {
            NSLog(@"Add (%d) a array member%@",level,result);
            level = level -1;
            result = @"";
            continue ;
        }
        
        if ([sc isEqualToString:@"\""] && (![prevChar isEqualToString:@"\\"]))
        {
            needrec = !needrec;
        }
        
        result = [result stringByAppendingFormat:@"%@",sc];
        
        prevChar = sc;
        
    }
    
    // Loop
    if (0 < [lStr length])
    {
        [self testPetch:lStr forDeep:level+1];
    }
    
    return ;
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //	bookcount++;
    //	NSLog(@"bookcount = %d",bookcount);
	static NSString *CellIdentifier = @"Cell";
	static NSUInteger const DeviceLabelTag = 2;
    static NSUInteger const DeviceimgTag = 3;
    static NSUInteger const bgimgTag = 4;
	static NSUInteger const chooseTag = 5;

    
    
	
	UILabel *DeivceLabel = nil;
	UIImageView* Deviceimg  = nil;
    UIImageView* bgimg  = nil;
    UIImageView* chooseimg  = nil;
    //Device_list = tableView;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//cell.indentationWidth = 0.0;
        UIImage *tmpImage1 = [UIImage imageNamed:@"list_bg_60.png"];
		bgimg = [[[UIImageView alloc] initWithImage:tmpImage1] autorelease];
        CGRect imageFrame1 = CGRectMake(60, 0, 260, 60);
        //imageFrame.origin = CGPointMake(0, 8);
        bgimg.frame = imageFrame1;
        bgimg.tag = bgimgTag;
        //bookimg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:bgimg];
        
		UIImage *tmpImage = [UIImage imageNamed:@"icon_device_WAH7130_ID.png"];
		Deviceimg = [[[UIImageView alloc] initWithImage:tmpImage] autorelease];
        CGRect imageFrame = CGRectMake(0, 0, 60, 60);//CGRectMake(-340, 8, 50, 65);//CGRectMake(-410, 5, 70, 90)
        //imageFrame.origin = CGPointMake(0, 8);
        Deviceimg.frame = imageFrame;
        Deviceimg.tag = bgimgTag;
        //bookimg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:Deviceimg];
		//cell.icon


		
        DeivceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(80, 15, 300, 30)] autorelease];
		DeivceLabel.tag = DeviceLabelTag;
		DeivceLabel.font = [UIFont boldSystemFontOfSize:20];
		DeivceLabel.numberOfLines = 2;
		DeivceLabel.textColor = [UIColor whiteColor];
		DeivceLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:DeivceLabel];
        

        
        UIImage *tmpImage2 = [UIImage imageNamed:@"icon_check_60.png"];
		chooseimg = [[[UIImageView alloc] initWithImage:tmpImage2] autorelease];
        CGRect imageFrame2 = CGRectMake(270, 0, 35, 60);//CGRectMake(-340, 8, 50, 65);//CGRectMake(-410, 5, 70, 90)
        //imageFrame.origin = CGPointMake(0, 8);
        chooseimg.frame = imageFrame2;
        chooseimg.tag = chooseTag;
        //bookimg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:chooseimg];
		

		
		
    }else
	{
        
		DeivceLabel = (UILabel *)[cell.contentView viewWithTag:DeviceLabelTag];

		Deviceimg  = (UIImageView *)[cell.contentView viewWithTag:DeviceimgTag];
        
        bgimg  = (UIImageView *)[cell.contentView viewWithTag:bgimgTag];
        
        chooseimg  = (UIImageView *)[cell.contentView viewWithTag:chooseTag];

        
		
	}
    // Get the specific store for this row.
    
	
    
    // Set the relevant data for each subview in the cell.
    
    DeivceLabel.text = self.Devicename;

	UIImage *ppImage = [UIImage imageNamed:@"icon_device_WAH7130_ID.png"];
	Deviceimg.image = ppImage;
    
    UIImage *ppImage1 = [UIImage imageNamed:@"list_bg_60.png"];
	bgimg.image = ppImage1;
    
    UIImage *ppImage2 = [UIImage imageNamed:@"icon_check_60.png"];
	chooseimg.image = ppImage2;

    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"isConnected"] isEqualToString:@"YES"]) {
        chooseimg.hidden = NO;
    }
    else
    {
        chooseimg.hidden = YES;
    }
    
    // Configure the cell...
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}




#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView* imageview = [[UIImageView alloc] init];
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"isConnected"] isEqualToString:@"YES"]) {
        UIView* subview = [[cell1.contentView subviews] lastObject];
        if ([subview isKindOfClass:[UIImageView class]]) {
            imageview = (UIImageView*)subview;
            imageview.hidden = NO;

            [self.slidingViewController anchorTopViewTo:ECRight];
        }
    }else{
        [self connect_Device];
        UIView* subview = [[cell1.contentView subviews] lastObject];
        if ([subview isKindOfClass:[UIImageView class]]) {
            imageview = (UIImageView*)subview;
            imageview.hidden = YES;
        }
    }

	
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing %@",textField.text);
    NSError* error;
    if ([textField.text isEqual:Devide_password])
    {
        [connection disconnect];
        [connection release];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isConnected"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.slidingViewController anchorTopViewTo:ECRight];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isConnected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                          message:@"Password is Error."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        
        [broadcastSocket enableBroadcast:NO error:&error];
        [connection disconnect];
        [connection release];
        [self sendBroadcastUDP];
        send_tag = 0;

    }

}

-(void)connect_Device
{
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Connect Device" message:@"\n\n\n"
                                                           delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
    passwordLabel.font = [UIFont systemFontOfSize:16];
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.shadowColor = [UIColor blackColor];
    passwordLabel.shadowOffset = CGSizeMake(0,-1);
    passwordLabel.textAlignment = UITextAlignmentCenter;
    passwordLabel.text = @"";
    [passwordAlert addSubview:passwordLabel];
    
    UIImageView *passwordImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"passwordfield" ofType:@"png"]]];
    passwordImage.frame = CGRectMake(11,79,262,31);
    [passwordAlert addSubview:passwordImage];
    
    
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,83,252,25)];
    passwordField.font = [UIFont systemFontOfSize:18];
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.secureTextEntry = YES;
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.delegate = self;
    [passwordField becomeFirstResponder];
    [passwordAlert addSubview:passwordField];
    
    //[passwordAlert setTransform:CGAffineTransformMakeTranslation(0,0)];
    [passwordAlert show];
    [passwordAlert release];
    [passwordField release];
    [passwordImage release];
    [passwordLabel release];

}
@end
