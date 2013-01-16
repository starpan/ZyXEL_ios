//
//  Notifi_ViewController.m
//  ZyXEL_router
//
//  Created by pan star on 12/10/22.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import "Notifi_ViewController.h"

@interface Notifi_ViewController ()

@end

@implementation Notifi_ViewController
@synthesize menuItems,notifylist,header,connection,broadcastSocket;

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
    arraynotify = [[NSMutableArray alloc] init];
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
    
    return [arraynotify count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //	bookcount++;
    //	NSLog(@"bookcount = %d",bookcount);
	static NSString *CellIdentifier = @"Cell";
	static NSUInteger const notifyLabelTag = 2;
    static NSUInteger const bgimgTag = 3;
    
    
    
	
	UILabel *notifyLabel = nil;
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
        
            
        
		
        notifyLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 30)] autorelease];
		notifyLabel.tag = notifyLabelTag;
		notifyLabel.font = [UIFont boldSystemFontOfSize:18];
		notifyLabel.numberOfLines = 2;
		notifyLabel.textColor = [UIColor blackColor];
		notifyLabel.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:notifyLabel];
        

		
        
		
		
    }else
	{
        
		notifyLabel = (UILabel *)[cell.contentView viewWithTag:notifyLabelTag];

        
        //bgimg  = (UIImageView *)[cell.contentView viewWithTag:bgimgTag];

        
        
		
	}
    // Get the specific store for this row.
    
	
    
    // Set the relevant data for each subview in the cell.
    if ([arraynotify count]>0 && [indexPath row]<[arraynotify count]) {
        notifyLabel.text = [arraynotify objectAtIndex:[indexPath row]];
    }else
    {
       notifyLabel.text = @"";
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
    UITableViewCell *cell1 = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView* imageview = [[UIImageView alloc] init];
    
    UIView* subview = [[cell1.contentView subviews] lastObject];
    if ([subview isKindOfClass:[UIImageView class]]) {
        imageview = (UIImageView*)subview;
        imageview.hidden = NO;
    }
    //NSString *cell1Text = [NSString stringWithString: cell1.textLabel.text];

	
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.delegate Notifi_ViewControllerDidFinish:self];
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

        jsonData = [NSJSONSerialization dataWithJSONObject:[self Notify]
                                                   options:0
                                                     error:&err];

    const char *transmit = [jsonData bytes];
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
        [arraynotify addObject:@"Device is funcioning properly"];
        
        [notifylist reloadData];
        return;
    }
    
    NSData* data = [[NSData alloc] initWithBytes:json_str length:strlen(json_str)];
    //NSData* jsonData = [json_str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *JasonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *keys = [JasonDic allKeys];
    
    NSDictionary *json = (NSDictionary *)JasonDic;
    // values in foreach loop
    
    
    NSString* alert_s = [[[[[json objectForKey:@"Device"]
                        objectForKey:@"X_ZyXEL_Ext"]
                       objectForKey:@"Notify"]
                      objectForKey:@"aps"]
                     objectForKey:@"alert"];
    
    [arraynotify addObject:alert_s];
    
    NSString* timestamp_s = [[[[[json objectForKey:@"Device"]
                            objectForKey:@"X_ZyXEL_Ext"]
                           objectForKey:@"Notify"]
                          objectForKey:@"aps"]
                         objectForKey:@"timestamp"];
    [arraynotify addObject:timestamp_s];
    
    NSString* SystemName_s = [[[[json objectForKey:@"Device"]
                            objectForKey:@"X_ZyXEL_Ext"]
                           objectForKey:@"SystemInfo"]
                          objectForKey:@"SystemName"];
    [arraynotify addObject:SystemName_s];

    [notifylist reloadData];
    
}

-(NSDictionary*)Notify
{
    
    NSMutableDictionary *data2 = [[NSMutableDictionary alloc] init];
    [data2 setValue:@"" forKey:@"timestamp"];
    [data2 setValue:@"" forKey:@"alert"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setValue:data2 forKey:@"aps"];
    
    
    NSMutableDictionary *sys_data1 = [[NSMutableDictionary alloc] init];
    [sys_data1 setValue:@"" forKey:@"SystemName"];
    
    NSMutableDictionary *appinfo_data1 = [[NSMutableDictionary alloc] init];
    [appinfo_data1 setValue:sys_data1 forKey:@"SystemInfo"];
    [appinfo_data1 setValue:data2 forKey:@"Notify"];
    
    
    NSDictionary *SecondLevel = [NSDictionary dictionaryWithObject:appinfo_data1 forKey:@"X_ZyXEL_Ext"];
    NSDictionary *TopLevel = [NSDictionary dictionaryWithObject:SecondLevel forKey:@"Device"];
    
    return TopLevel;
    
}



@end
