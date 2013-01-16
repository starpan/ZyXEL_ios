//
//  Guest_WifiViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/19.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "Guest_WifiViewController.h"
#import "Message_Define.h"

@interface Guest_WifiViewController ()

@end

@implementation Guest_WifiViewController
@synthesize Wifipwd,Wifiname,Devicename;
@synthesize b_change,b_open;
@synthesize header,connection,broadcastSocket;

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
    Devicename.text = @"";
    Wifiname.text = @"";
    Wifipwd.text = @"";
    Devide_password = [[NSUserDefaults standardUserDefaults] stringForKey:@"DevicePassword"];
    header=[ZyXELAPPLib new];
    

    [self sendTCPData:msgType_ParameterGetReq sendtag:0];
    send_tag = 0;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revealMenu:(id)sender
{
    [connection disconnect];
    [connection release];
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)changewifiPwd:(id)sender
{
    UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"\n\n\n"
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
- (IBAction)openwifi:(id)sender
{
    if (open_status) {
        open_status = 0;
        [connection disconnect];
        [connection release];
        [self sendTCPData:msgType_ParameterSetReq sendtag:1];
        send_tag = 1;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                          message:@"Guest Wi-Fi is Closed."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }else{
        open_status = 1;
        [connection disconnect];
        [connection release];
        [self sendTCPData:msgType_ParameterSetReq sendtag:2];
        send_tag = 2;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                          message:@"Guest Wi-Fi is Opened."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing %@",textField.text);
    if (!textField.text) {
        return;
    }
    Wifipwd.text = textField.text;
    [self sendTCPData:msgType_ParameterSetReq sendtag:3];
    send_tag = 3;
}

-(NSDictionary*)GuestWLAN
{
    
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:[NSNumber numberWithInteger:open_status] forKey:@"Enable"];
    [data setValue:Wifipwd.text forKey:@"PreShareKey"];
    [data setValue:Wifiname.text  forKey:@"SSID"];
    
    NSDictionary *ThirdLevel = [NSDictionary dictionaryWithObject:data forKey:@"X_ZyXEL_GuestAP"];
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:ThirdLevel forKey:@"WiFi"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
    return TopLevel;
    
}

-(void)wifi_status:(int) open
{
    if (open) {
        Wifiname.hidden = NO;
        Wifipwd.hidden =NO;
        b_change.enabled = YES;
        [b_open setImage:[UIImage imageNamed:@"btn_power_on_1.png"] forState:UIControlStateNormal];
        [b_open setImage:[UIImage imageNamed:@"btn_power_on_2.png"] forState:UIControlStateHighlighted];
    }else
    {
        Wifiname.hidden = YES;
        Wifipwd.hidden =YES;
        b_change.enabled = NO;
        [b_open setImage:[UIImage imageNamed:@"btn_power_off_1.png"] forState:UIControlStateNormal];
        [b_open setImage:[UIImage imageNamed:@"btn_power_off_2.png"] forState:UIControlStateHighlighted];
    }
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //cancel clicked ...do your action
    }else if (buttonIndex == 1){
        //reset clicked
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
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self GuestWLAN]
                                                       options:0
                                                         error:&err];
    const char *transmit = [jsonData bytes];
    len = [jsonData length];
    //len=strlen(transmit);

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
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"wants runloop for new socket.");
    return [NSRunLoop currentRunLoop];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected host = %@  port = %d",host,port);
    [connection readDataWithTimeout:-1 tag:send_tag];
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"willDisconnectWithError(错误):%p    %@",sock,err);
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"warning!"
                                                      message:@"Please check your Wi-Fi setting if Wi-Fi is disconnected."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
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
    int len,passwordLen,msgLen;
    char *psztmp;
    char type,version;
    int payloadSize;
    
    
    len=strlen(tmp_ch);

    memset(_encodeData,0,sizeof(_encodeData));
    memcpy(_encodeData+4,tmp_ch,len);
    msgLen=len+4;
    
    
    const char *pwddata = [Devide_password UTF8String];
    passwordLen=[Devide_password length];

    
    int backheader = [header msgEncodeType:msgType_SystemQueryReq msgData:_encodeData msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];

    psztmp=_encodeData+4;
    
    memcpy(&version,_encodeData,1);
    memcpy(&type,_encodeData+1,1);
    payloadSize=0;
    memcpy(&payloadSize,_encodeData+2,2);
    NSString *Encode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d encode msg:%s",version,type,payloadSize,psztmp];
    NSLog(@"Tcp Encode str = %@",Encode_str);
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
    NSLog(@"guest wifi error %d",tmp_ch[2]);
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
    NSArray *keys = [JasonDic allKeys];
    
    if (JasonDic != nil && error == nil){
        NSLog(@"Successfully deserialized...");
        if ([JasonDic isKindOfClass:[NSDictionary class]]){
            NSDictionary *deserializedDictionary = (NSDictionary *)JasonDic;
            NSLog(@"Dersialized JSON Dictionary = %@", deserializedDictionary);
        } else if ([JasonDic isKindOfClass:[NSArray class]]){
            NSArray *deserializedArray = (NSArray *)JasonDic;
            NSLog(@"Dersialized JSON Array = %@", deserializedArray);
        } else {
            NSLog(@"An error happened while deserializing the JSON data.");
        }
        
    }
    NSDictionary *json = (NSDictionary *)JasonDic;
    // values in foreach loop
    for (NSString *key in keys) {
        NSDictionary *deserializedDictionary = (NSDictionary *)JasonDic;
        keys = [deserializedDictionary allKeys];
    }
    

    Wifipwd.text = [[[[json objectForKey:[Guest_WLAN_Keys objectAtIndex:0]]
                      objectForKey:[Guest_WLAN_Keys objectAtIndex:1]]
                     objectForKey:[Guest_WLAN_Keys objectAtIndex:2]]
                    objectForKey:[Guest_WLAN_Keys objectAtIndex:3]];
    
    Wifiname.text = [[[[json objectForKey:[Guest_WLAN_Keys objectAtIndex:0]]
                       objectForKey:[Guest_WLAN_Keys objectAtIndex:1]]
                      objectForKey:[Guest_WLAN_Keys objectAtIndex:2]]
                     objectForKey:[Guest_WLAN_Keys objectAtIndex:4]];
    
    open_status = [[[[[json objectForKey:[Guest_WLAN_Keys objectAtIndex:0]]
                    objectForKey:[Guest_WLAN_Keys objectAtIndex:1]]
                   objectForKey:[Guest_WLAN_Keys objectAtIndex:2]]
                  objectForKey:[Guest_WLAN_Keys objectAtIndex:5]]intValue];

            [self wifi_status:open_status];
    

    
    
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


@end
