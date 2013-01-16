//
//  InfoViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/19.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
@synthesize menuItems,broadcastSocket,header,connection,infocontent;
@synthesize Signal;
@synthesize wifiSignal;
@synthesize battery;
@synthesize CelluarMode;
@synthesize serviceProvider;
@synthesize Devicename;

@synthesize allbar;
@synthesize sendbar;
@synthesize recbar;
@synthesize current_usage;
@synthesize Quota;
@synthesize Send_data;
@synthesize Receviv_data;
@synthesize Usage_Advice;
@synthesize Reset_Date;
@synthesize Reset_count;


@synthesize wifiname;
@synthesize channel;

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
    infocontent.contentSize =  CGSizeMake(320, 700);
    Devide_password = [[NSUserDefaults standardUserDefaults] stringForKey:@"DevicePassword"];
    header=[ZyXELAPPLib new];
    
    [self sendTCPData:msgType_ParameterGetReq sendtag:0];
    send_tag = 0;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}


- (void)Notifi_ViewControllerDidFinish:(Notifi_ViewController *)controller
{
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)Clientlist_ViewControllerDidFinish:(Clientlist_ViewController *)controller
{
    
    [self dismissModalViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([[segue identifier] isEqualToString:@"Notification"]) {
        [[segue destinationViewController] setDelegate:self];
    }
    if ([[segue identifier] isEqualToString:@"Clienlist"]) {
        [[segue destinationViewController] setDelegate:self];
    }

}

/*********************
 * TCP SOCKET
 *********************/
#pragma mark - TCP SOCKET
-(void) sendTCPData:(int)sendtype sendtag:(long)tmptag
{
    connection = [[AsyncSocket alloc] initWithDelegate:self];
    [connection setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    NSError *err;
    if (![connection connectToHost:routerHost onPort:263 error:&err]) {
        NSLog(@" %@",[err localizedDescription]);
        
        return;
    }
    int len,passwordLen,msgLen;
    char *psztmp;
    char type,version;
    int payloadSize;
    NSData *jsonData;
    const char *transmit;
    if (tmptag == 0) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_Battery_lite]
                                                           options:0
                                                             error:&err];

    }else if (tmptag == 1)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_3GPP]
                                                           options:NSJSONReadingMutableLeaves
                                                             error:&err];
    }else if (tmptag == 2)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_WiFilite]
                                                   options:0
                                                     error:&err];
    }else if (tmptag == 3)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_Host]
                                                   options:0
                                                     error:&err];
    }
    transmit = [jsonData bytes];

    //len=strlen(transmit);
    len=[jsonData length];
    

    memset(_encodeData,0,sizeof(_encodeData));
    memcpy(_encodeData+4,transmit,len);
    msgLen=len+4;
    
    
    const char *pwddata = [Devide_password UTF8String];
    passwordLen=[Devide_password length];

    
    int backheader = [header msgEncodeType:sendtype msgData:_encodeData msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];

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
    NSLog(@"Disconnect");
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
    if (tag ==0) {
        [connection disconnect];
        [connection release];
        [self sendTCPData:msgType_ParameterGetReq sendtag:1];
        send_tag = 1;
    }
    else if (tag ==1) {
        [connection disconnect];
        [connection release];
        [self sendTCPData:msgType_ParameterGetReq sendtag:2];
        send_tag = 2;
    }else if (tag ==2)
    {
        [connection disconnect];
        [connection release];
        [self sendTCPData:msgType_ParameterGetReq sendtag:3];
        send_tag = 3;
    }else
    {
    //[connection readDataWithTimeout:-1 tag:0];
        [connection disconnect];
        [connection release];
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

    const char *pwddata = [Devide_password UTF8String];
    passwordLen=[Devide_password length];
    //char* newStr = [data bytes];
    
    
    
    //len =[tmp_ch length];
    
    memset(_decodeDate,0,sizeof(_decodeDate));
    
    
    memcpy(&version,tmp_ch,1);
    memcpy(&type,tmp_ch+1,1);
    payloadSize=0;
    memcpy(&payloadSize,tmp_ch+2,2);
    len = payloadSize;
    msgLen=len+4;
    char lsb = tmp_ch[2];
    char msb = tmp_ch[3];
    int value = (msb << 8) + lsb;
    if(payloadSize>65500) return @"";

    memcpy(_decodeDate,tmp_ch,msgLen);
    
    typeReq=0;
    ptypeReq=&typeReq;
    
    [header msgDecodeType:ptypeReq msgData:_decodeDate msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];
    psztmp=_decodeDate+4;
    NSString *Decode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d decode msg:%s",version,type,payloadSize,psztmp];

    return psztmp;}

