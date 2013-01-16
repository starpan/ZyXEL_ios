//
//  S_WiFiViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/22.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "S_WiFiViewController.h"

@interface S_WiFiViewController ()

@end

@implementation S_WiFiViewController

@synthesize menuItems,header,content,connection,broadcastSocket;
@synthesize Wifiname;
@synthesize b_channel;
@synthesize power;
@synthesize Wifisecurity;
@synthesize Wifipwd;

@synthesize GuestWifiname;
@synthesize open;
@synthesize GuestWifipwd;
@synthesize wifi_wait;

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
    content.contentSize =  CGSizeMake(320, 650);
    auto_channel = 1;
    Devide_password = [[NSUserDefaults standardUserDefaults] stringForKey:@"DevicePassword"];
	// Do any additional setup after loading the view.
    channelPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 280, 320, 200)];
    channelPickerView.delegate = self;
    channelPickerView.tag = 0;
    channelPickerView.showsSelectionIndicator = YES;
    [self.view addSubview:channelPickerView];
    channelPickerView.hidden = YES;
    
    SecurityPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 280, 320, 200)];
    SecurityPickerView.delegate = self;
    SecurityPickerView.tag =1;
    SecurityPickerView.showsSelectionIndicator = YES;
    [self.view addSubview:SecurityPickerView];
    SecurityPickerView.hidden = YES;

 
    
    arraychannel = [[NSMutableArray alloc] init];
    [arraychannel addObject:@"Auto"];
    [arraychannel addObject:@"1"];
    [arraychannel addObject:@"2"];
    [arraychannel addObject:@"3"];
    [arraychannel addObject:@"4"];
    [arraychannel addObject:@"5"];
    [arraychannel addObject:@"6"];
    [arraychannel addObject:@"8"];
    [arraychannel addObject:@"9"];
    [arraychannel addObject:@"10"];
    [arraychannel addObject:@"11"];
    
    arraySecu = [[NSMutableArray alloc] init];
    [arraySecu addObject:@"None"];
    [arraySecu addObject:@"WPA"];
    [arraySecu addObject:@"WPA2-Personal"];



    power.selectedSegmentIndex = 0;
    
    //設定所觸發的事件條件與對應事件
    [power addTarget:self action:@selector(Powerchange:) forControlEvents:UIControlEventValueChanged];
    
    
    header=[ZyXELAPPLib new];
    
    send_tag = 0;
    [self sendTCPData:msgType_ParameterGetReq sendtag:0];
    
    wifi_wait.hidden =YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)back:(id)sender
{

    [self.delegate S_WiFiViewControllerDidFinish:self];
}

- (IBAction)Save:(id)sender
{
    wifi_wait.hidden =NO;
    send_tag = 4;
    [self sendTCPData:msgType_ParameterSetReq sendtag:4];

}

- (IBAction)channel_choose:(id)sender
{
    channelPickerView.hidden = NO;
}

- (IBAction)Security_choose:(id)sender
{
    SecurityPickerView.hidden = NO;

}

- (void)Powerchange:(id)sender
{
    NSLog(@"%@", [sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]);
}

#pragma mark -
#pragma mark PickerView DataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    if (pickerView.tag == 0) {
        [b_channel setTitle:[arraychannel objectAtIndex:row] forState:UIControlStateNormal];
        [b_channel setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        if (row!=0) {
            auto_channel = 0;
        }
        
    }else
    {
        [Wifisecurity setTitle:[arraySecu objectAtIndex:row] forState:UIControlStateNormal];
        [Wifisecurity setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        //Wifisecurity.titleLabel.text = [arraySecu objectAtIndex:row];
    }
    
    SecurityPickerView.hidden = YES;
    channelPickerView.hidden = YES;

   
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    if (pickerView.tag == 0) {
        return [arraychannel count];
    }else
        return [arraySecu count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    if (pickerView.tag == 0) {
        return [arraychannel objectAtIndex:row];
    }else
        return [arraySecu objectAtIndex:row];
    
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGRect oldframe = content.bounds;
    content.frame =  CGRectMake(oldframe.origin.x, -60, oldframe.size.width, oldframe.size.height);
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
}
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSLog(@"textField:shouldChangeCharactersInRange:replacementString:");
//    if ([string isEqualToString:@"#"]) {
//        return NO;
//    }
//    else {
//        return YES;
//    }
//}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag == 1) {
        NSLog(@"1:");
    }else if (textField.tag == 2)
    {
        NSLog(@"2:");
    }else if (textField.tag == 3){
        NSLog(@"3:");
    }
    
    if (textField.tag == 1) {
        UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:2];
        [passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    CGRect oldframe = content.bounds;
    content.frame =  CGRectMake(oldframe.origin.x, 44, oldframe.size.width, oldframe.size.height);
    return YES;
}
/*********************
 * PARAMETER Json
 *********************/
