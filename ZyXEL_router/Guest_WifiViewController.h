//
//  Guest_WifiViewController.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/19.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "ZyXELAPPLib.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

#define broascastHost @"255.255.255.255"
#define anyHost @"0.0.0.0"
#define routerHost @"192.168.1.1"

@interface Guest_WifiViewController : UIViewController<UITextFieldDelegate>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    
	NSMutableArray *connectedSockets;
    BOOL isRunning;
    IBOutlet UILabel* Devicename;
    IBOutlet UILabel* Wifiname;
    IBOutlet UILabel* Wifipwd;
    IBOutlet UIButton* b_change;
    IBOutlet UIButton* b_open;
    int open_status;
    long send_tag;
    NSString* Devide_password;
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
//Bundle Version
@property (retain, nonatomic) NSString *version;

@property (retain, nonatomic)IBOutlet UILabel* Devicename;
@property (retain, nonatomic)IBOutlet UILabel* Wifiname;
@property (retain, nonatomic)IBOutlet UILabel* Wifipwd;
@property (retain, nonatomic)IBOutlet UIButton* b_change;
@property (retain, nonatomic)IBOutlet UIButton* b_open;



- (IBAction)revealMenu:(id)sender;
- (IBAction)changewifiPwd:(id)sender;
- (IBAction)openwifi:(id)sender;

@end

