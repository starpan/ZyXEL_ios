//
//  InfoViewController.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/19.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "Notifi_ViewController.h"
#import "Clientlist_ViewController.h"
#import "ZyXELAPPLib.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

#define broascastHost @"255.255.255.255"
#define anyHost @"0.0.0.0"
#define routerHost @"192.168.1.1"

@interface InfoViewController : UIViewController<Notifi_ViewControllerDelegate,Clientlist_ViewControllerDelegate>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    IBOutlet UIScrollView* infocontent;
    
    IBOutlet UIImageView* Signal;
    IBOutlet UIImageView* wifiSignal;
    IBOutlet UIImageView* battery;
    IBOutlet UILabel* CelluarMode;
    IBOutlet UILabel* serviceProvider;
    IBOutlet UILabel* Devicename;
    
    IBOutlet UIImageView* allbar;
    IBOutlet UIImageView* sendbar;
    IBOutlet UIImageView* recbar;
    IBOutlet UILabel* current_usage;
    IBOutlet UILabel* Quota;
    IBOutlet UILabel* Send_data;
    IBOutlet UILabel* Receviv_data;
    IBOutlet UILabel* Usage_Advice;
    IBOutlet UILabel* Reset_Date;
    IBOutlet UILabel* Reset_count;
    

    IBOutlet UILabel* wifiname;
    IBOutlet UILabel* channel;
    
    long send_tag;
    NSString* Devide_password;
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;
@property (retain, nonatomic)IBOutlet UIImageView* Signal;
@property (retain, nonatomic)IBOutlet UIImageView* wifiSignal;
@property (retain, nonatomic)IBOutlet UIImageView* battery;
@property (retain, nonatomic)IBOutlet UILabel* CelluarMode;
@property (retain, nonatomic)IBOutlet UILabel* serviceProvider;
@property (retain, nonatomic)IBOutlet UILabel* Devicename;

@property (retain, nonatomic)IBOutlet UIImageView* allbar;
@property (retain, nonatomic)IBOutlet UIImageView* sendbar;
@property (retain, nonatomic)IBOutlet UIImageView* recbar;
@property (retain, nonatomic)IBOutlet UILabel* current_usage;
@property (retain, nonatomic)IBOutlet UILabel* Quota;
@property (retain, nonatomic)IBOutlet UILabel* Send_data;
@property (retain, nonatomic)IBOutlet UILabel* Receviv_data;
@property (retain, nonatomic)IBOutlet UILabel* Usage_Advice;
@property (retain, nonatomic)IBOutlet UILabel* Reset_Date;
@property (retain, nonatomic)IBOutlet UILabel* Reset_count;

@property (retain, nonatomic)IBOutlet UILabel* wifiname;
@property (retain, nonatomic)IBOutlet UILabel* channel;
@property (retain, nonatomic)IBOutlet UIScrollView* infocontent;

- (IBAction)revealMenu:(id)sender;

@end