- (void)ReadJason:(char*) json_str{
    
    NSData* data = [[NSData alloc] initWithBytes:json_str length:strlen(json_str)];
    //NSData* jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *JasonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"Error message:%@",error);
    NSArray *keys = [JasonDic allKeys];

    NSDictionary *json = (NSDictionary *)JasonDic;
    //IBOutlet UIImageView* wifiSignal;

    



    if (send_tag == 0) {
        ;
        NSString* imgname =[NSString stringWithFormat:@"icon_battery_lev%d.png",[[[[[json objectForKey:@"Device"]
                                                                                     objectForKey:@"X_ZyXEL_Ext"]
                                                                                    objectForKey:@"BatteryStatus"]
                                                                                   objectForKey:@"RemainCapacity"] intValue]+1];
        battery.image = [UIImage imageNamed:imgname];
        
    }else if(send_tag == 1)
    {
        NSString* imgname =[NSString stringWithFormat:@"icon_tel_lev%d.png",[[[[[[json objectForKey:@"Device"]
                                                                                    objectForKey:@"X_ZyXEL_3GPP"]
                                                                                   objectForKey:@"Interface"]
                                                                                  objectForKey:@"i1"]
                                                                                 objectForKey:@"SignalStrength"] intValue]/2];
        Signal.image = [UIImage imageNamed:imgname];
        
        CelluarMode.text = [[[[[json objectForKey:@"Device"]
                               objectForKey:@"X_ZyXEL_3GPP"]
                              objectForKey:@"Interface"]
                             objectForKey:@"i1"]
                            objectForKey:@"CellularMode"];
        serviceProvider.text = [[[[[json objectForKey:@"Device"]
                                   objectForKey:@"X_ZyXEL_3GPP"]
                                  objectForKey:@"Interface"]
                                 objectForKey:@"i1"]
                                objectForKey:@"ServiceProvider"];
        int send_data_num = [[[[[[[json objectForKey:@"Device"]
                                  objectForKey:@"X_ZyXEL_3GPP"]
                                 objectForKey:@"Interface"]
                                objectForKey:@"i1"]
                               objectForKey:@"Stats"]
                              objectForKey:@"BytesSent"]intValue];
        int Rec_data_num = [[[[[[[json objectForKey:@"Device"]
                                objectForKey:@"X_ZyXEL_3GPP"]
                               objectForKey:@"Interface"]
                              objectForKey:@"i1"]
                             objectForKey:@"Stats"]
                            objectForKey:@"BytesReceived"]intValue];
        
        NSString* Send_data_mb =[NSString stringWithFormat:@"%d MB", send_data_num];
        Send_data.text= Send_data_mb;


        

        
        NSString* Receviv_data_mb =[NSString stringWithFormat:@"%d MB",Rec_data_num];

        
        NSString* timestmp = [[[[[[[json objectForKey:@"Device"]
                                   objectForKey:@"X_ZyXEL_3GPP"]
                                  objectForKey:@"Interface"]
                                 objectForKey:@"i1"]
                                objectForKey:@"Stats"]
                               objectForKey:@"DataPlanManagement"]
                              objectForKey:@"LastResetDate"];
        NSString* YearMonth = [timestmp substringToIndex:7];
        NSString* day = [timestmp substringFromIndex:8];
        
        double timeInterval = [day doubleValue];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeInterval];//dateWithTimeIntervalSinceReferenceDate dateWithTimeIntervalSince1970
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];//@"yyyy-MM-dd HH:mm:ss zzz"
        
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        Reset_Date.text= dateString;
        NSString* recommday = [dateString substringFromIndex:8];
        
        int count = [[[[[[[[json objectForKey:@"Device"]
                          objectForKey:@"X_ZyXEL_3GPP"]
                         objectForKey:@"Interface"]
                        objectForKey:@"i1"]
                       objectForKey:@"Stats"]
                      objectForKey:@"DataPlanManagement"]
                     objectForKey:@"ResetCounter"] intValue];
        Reset_count.text=[NSString stringWithFormat:@"%d",count];
        
        int Quota_num = [[[[[[[[json objectForKey:@"Device"]
                               objectForKey:@"X_ZyXEL_3GPP"]
                              objectForKey:@"Interface"]
                             objectForKey:@"i1"] objectForKey:@"Stats"]
                           objectForKey:@"DataPlanManagement"] objectForKey:@"MonthlyLimit"]intValue];
        
        NSString* limitQuota =[NSString stringWithFormat:@"%d",Quota_num];
        
        Quota.text =[NSString stringWithFormat:@"Quota:%@MB",limitQuota];
        
        int total_data = [[[[[[[json objectForKey:@"Device"]
                               objectForKey:@"X_ZyXEL_3GPP"]
                              objectForKey:@"Interface"]
                             objectForKey:@"i1"]
                            objectForKey:@"Stats"]
                           objectForKey:@"BytesReceived"]intValue] +[[[[[[[json objectForKey:@"Device"]
                                                                          objectForKey:@"X_ZyXEL_3GPP"]
                                                                         objectForKey:@"Interface"]
                                                                        objectForKey:@"i1"]
                                                                       objectForKey:@"Stats"]
                                                                      objectForKey:@"BytesSent"]intValue];
        int totla_per = total_data/[[[[[[[[json objectForKey:@"Device"]
                                          objectForKey:@"X_ZyXEL_3GPP"]
                                         objectForKey:@"Interface"]
                                        objectForKey:@"i1"] objectForKey:@"Stats"]
                                      objectForKey:@"DataPlanManagement"] objectForKey:@"MonthlyResetDay"]intValue] *100;
        current_usage.text = [NSString stringWithFormat:@"Current Usage: %d",totla_per];
        
        int sent_bar_length =send_data_num*250/Quota_num;
        int Rec_bar_length =Rec_data_num*250/Quota_num;
        sendbar.contentMode = UIViewContentModeScaleAspectFit;
        CGRect  sendframe = CGRectMake(34.0f, 213.0f,sent_bar_length,25 );
        sendbar.frame = sendframe;
        
        Receviv_data.text= Receviv_data_mb;
        CGRect Recframe;
        if (sent_bar_length+34 >250) {
             Recframe = CGRectMake(34.0f+sent_bar_length, 64.0f,0,25 );
        }else{
             Recframe = CGRectMake(34.0f+sent_bar_length, 64.0f,Rec_bar_length,25 );
        }
        [recbar setFrame:Recframe];
        float advice_num = (Quota_num-(send_data_num+Rec_data_num))/[self DateRecomm:[recommday intValue]];
        Usage_Advice.text= [NSString stringWithFormat:@"%4.2f MB",advice_num];
        
    }else if(send_tag == 2)
    {
        wifiname.text = [[[[[json objectForKey:@"Device"]
                           objectForKey:@"WiFi"]
                          objectForKey:@"SSID"]
                         objectForKey:@"i1"]
                            objectForKey:@"SSID"];
        int channel_num = [[[[[[json objectForKey:@"Device"]
                               objectForKey:@"WiFi"]
                              objectForKey:@"Radio"]
                             objectForKey:@"i1"]
                            objectForKey:@"Channel"] intValue];
        if (channel_num != 0) {
            channel.text = [NSString stringWithFormat:@"%d",channel_num];
        }else{
            channel.text = @"Auto";
        }
        
    }else if(send_tag == 3)
    {
        Devicename.text = [[[[[json objectForKey:@"Device"]
                              objectForKey:@"Hosts"]
                             objectForKey:@"Host"]
                            objectForKey:@"i1"]
                           objectForKey:@"HostName"];

    }
        
    
}


/*********************
 * PARAMETER Json
 *********************/
#pragma mark - PARAMETER Json
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

-(NSDictionary*)SystemInfo_Battery_lite
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
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

-(NSDictionary*)SystemInfo_WiFilite
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:@"" forKey:@"SSID"];
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"Channel"];
    NSDictionary *ThirdLevel_1 = [NSDictionary dictionaryWithObject:data2 forKey:@"i1"];
    
    NSMutableDictionary *data_wifi = [[NSMutableDictionary alloc] init];
    [data_wifi setValue:ThirdLevel forKey:@"SSID"];
    [data_wifi setValue:ThirdLevel_1  forKey:@"Radio"];
    
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

-(int)DateRecomm:(int)resetday
{

    
    //取得日期與時間的各項整數型資料

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    int day = [comps day];
    
    if(day>resetday)
        return day - resetday;
    else
        return resetday - day;
}

//unsigned long long unistrlen(unichar *chars)
//{
//    unsigned long long length = 0llu;
//    if(NULL == chars) return length;
//    
//    while(NULL != chars[length])
//        length++;
//    
//    return length;
//}

@end
