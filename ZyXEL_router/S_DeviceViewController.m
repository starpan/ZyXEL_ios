//
//  S_DeviceViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/22.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "S_DeviceViewController.h"

@interface S_DeviceViewController ()

@end

@implementation S_DeviceViewController
@synthesize menuItems,broadcastSocket,connection,Devide_password,header;
@synthesize Old_pwd;
@synthesize New_pwd;
@synthesize re_pwd;


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

#pragma mark - Flipside View Controller

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
-(BOOL)check_pwd
{
    NSLog(@"oldinput:%@, %@",Old_pwd.text,Devide_password);
    if ([Old_pwd.text isEqual:Devide_password]) {
        if ([New_pwd.text isEqual:re_pwd.text])
        {
            return true;
        }else
        {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                              message:@"Retype Password is Error."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
          return false;  
        }
        
    }else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                          message:@"Old Password is Error."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return false;
    }
}
#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.delegate S_DeviceViewControllerDidFinish:self];
}

-(IBAction)Save:(id)sender
{
    if([self check_pwd])
    {
        NSLog(@"password ok");
        //Devide_password = New_pwd.text;
        send_tag = 1;
        [self sendTCPData:msgType_ParameterSetReq sendtag:1];
        
    }
}
#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

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

    return YES;
}

/*********************
 * PARAMETER Json
 *********************/
// Device.LANConfigSecurity.ConfigPassword
#pragma mark - PARAMETER Json
-(NSDictionary*)DevicePassword
{
    NSDictionary *ThirdLevel;
    if (send_tag == 0) {
        ThirdLevel = [NSDictionary dictionaryWithObject:Devide_password forKey:@"ConfigPassword"];
    }else
    {
        ThirdLevel = [NSDictionary dictionaryWithObject:New_pwd.text forKey:@"ConfigPassword"];
    }
    
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:ThirdLevel forKey:@"LANConfigSecurity"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
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
    jsonData = [NSJSONSerialization dataWithJSONObject:[self DevicePassword]
                                               options:0
                                                 error:&err];

    const char *transmit = [jsonData bytes];
    len = [jsonData length];
    //len=strlen(transmit);
    
    NSLog(@"len is %d",len);
    memset(_encodeData,0,sizeof(_encodeData));
    memcpy(_encodeData+4,transmit,len);
    msgLen=len+4;
    
    
    const char *pwddata = [Devide_password UTF8String];
    passwordLen=[Devide_password length];
    
    NSLog(@"transmit_header is %s",_encodeData+4);
    //return;
    
    int backheader = [header msgEncodeType:sendtype msgData:_encodeData msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];
    
    NSLog(@"msgEncodeType is %d",backheader);
    psztmp=_encodeData+4;
    
    memcpy(&version,_encodeData,1);
    memcpy(&type,_encodeData+1,1);
    payloadSize=0;
    memcpy(&payloadSize,_encodeData+2,2);
    NSString *Encode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d encode msg:%s",version,type,payloadSize,psztmp];
    NSLog(@"Tcp Encode str = %@",Encode_str);
    
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
        [connection disconnect];
        [connection release];
    
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
    
    /*
    memcpy(&version,tmp_ch,1);
    memcpy(&type,tmp_ch+1,1);
    payloadSize=0;
    memcpy(&payloadSize,tmp_ch+2,2);
    len = payloadSize;
    msgLen=len+4;
    if(payloadSize>65500) return @"";
  
    memcpy(_decodeDate,tmp_ch,msgLen);
    */
    memcpy(&version,tmp_ch,1);
    memcpy(&type,tmp_ch+1,1);
    payloadSize=0;
    memcpy(&payloadSize,tmp_ch+2,2);
    len = payloadSize;
    msgLen=len+4;
    char lsb = tmp_ch[2];
    char msb = tmp_ch[3];
    int value = (msb << 8) + lsb;
    NSLog(@"ch1 %d",lsb);
    NSLog(@"ch2 %d",msb);
    if(payloadSize>65500) return @"";

    
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
    
    NSDictionary *json = (NSDictionary *)JasonDic;
    // values in foreach loopsend_tag
    
    
    if (send_tag == 1 ) {
//        Devide_password = [[[json objectForKey:@"Device"]
//                            objectForKey:@"LANConfigSecurity"]
//                           objectForKey:@"ConfigPassword"];
        Devide_password = New_pwd.text;
        [[NSUserDefaults standardUserDefaults] setObject:Devide_password forKey:@"DevicePassword"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isConnected"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                          message:@"Setting is saved."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
    }
    
}
@end