#pragma mark - PARAMETER Json
-(NSDictionary*)WiFiGet
{

    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:Wifiname.text forKey:@"SSID"];
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:@"" forKey:@"TransmitPowerSupported"];
    [data2 setValue:[NSNumber numberWithInteger:power.selectedSegmentIndex]  forKey:@"TransmitPower"];
    //[data2 setValue:[NSNumber numberWithInteger:1]  forKey:@"AutoChannelSupported"];
    [data2 setValue:[NSNumber numberWithInteger:auto_channel]  forKey:@"AutoChannelEnable"];
    if (auto_channel) {
        [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"Channel"];
    }else
    {
        [data2 setValue:[NSNumber numberWithInteger:[b_channel.titleLabel.text intValue]]  forKey:@"Channel"];
    }
    NSDictionary *ThirdLevel_1 = [NSDictionary dictionaryWithObject:data2 forKey:@"i1"];
    
    
    NSMutableDictionary *data1 = [[NSMutableDictionary alloc] init];
    [data1 setValue:Wifipwd.text forKey:@"PreShareKey"];
//    if ([Wifisecurity.titleLabel.text isEqualToString:@"None"]) {
//        [data1 setValue:@"0"  forKey:@"ModeEnabled"];
//    }else{
//        [data1 setValue:@"1"  forKey:@"ModeEnabled"];
//    }
    [data1 setValue:Wifisecurity.titleLabel.text  forKey:@"ModeEnabled"];
    NSMutableDictionary *data1_1 = [[NSMutableDictionary alloc] init];
    [data1_1 setValue:data1 forKey:@"Security"];
    NSDictionary *ThirdLevel_2 = [NSDictionary dictionaryWithObject:data1_1 forKey:@"i1"];
    
    NSMutableDictionary *dataguest = [[NSMutableDictionary alloc] init];
    if (open.on) {
        [dataguest setValue:[NSNumber numberWithInteger:1] forKey:@"Enable"];
    }else{
        [dataguest setValue:[NSNumber numberWithInteger:0] forKey:@"Enable"];
    }
    [dataguest setValue:GuestWifipwd.text forKey:@"PreShareKey"];
    [dataguest setValue:GuestWifiname.text forKey:@"SSID"];
    
    
    NSMutableDictionary *data_wifi = [[NSMutableDictionary alloc] init];
    [data_wifi setValue:ThirdLevel forKey:@"SSID"];
    [data_wifi setValue:ThirdLevel_1  forKey:@"Radio"];
    [data_wifi setValue:ThirdLevel_2  forKey:@"AccessPoint"];
    //[data_wifi setValue:dataguest  forKey:@"X_ZyXEL_GuestAP"];
    
    
    NSDictionary *wifiLevel = [NSDictionary dictionaryWithObject:data_wifi forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:wifiLevel forKey:@"Device"];
    return TopLevel;
}

-(NSDictionary*)GuestWLAN
{
    
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    if (open.on) {
        [data setValue:[NSNumber numberWithInteger:1] forKey:@"Enable"];
    }else{
        [data setValue:[NSNumber numberWithInteger:0] forKey:@"Enable"];
    }
    [data setValue:GuestWifipwd.text forKey:@"PreShareKey"];
    [data setValue:GuestWifiname.text  forKey:@"SSID"];
    
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"X_ZyXEL_GuestAP"];
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:ThirdLevel forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
    return TopLevel;
    
}

