//
//  Clientlist_ViewController.h
//  ZyXEL 4G Airspot
//
//  Created by pan star on 12/12/27.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZyXELAPPLib.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

#define broascastHost @"255.255.255.255"
#define anyHost @"0.0.0.0"
#define routerHost @"192.168.1.1"
@class Clientlist_ViewController;

@protocol Clientlist_ViewControllerDelegate
- (void)Clientlist_ViewControllerDidFinish:(Clientlist_ViewController *)controller;
@end
@interface Clientlist_ViewController : UIViewController
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    IBOutlet UITableView* Clienlist_table;
    long send_tag;
    NSMutableArray *arrayClient;
    
    NSString* Devide_password;
    int Entries;
    
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;
@property (assign, nonatomic) id <Clientlist_ViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView* Clienlist_table;

- (IBAction)back:(id)sender;
@end


