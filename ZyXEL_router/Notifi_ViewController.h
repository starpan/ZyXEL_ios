//
//  Notifi_ViewController.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/22.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZyXELAPPLib.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

#define broascastHost @"255.255.255.255"
#define anyHost @"0.0.0.0"
#define routerHost @"192.168.1.1"
@class Notifi_ViewController;

@protocol Notifi_ViewControllerDelegate
- (void)Notifi_ViewControllerDidFinish:(Notifi_ViewController *)controller;
@end
@interface Notifi_ViewController : UIViewController
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    IBOutlet UITableView* notifylist;
    long send_tag;
    NSMutableArray *arraynotify;
    
    NSString* Devide_password;
    
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;
@property (assign, nonatomic) id <Notifi_ViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView* notifylist;

- (IBAction)back:(id)sender;
@end
