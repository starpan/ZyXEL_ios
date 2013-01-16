//
//  S_CellularViewController.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/22.
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

@class S_CellularViewController;


@protocol S_CellularViewControllerDelegate
- (void)S_CellularViewControllerDidFinish:(S_CellularViewController *)controller;
@end

@interface S_CellularViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,UIPickerViewDelegate>
{
    AsyncUdpSocket *broadcastSocket;
    AsyncSocket* connection;
    NSTimer *time;
    ZyXELAPPLib *header;
    char _encodeData[6000],_msg[6000],_decodeDate[6000];
    IBOutlet UIScrollView* content;
    
    IBOutlet UITextField* APNname;
    IBOutlet UISegmentedControl* Auehentication;
    IBOutlet UITextField* UserName;
    IBOutlet UITextField* Cellupwd;
    
    
    IBOutlet UISwitch* Usage_Monitor;
    IBOutlet UISwitch* Reset;
    IBOutlet UIButton* Reset_Date;
    IBOutlet UITextField* Quota;
    UIDatePicker *datePicker;
    UIButton *myButton;
    
    UIPickerView *DatePickerView;
    
    NSMutableArray *arraydate;
    
    long send_tag;
    NSString* Devide_password;
    
}
//Sockets
@property (retain, nonatomic) AsyncUdpSocket *broadcastSocket;
@property (retain, nonatomic) AsyncSocket *connection;
//header
@property (retain) ZyXELAPPLib *header;
@property (nonatomic, strong) NSArray *menuItems;
@property (retain, nonatomic) IBOutlet UIScrollView* content;
@property (assign, nonatomic) id <S_CellularViewControllerDelegate> delegate;

@property (retain, nonatomic)IBOutlet UITextField* APNname;
@property (retain, nonatomic)IBOutlet UISegmentedControl* Auehentication;
@property (retain, nonatomic)IBOutlet UITextField* UserName;
@property (retain, nonatomic)IBOutlet UITextField* Cellupwd;


@property (retain, nonatomic)IBOutlet UISwitch* Usage_Monitor;
@property (retain, nonatomic)IBOutlet UISwitch* Reset;
@property (retain, nonatomic)IBOutlet UIButton* Reset_Date;
@property (retain, nonatomic)IBOutlet UITextField* Quota;
@property (retain, nonatomic) UIDatePicker *datePicker;

- (IBAction)back:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)changeDate:(id)sender;
- (void)Authenchange:(id)sender;
-(IBAction)MoniterSwitch:(id)sender;

@end
