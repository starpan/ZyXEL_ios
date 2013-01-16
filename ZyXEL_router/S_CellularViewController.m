//
//  S_CellularViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/22.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "S_CellularViewController.h"


@interface S_CellularViewController ()

@end

@implementation S_CellularViewController

@synthesize menuItems,header,broadcastSocket,connection,content;
@synthesize APNname;
@synthesize Auehentication;
@synthesize UserName;
@synthesize Cellupwd;
@synthesize Usage_Monitor;
@synthesize Reset;
@synthesize Reset_Date,datePicker;
@synthesize Quota;

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
    content.contentSize =  CGSizeMake(320, 700);
    Devide_password = [[NSUserDefaults standardUserDefaults] stringForKey:@"DevicePassword"];
    header=[ZyXELAPPLib new];
    
    [self sendTCPData:msgType_ParameterGetReq sendtag:0];
    send_tag = 0;
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 250, 325, 300)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = NO;
    datePicker.date = [NSDate date];
    
    [datePicker addTarget:self
                   action:@selector(changeDate:)
         forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    [datePicker release];
    datePicker.hidden = YES;
    
    myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    myButton.frame = CGRectMake(280, 210, 40, 40); // position in the parent view and set the size of the button
    [myButton setTitle:@"Done" forState:UIControlStateNormal];
    // add targets and actions
    [myButton addTarget:self action:@selector(closedate) forControlEvents:UIControlEventTouchUpInside];
    // add to a view
    [self.view addSubview:myButton];
    myButton.hidden = YES;
    
    //Auehentication.selectedSegmentIndex = 0;
    
    //設定所觸發的事件條件與對應事件
    [Auehentication addTarget:self action:@selector(Authenchange:) forControlEvents:UIControlEventValueChanged];

	// Do any additional setup after loading the view.

    DatePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
    DatePickerView.delegate = self;
    DatePickerView.tag =1;
    DatePickerView.showsSelectionIndicator = YES;
    [self.view addSubview:DatePickerView];
    DatePickerView.hidden = YES;
    
    
    
    arraydate = [[NSMutableArray alloc] init];
    for (int i=1; i<32; i++) {
        NSString *num = [NSString stringWithFormat:@"%d", i];
        [arraydate addObject:num];
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
    //[self.view addGestureRecognizer:self.slidingViewController.panGesture];
}


#pragma mark - Actions

- (IBAction)back:(id)sender
{

    [self.delegate S_CellularViewControllerDidFinish:self];
     //[self.slidingViewController anchorTopViewTo:ECRight];
}
- (IBAction)save:(id)sender
{
    send_tag = 4;
    [self sendTCPData:msgType_ParameterSetReq sendtag:4];
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                      message:@"Setting is saved."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
}

- (IBAction)changeDate:(id)sender
{
    DatePickerView.hidden = NO;
//    datePicker.hidden =NO;
//    myButton.hidden = NO;
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    df.dateStyle = NSDateFormatterMediumStyle;
//    Reset_Date.titleLabel.text = [NSString stringWithFormat:@"%@",
//                  [df stringFromDate:datePicker.date]];
//    [df release];


}
-(void)closedate
{
//    datePicker.hidden =YES;
//    myButton.hidden = YES;
}

- (void)Authenchange:(id)sender
{
    NSLog(@"%@", [sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]);
}

-(IBAction)MoniterSwitch:(id)sender
{
    if ([Usage_Monitor isOn]== YES) {
        Reset.enabled=YES;
        Reset_Date.userInteractionEnabled=YES;
        Quota.userInteractionEnabled=YES;
    }else{
        Reset.enabled=NO;
        Reset_Date.userInteractionEnabled=NO;
        Quota.userInteractionEnabled=NO;
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

    if (tmptag == 0 || tmptag == 4) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_3GPP]
                                                   options:0
                                                     error:&err];

    }else if(tmptag == 1 ||tmptag == 5)
    {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self CellularWanSetup]
                                                   options:0
                                                     error:&err];
    }

    transmit = [jsonData bytes];
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
    
}

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    const char* datachar =[data bytes];
    char* tmpchar=[self Decode_Str:datachar];
    [self ReadJason:tmpchar receive:tag];
    if (send_tag == 0) {
        [connection disconnect];
        [connection release];
        [self sendTCPData:msgType_ParameterGetReq sendtag:1];
        send_tag = 1;
    }else
    if (send_tag == 4) {
        [connection disconnect];
        [connection release];
        send_tag = 5;
        [self sendTCPData:msgType_ParameterSetReq sendtag:5];
        
    }else
    {
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
    if(payloadSize>65500) return @"";
    memcpy(_decodeDate,tmp_ch,msgLen);
    
    typeReq=0;
    ptypeReq=&typeReq;
    
    [header msgDecodeType:ptypeReq msgData:_decodeDate msgLength:msgLen passwordData:pwddata passwordLength:passwordLen];
    psztmp=_decodeDate+4;
    NSString *Decode_str=[NSString stringWithFormat:@"version:%d type:%d payloadSize:%d decode msg:%s",version,type,payloadSize,psztmp];
    return psztmp;
}

