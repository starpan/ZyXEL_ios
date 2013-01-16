//
//  SettingsViewController.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/19.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "S_CellularViewController.h"
#import "S_WiFiViewController.h"
#import "S_DeviceViewController.h"
#import "ZyXELAPPLib.h"
#import "AsyncUdpSocket.h"
#import "AsyncSocket.h"

#define broascastHost @"255.255.255.255"
#define anyHost @"0.0.0.0"
#define routerHost @"192.168.1.1"


@interface SettingsViewController : UIViewController<S_CellularViewControllerDelegate,S_WiFiViewControllerDelegate,S_DeviceViewControllerDelegate, UIPopoverControllerDelegate>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;

- (IBAction)revealMenu:(id)sender;


@end