-(NSDictionary*)WiFiSetup
{
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:Wifiname.text forKey:@"SSID"];
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:@"" forKey:@"TransmitPowerSupported"];
    [data2 setValue:[NSNumber numberWithInteger:power.selectedSegmentIndex]  forKey:@"TransmitPower"];
    //[data2 setValue:[NSNumber numberWithInteger:1]  forKey:@"AutoChannelSupported"];
    [data2 setValue:[NSNumber numberWithInteger:auto_channel]  forKey:@"AutoChannelEnable"];
    if (auto_channel) {
        [data2 setValue:[NSNumber numberWithInteger:0]  forKey:@"Channel"];
    }else
    {
        [data2 setValue:[NSNumber numberWithInteger:[b_channel.titleLabel.text intValue]]  forKey:@"Channel"];
    }
    NSDictionary *ThirdLevel_1 = [NSDictionary dictionaryWithObject:data2 forKey:@"i1"];
    
    
    NSMutableDictionary *data1 = [[NSMutableDictionary alloc] init];
    [data1 setValue:Wifipwd.text forKey:@"PreShareKey"];
    //    if ([Wifisecurity.titleLabel.text isEqualToString:@"None"]) {
    //        [data1 setValue:@"0"  forKey:@"ModeEnabled"];
    //    }else{
    //        [data1 setValue:@"1"  forKey:@"ModeEnabled"];
    //    }
    [data1 setValue:Wifisecurity.titleLabel.text  forKey:@"ModeEnabled"];
    NSMutableDictionary *data1_1 = [[NSMutableDictionary alloc] init];
    [data1_1 setValue:data1 forKey:@"Security"];
    NSDictionary *ThirdLevel_2 = [NSDictionary dictionaryWithObject:data1_1 forKey:@"i1"];
    
    NSMutableDictionary *dataguest = [[NSMutableDictionary alloc] init];
    if (open.on) {
        [dataguest setValue:[NSNumber numberWithInteger:1] forKey:@"Enable"];
    }else{
        [dataguest setValue:[NSNumber numberWithInteger:0] forKey:@"Enable"];
    }
    [dataguest setValue:GuestWifipwd.text forKey:@"PreShareKey"];
    [dataguest setValue:GuestWifiname.text forKey:@"SSID"];
    
    
    NSMutableDictionary *data_wifi = [[NSMutableDictionary alloc] init];
    [data_wifi setValue:ThirdLevel forKey:@"SSID"];
    [data_wifi setValue:ThirdLevel_1  forKey:@"Radio"];
    [data_wifi setValue:ThirdLevel_2  forKey:@"AccessPoint"];
    [data_wifi setValue:dataguest  forKey:@"X_ZyXEL_GuestAP"];
    
    
    NSDictionary *wifiLevel = [NSDictionary dictionaryWithObject:data_wifi forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:wifiLevel forKey:@"Device"];
    return TopLevel;
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
    if (tmptag == 0 ) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self WiFiGet]
                                                   options:0
                                                     error:&err];

    }else if(tmptag == 1 ) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self GuestWLAN]
                                                   options:0
                                                     error:&err];
    //}
    }else if(tmptag == 4) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self WiFiSetup]
                                                   options:0
                                                     error:&err];
    }

    
     const char *transmit= [jsonData bytes];
    len = [jsonData length];
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
    connection = nil;
}
- (void)onSocketDidSecure:(AsyncSocket *)sock{
    
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag

{
    
    NSLog(@"thread(%@),onSocket:%p didWriteDataWithTag:%ld",[[NSThread currentThread] name],
          
          sock,tag);
    wifi_wait.hidden =YES;
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                      message:@"Setting is saved."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
}

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    [self ReadJason:[self Decode_Str:[data bytes]]];
    if (send_tag == 0) {
        [connection disconnect];
        [connection release];
        send_tag = 1;
        [self sendTCPData:msgType_ParameterGetReq sendtag:1];
        
    }
    else if (send_tag == 4) {
        [connection disconnect];
        [connection release];
        
//        [self sendTCPData:msgType_ParameterSetReq sendtag:5];
//        send_tag = 5;

    }else{

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
    
    NSLog(@"wifi error code %d",tmp_ch[2]);
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

- (void)ReadJason:(char*) json_str{
    
    NSData* data = [[NSData alloc] initWithBytes:json_str length:strlen(json_str)];
    //NSData* jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *JasonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *keys = [JasonDic allKeys];

    NSDictionary *json = (NSDictionary *)JasonDic;
    int enable_oepn;
    // values in foreach loop
    

    if (send_tag == 0 || send_tag == 4) {
        Wifiname.text = [[[[[json objectForKey:@"Device"]
                            objectForKey:@"WiFi"]
                           objectForKey:@"SSID"]
                          objectForKey:@"i1"]
                         objectForKey:@"SSID"];
        
        NSString* security_s = [[[[[[json objectForKey:@"Device"]
                                    objectForKey:@"WiFi"]
                                   objectForKey:@"AccessPoint"]
                                  objectForKey:@"i1"]
                                 objectForKey:@"Security"]
                                objectForKey:@"ModeEnabled"];

        [Wifisecurity setTitle:security_s forState:UIControlStateNormal];
        [Wifisecurity setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        //Wifisecurity.titleLabel.text = security_s;
        
        NSLog(@"wifi channel is %d",[[[[[[json objectForKey:@"Device"]
                                       objectForKey:@"WiFi"]
                                      objectForKey:@"Radio"]
                                     objectForKey:@"i1"]
                                    objectForKey:@"Channel"] intValue]);
        int channel_num = [[[[[[json objectForKey:@"Device"]
                               objectForKey:@"WiFi"]
                              objectForKey:@"Radio"]
                             objectForKey:@"i1"]
                            objectForKey:@"Channel"] intValue];
        if(channel_num != 0)
        {
            b_channel.titleLabel.text = [NSString stringWithFormat:@"%d",channel_num];
        }else
        {
            b_channel.titleLabel.text = @"Auto";
        }
        
        
        Wifipwd.text = [[[[[[json objectForKey:@"Device"]
                           objectForKey:@"WiFi"]
                          objectForKey:@"AccessPoint"]
                         objectForKey:@"i1"]
                        objectForKey:@"Security"]
                        objectForKey:@"PreShareKey"];
        
        power.selectedSegmentIndex = [[[[[[json objectForKey:@"Device"]
                                          objectForKey:@"WiFi"]
                                         objectForKey:@"Radio"]
                                        objectForKey:@"i1"]
                                       objectForKey:@"TransmitPower"] intValue];
        
        auto_channel =[[[[[[json objectForKey:@"Device"]
                           objectForKey:@"WiFi"]
                          objectForKey:@"Radio"]
                         objectForKey:@"i1"]
                        objectForKey:@"AutoChannelEnable"] intValue];
        
    }
//
    if (send_tag == 1 || send_tag == 5) {
        GuestWifiname.text = [[[[json objectForKey:@"Device"]
                            objectForKey:@"WiFi"]
                           objectForKey:@"X_ZyXEL_GuestAP"]
                          objectForKey:@"SSID"];
        
        enable_oepn = [[[[[json objectForKey:@"Device"]
                         objectForKey:@"WiFi"]
                        objectForKey:@"X_ZyXEL_GuestAP"]
                       objectForKey:@"Enable"] integerValue];

        if (enable_oepn) {
            open.on = YES;
        }else
            open.on = NO;
        GuestWifipwd.text = [[[[json objectForKey:@"Device"]
                               objectForKey:@"WiFi"]
                              objectForKey:@"X_ZyXEL_GuestAP"]
                             objectForKey:@"PreShareKey"];
    }

    
}



@end