- (void)ReadJason:(char*) json_str receive:(long)tmptag{
    
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
        NSLog(@"%@ is %@",key,[deserializedDictionary objectForKey:key]);
    }
    

    if (send_tag == 1 || send_tag == 5) {
        APNname.text = [[[[[json objectForKey:@"Device"]
                           objectForKey:@"X_ZyXEL_3GPP"]
                          objectForKey:@"Interface"]
                         objectForKey:@"i1"] objectForKey:@"AccessPointName"];
        
        UserName.text = [[[[[json objectForKey:@"Device"]
                            objectForKey:@"X_ZyXEL_3GPP"]
                           objectForKey:@"Interface"]
                          objectForKey:@"i1"] objectForKey:@"Username"];
        
        Cellupwd.text = [[[[[json objectForKey:@"Device"]
                            objectForKey:@"X_ZyXEL_3GPP"]
                           objectForKey:@"Interface"]
                          objectForKey:@"i1"] objectForKey:@"Password"];
        NSString* Au_index = [[[[[json objectForKey:@"Device"]
                            objectForKey:@"X_ZyXEL_3GPP"]
                           objectForKey:@"Interface"]
                          objectForKey:@"i1"] objectForKey:@"PPPAuthenticationProtocol"];
        Auehentication.selectedSegmentIndex = [Au_index intValue];
    }else if(send_tag == 0 || send_tag == 4)
    {
        int days = [[[[[[[[json objectForKey:@"Device"]
                          objectForKey:@"X_ZyXEL_3GPP"]
                         objectForKey:@"Interface"]
                        objectForKey:@"i1"] objectForKey:@"Stats"]
                      objectForKey:@"DataPlanManagement"] objectForKey:@"MonthlyResetDay"] intValue];
        Reset_Date.titleLabel.text =[NSString stringWithFormat:@"%d",days];
        
        NSString* limitQuota =[NSString stringWithFormat:@"%d", [[[[[[[[json objectForKey:@"Device"]
                                                                       objectForKey:@"X_ZyXEL_3GPP"]
                                                                      objectForKey:@"Interface"]
                                                                     objectForKey:@"i1"] objectForKey:@"Stats"]
                                                                   objectForKey:@"DataPlanManagement"] objectForKey:@"MonthlyLimit"]intValue] ];
        Quota.text = limitQuota;
        NSString* resetflag;
        resetflag = [[[[[[[json objectForKey:@"Device"]
                           objectForKey:@"X_ZyXEL_3GPP"]
                          objectForKey:@"Interface"]
                         objectForKey:@"i1"] objectForKey:@"Stats"]
                       objectForKey:@"DataPlanManagement"] objectForKey:@"MonthlyResetEnable"];
        
        if ([resetflag isEqualToString:@"enable"]) {
            Reset.on = YES;
        }else{
            Reset.on = NO;
        }
    }

    
    

     
}

/*********************
 * PARAMETER Json
 *********************/
#pragma mark - PARAMETER Json
-(NSDictionary*)SystemInfo_3GPP
{

    NSMutableDictionary *data_Monthly = [[NSMutableDictionary alloc] init];
    [data_Monthly setValue:[NSNumber numberWithInteger:[Quota.text intValue]] forKey:@"MonthlyLimit"];
    if (Reset) {
        [data_Monthly setValue:@"enable" forKey:@"MonthlyResetEnable"];
    }else{
        [data_Monthly setValue:@"disable" forKey:@"MonthlyResetEnable"];
    }
    [data_Monthly setValue:[NSNumber numberWithInteger:[Reset_Date.titleLabel.text intValue]]  forKey:@"MonthlyResetDay"];

    
    
    NSMutableDictionary *data_1 = [[NSMutableDictionary alloc] init];
    [data_1 setValue:data_Monthly forKey:@"DataPlanManagement"];
    
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:data_1 forKey:@"Stats"];
    
    NSDictionary *i1Level = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSDictionary *faceLevel = [NSDictionary dictionaryWithObject:i1Level forKey:@"Interface"];
    NSDictionary *GPPLevel = [NSDictionary dictionaryWithObject:faceLevel forKey:@"X_ZyXEL_3GPP"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:GPPLevel forKey:@"Device"];
    return TopLevel;
}

-(NSDictionary*)CellularWanSetup
{
    NSString *pppname=[NSString stringWithFormat:@"%d",Auehentication.selectedSegmentIndex];
    NSString *APNname_tmp=APNname.text;
    NSString *UserName_tmp=UserName.text;
    NSString *Cellupwd_tmp=Cellupwd.text;
    NSLog(@"apn: %@, user: %@, cell: %@",APNname_tmp,UserName_tmp,Cellupwd_tmp);
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:APNname_tmp forKey:@"AccessPointName"];
    [data setValue:pppname forKey:@"PPPAuthenticationProtocol"];
    [data setValue:UserName_tmp forKey:@"Username"];
    [data setValue:Cellupwd_tmp forKey:@"Password"];
    
    NSDictionary *i1Level = [NSDictionary dictionaryWithObject:data forKey:@"i1"];
    
    NSDictionary *faceLevel = [NSDictionary dictionaryWithObject:i1Level forKey:@"Interface"];
    NSDictionary *GPPLevel = [NSDictionary dictionaryWithObject:faceLevel forKey:@"X_ZyXEL_3GPP"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:GPPLevel forKey:@"Device"];
    return TopLevel;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGRect oldframe = content.bounds;
    content.frame =  CGRectMake(oldframe.origin.x, -100, oldframe.size.width, oldframe.size.height);
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
    [textField resignFirstResponder];
    CGRect oldframe = content.bounds;
    content.frame =  CGRectMake(oldframe.origin.x, 44, oldframe.size.width, oldframe.size.height);
    return YES;
}

#pragma mark -
#pragma mark PickerView DataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection

        Reset_Date.titleLabel.text = [arraydate objectAtIndex:row];
    

    DatePickerView.hidden = YES;
    
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    

        return [arraydate count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    

        return [arraydate objectAtIndex:row];
    
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}


@end
