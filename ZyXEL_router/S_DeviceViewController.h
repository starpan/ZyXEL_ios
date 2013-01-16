//
//  S_DeviceViewController.h
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
@class S_DeviceViewController;

@protocol S_DeviceViewControllerDelegate
- (void)S_DeviceViewControllerDidFinish:(S_DeviceViewController *)controller;
@end

@interface S_DeviceViewController : UIViewController<UITextFieldDelegate>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    
    IBOutlet UITextField* Old_pwd;
    IBOutlet UITextField* New_pwd;
    IBOutlet UITextField* re_pwd;
    
    NSString* Devide_password;
    int send_tag;
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;

@property (nonatomic, retain) IBOutlet UITextField* Old_pwd;
@property (nonatomic, retain) IBOutlet UITextField* New_pwd;
@property (nonatomic, retain) IBOutlet UITextField* re_pwd;

@property (assign, nonatomic) id <S_DeviceViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString* Devide_password;

- (IBAction)back:(id)sender;
-(IBAction)Save:(id)sender;
@end
