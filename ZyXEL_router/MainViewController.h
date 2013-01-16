//
//  MainViewController.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/3.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <CFNetwork/CFNetwork.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "FlipsideViewController.h"
#import "ZyXELAPPLib.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

#define broascastHost @"255.255.255.255"
#define anyHost @"0.0.0.0"
#define routerHost @"192.168.1.1"


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate,UIPopoverControllerDelegate,UITableViewDataSource>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket *connection;
    NSTimer *time;
    NSMutableArray *deviceList;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    
	NSMutableArray *connectedSockets;
    NSString* Devicename;
    BOOL isRunning;
    IBOutlet UITableView* Device_list;
    IBOutlet UIView *scanningView;
    int send_tag;
    NSString* Devide_password;
    NSString* default_password;
    UIImageView* checkimg;
    IBOutlet UIButton* menu;
    IBOutlet UIButton* b_Refresh;
}
@property (nonatomic, strong) NSArray *menuItems;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
//Views
@property (retain, nonatomic) IBOutlet UIView *scanningView;
@property (retain, nonatomic) IBOutlet UITableView* Device_list;

//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;

//Bundle Version
@property (retain, nonatomic) NSString *version;
@property (retain, nonatomic) NSString *Devicename;
@property (retain, nonatomic) IBOutlet UIButton* menu;
@property (retain, nonatomic) IBOutlet UIButton* b_Refresh;

//header
@property (retain) ZyXELAPPLib *header;

-(void) sendBroadcastUDP;
-(void) sendTCPData:(int)sendtype sendtag:(long)tmptag;


- (IBAction)revealMenu:(id)sender;
- (IBAction)revealUnderRight:(id)sender;
- (IBAction)Reflash:(id)sender;
-(void)connect_Device;
@end
