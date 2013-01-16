//
//  ZyXELAPPLib.h
//  ZyXELAPPLib
//
//  Created by cheng-heng hsu on 12/7/9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
//test git on my air
//just test co work
//add this  on air
//add this line second

#import <Foundation/Foundation.h>
#define FINESTATUS                   0
#define ERR_MSG_NULL                 0x1
#define ERR_MSG_TYPE                 0x2
#define ERR_PAYLOAD_LEN              0x3
#define ERR_PASSWD_LEN               0x4

#define msgType_DiscoverReq         0x1
#define msgType_DiscoverResp        0x2
#define msgType_SystemQueryReq      0x3
#define msgType_SystemQueryResp     0x4
#define msgType_ParameterGetReq     0x5
#define msgType_ParameterGetResp    0x6
#define msgType_ParameterSetReq     0x7
#define msgType_ParameterSetResp    0x8
#define msgType_DeviceNotifyReq     0x9
#define msgType_DeviceNotifyResp    0xa

@interface ZyXELAPPLib : NSObject
-(int)msgEncodeType:(int) reqType msgData:(char *)msg msgLength:(int)msgLen passwordData:(char*)pwdData passwordLength:(int)pwdLen;
-(int)msgDecodeType:(int*) reqType msgData:(char *)msg msgLength:(int)msgLen passwordData:(char*)pwdData passwordLength:(int)pwdLen;
@end
