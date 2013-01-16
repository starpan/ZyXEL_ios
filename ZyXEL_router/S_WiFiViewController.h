//
//  S_WiFiViewController.h
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
@class S_WiFiViewController;

@protocol S_WiFiViewControllerDelegate
- (void)S_WiFiViewControllerDidFinish:(S_WiFiViewController *)controller;
@end

@interface S_WiFiViewController : UIViewController<UIScrollViewDelegate,UIPickerViewDelegate,UITextFieldDelegate>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    IBOutlet UIScrollView* content;
    
    IBOutlet UITextField* Wifiname;
    IBOutlet UIButton* b_channel;
    IBOutlet UISegmentedControl* power;
    IBOutlet UIButton* Wifisecurity;
    IBOutlet UITextField* Wifipwd;
    
    IBOutlet UITextField* GuestWifiname;
    IBOutlet UISwitch* open;
    IBOutlet UITextField* GuestWifipwd;
    
    UIPickerView *channelPickerView;
    UIPickerView *SecurityPickerView;
    
    NSMutableArray *arraychannel;
    NSMutableArray *arraySecu;
    
    long send_tag;
    NSString* Devide_password;
    int auto_channel;
    
    IBOutlet UIActivityIndicatorView* wifi_wait;
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;
@property (assign, nonatomic)  IBOutlet UIScrollView* content;
@property (assign, nonatomic) id <S_WiFiViewControllerDelegate> delegate;

@property (retain, nonatomic)IBOutlet UITextField* Wifiname;
@property (retain, nonatomic)IBOutlet UIButton* b_channel;
@property (retain, nonatomic)IBOutlet UISegmentedControl* power;
@property (retain, nonatomic)IBOutlet UIButton* Wifisecurity;
@property (retain, nonatomic)IBOutlet UITextField* Wifipwd;

@property (retain, nonatomic)IBOutlet UITextField* GuestWifiname;
@property (retain, nonatomic)IBOutlet UISwitch* open;
@property (retain, nonatomic)IBOutlet UITextField* GuestWifipwd;
@property (retain, nonatomic)IBOutlet UIActivityIndicatorView* wifi_wait;

- (IBAction)back:(id)sender;
- (IBAction)Save:(id)sender;
- (IBAction)channel_choose:(id)sender;
- (IBAction)Security_choose:(id)sender;
- (void)Powerchange:(id)sender;

@end
