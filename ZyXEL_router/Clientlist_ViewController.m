//
//  Clientlist_ViewController.m
//  ZyXEL 4G Airspot
//
//  Created by pan star on 12/12/27.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "Clientlist_ViewController.h"

@interface Clientlist_ViewController ()

@end

@implementation Clientlist_ViewController
@synthesize Clienlist_table,broadcastSocket,header,connection;

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
    Devide_password = [[NSUserDefaults standardUserDefaults] stringForKey:@"DevicePassword"];
    header=[ZyXELAPPLib new];
    
    [self sendTCPData:msgType_ParameterGetReq sendtag:0];
    send_tag = 0;
    arrayClient = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [arrayClient count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

	static NSString *CellIdentifier = @"Cell";
	static NSUInteger const clientLabelTag = 2;
    static NSUInteger const bgimgTag = 3;
    
    
    
	
	UILabel *clientLabel = nil;
    UIImageView* bgimg  = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		//cell.indentationWidth = 0.0;
        //        UIImage *tmpImage1 = [UIImage imageNamed:@"list_bg_60.png"];
        //		bgimg = [[[UIImageView alloc] initWithImage:tmpImage1] autorelease];
        //        CGRect imageFrame1 = CGRectMake(0, 0, 280, 60);
        //        //imageFrame.origin = CGPointMake(0, 8);
        //        bgimg.frame = imageFrame1;
        //        bgimg.tag = bgimgTag;
        //        [cell.contentView addSubview:bgimg];
        
        
        
		
        clientLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 30)] autorelease];
		clientLabel.tag = clientLabelTag;
		clientLabel.font = [UIFont boldSystemFontOfSize:18];
		clientLabel.numberOfLines = 2;
		clientLabel.textColor = [UIColor blackColor];
		clientLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:clientLabel];
        
        
		
        
		
		
    }else
	{
        
		clientLabel = (UILabel *)[cell.contentView viewWithTag:clientLabelTag];
        
        
        //bgimg  = (UIImageView *)[cell.contentView viewWithTag:bgimgTag];
        
        
        
		
	}
    // Get the specific store for this row.

    // Set the relevant data for each subview in the cell.
    if ([arrayClient count]>0 && [indexPath row]<=[arrayClient count]) {
        clientLabel.text = [arrayClient objectAtIndex:[indexPath row]];
    }else
    {
        clientLabel.text = @"";
    }
    
    
    
    
    //    UIImage *ppImage1 = [UIImage imageNamed:@"list_bg_60.png"];
    //	bgimg.image = ppImage1;
    
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
	
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.delegate Clientlist_ViewControllerDidFinish:self];
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
    
    if (tmptag == 0) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_HostofEntries]
                                                   options:0
                                                     error:&err];

    }else if(tmptag == 1) {
        jsonData = [NSJSONSerialization dataWithJSONObject:[self SystemInfo_Host:Entries]
                                                   options:0
                                                     error:&err];
        
    }
    

    
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
    [connection disconnect];
    [connection release];
    [self ReadJason:[self Decode_Str:[data bytes]]];
    

    
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
    return psztmp;
}

- (void)ReadJason:(char*) json_str{
    if (json_str == @"") {
        [arrayClient addObject:@"Device is funcioning properly"];
        
        [Clienlist_table reloadData];
        return;
    }
    
    NSData* data = [[NSData alloc] initWithBytes:json_str length:strlen(json_str)];
    //NSData* jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *JasonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *keys = [JasonDic allKeys];
    
    NSDictionary *json = (NSDictionary *)JasonDic;
    // values in foreach loop
    
    if (send_tag == 0) {
        Entries = [[[[json objectForKey:@"Device"]
                     objectForKey:@"Hosts"]
                     objectForKey:@"HostNumberOfEntries"] intValue];
        [self sendTCPData:msgType_ParameterGetReq sendtag:1];
        send_tag = 1;
    }else
    {
        for (int i=1; i<=Entries; i++) {
            NSString* i_num = [NSString stringWithFormat:@"i%d",i];
            NSString* device_name = [[[[[json objectForKey:@"Device"]
                                    objectForKey:@"Hosts"]
                                   objectForKey:@"Host"]
                                  objectForKey:i_num]
                                 objectForKey:@"HostName"];
            [arrayClient addObject:device_name];
        }
    
    [Clienlist_table reloadData];
    }
    
}

-(NSDictionary*)SystemInfo_Host:(int)list_num
{
    if (list_num == 0) {
        list_num =1;
    }
    NSDictionary *HostLevel;
    NSMutableDictionary *data_i=[[NSMutableDictionary alloc] init];
    for (int i=1; i<=list_num; i++) {
        NSString* i_num = [NSString stringWithFormat:@"i%d",i];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        [data setValue:@"" forKey:@"PhysAddress"];
        [data setValue:@"" forKey:@"HostName"];
        [data setValue:@"" forKey:@"X_ZyXEL_HostType"];
        
        
        [data_i setValue:data forKey:i_num];
        
        
    }
    

    
    
    HostLevel = [NSDictionary dictionaryWithObject:data_i forKey:@"Host"];
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

@end
