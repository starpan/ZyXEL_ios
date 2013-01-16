//
//  Message_Define.h
//  ZyXEL_router
//
//  Created by pan star on 12/10/12.
//  Copyright (c) 2012年 pan star. All rights reserved.
//

#ifndef ZyXEL_router_Message_Define_h
#define ZyXEL_router_Message_Define_h

#define ERR_UNDEFINED_REQ_TYPE  -1
#define ERR_JSON_FORMAT   -2
#define ERR_APP_VER   -3
#define ERR_MAGIC_NUM   -4
#define ERR_JOBJ_PARAMETER_NOT_FOUND -5
#define ERR_SOCKET_SYS_MGR  -6
#define ERR_WIFI_INVALID_ENCRYPT -7
#define ERR_HEADER_PROTOCOL_VER  -8
#define ERR_HEADER_PAYLOAD_LENGTH -9
#define ERR_HEADER_NOT_SUPPORT_TYPE -10
#define ERR_CELL_SOCKET_SET  -11
#define ERR_UCI_INVALID_PACKAGE  -12
#define ERR_UCI_INVALID_OPTION  -13
#define ERR_UCI_APPLY_FAILED  -14
#define ERR_UCI_COMMIT_FAILED  -15
#define ERR_JOBJ_INVALID_INTERFACE -16
#define ERR_JOBJ_MAX_LEVEL_INTF  -17
#define ERR_FILE_OPEN   -18
#define ERR_PROC_OPEN   -19
#define ERR_RC4KEY   -20



// UDP
#define DeviceDiscoverReq @"{\"Device\":{\"X_ZyXEL_Ext\":{\"AppInfo\":{\"MagicNum\":\"Z3704\",\"AppVersion\":1}}}}"
//TCP
#define SystemQueryReq @"{\"Device\":{\"X_ZyXEL_Ext\":{\"AppInfo\":{\"MagicNum\":\"Z3704\",\"AppVersion\":1}}}}"

/* APP Magic Number */
#define APP_MAGIC_NUM			"Z3704"

/* APP features supported in this product */
#define APP_SYS_INFO "SystemInfo"
#define APP_SYS_INFO_VER 0x1
#define APP_WiFi_SETUP "WiFiSetup"
#define APP_WiFi_SETUP_VER 0x1
#define APP_GUEST_WLAN "GuestWlan"
#define APP_GUEST_WLAN_VER 0x1
#define APP_WAN_DATA_METER "WanDataMeter"
#define APP_WAN_DATA_METER_VER 0x1
#define APP_DEVICE_NOTIFY "DeviceNotify"
#define APP_DEVICE_NOTIFY_VER 0x1

#define DEVICE_DISCOVERY_REQ_PAYLOAD @"{\"Device\":{\"X_ZyXEL_Ext\":{\
\"AppInfo\":{\
\"MagicNum\":\"" APP_MAGIC_NUM "\",\
\"AppVersion\":1}}}}"


#define SYSTEM_QUERY_REQ_PAYLOAD @"{\"Device\":{\"X_ZyXEL_Ext\":{\
\"AppInfo\":{\
\"MagicNum\":\"" APP_MAGIC_NUM "\",\
\"AppVersion\":1}}}}"

//#define DEVICE_NOTIFY_REQ_PAYLOAD @"{\"InternetGatewayDevice\":{\"X_ZyXEL_Ext\":{\
//\"AppInfo\":{\
//\"MagicNum\":\"" APP_MAGIC_NUM "\",\
//\"AppVersion\":1\
//}}}}"

#define PARAMETER_GET_REQ_PAYLOAD @"{\"Device\":{\
\"X_ZyXEL_3GPP\":{\
\"Interface\":{\
\"i1\":{\
\"SignalStrength\":0,\
\"CellularMode\":\"\",\
\"ServiceProvider\":\"\",\
\"Stats\":{\
\"BytesReceived\":0,\
\"BytesSent\":0,\
\"DataPlanManagement\":{\
\"LastResetDate\":\"\",\
\"MonthlyLimit\":0}}}}},\
\"X_ZyXEL_Ext\":{\
\"BatteryStatus\":{\
\"ChargeStat\":\"\",\
\"TotalCapacity\":0,\
\"RemainCapacity\":0}},\
\"WiFi\":{\
\"SSID\":{\
\"i1\":{\
\"SSID\":\"\"}},\
\"Radio\":{\
\"i1\":{\
\"Channel\":0,\
\"TransmitPowerSupported\":\"\",\
\"TransmitPower\":0,\
\"AutoChannelSupported\":0,\
\"AutoChannelEnable\":0,\
}},\
\"AccessPointNumberOfEntries\":0,\
\"AccessPoint\":{\
\"i1\":{\
\"Security\":{\
\"ModeEnabled\":\"\",\
\"ModesSupported\":\"\",\
\"PreShareKey\":\"\"},\
\"AssociatedDeviceNumberOfEntries\":0,\
\"AssociatedDevice\":{\
\"i1\":{\
\"MACAddress\":\"\"}}}}},\
\"Hosts\":{\
\"Host\":{\
\"i1\":{\
\"PhysAddress\":\"\",\
\"HostName\":\"\"\
}}}}\
}"

#define PARAMETER_SET_REQ_PAYLOAD @"{\"Device\":{\
\"X_ZyXEL_3GPP\":{\
\"Interface\":{\
\"i3\":{\
\"Stats\":{\
\"DataPlanManagement\":{\
\"MonthlyLimit\":0,\
\"MonthlyResetEnable\":1,\
\"MonthlyResetDay\":27,\
\"ResetCounter\":1}}}}},\
\"WiFi\":{\
\"SSID\":{\
\"i1\":{\
\"SSID\":\"ASHole\"}},\
\"Radio\":{\
\"i1\":{\
\"TransmitPower\":5,\
\"AutoChannelEnable\":1,\
\"Channel\":0}},\
\"AccessPoint\":{\
\"i1\":{\
\"Security\":{\
\"ModeEnabled\":\"WPA2-Personal\",\
\"PreShareKey\":\"12345678\"}}}}\}}"

/* APP comands json */
#define DEVICE_Guestwifi_REQ_PAYLOAD @"{\"Device\":{\"WiFi\":{\
\"X_ZyXEL_GuestAP\":{\
\"Enable\":0,\
\"SSID\":\"\",\
\"PreShareKey\":\"\"}}}}"

#define DEVICE_Guestwifi_REQ1_PAYLOAD @"{\"Device\":{\"WiFi\":{\
\"X_ZyXEL_GuestAP\":{\
\"Enable\":0,\
\"PreShareKey\":\"\"}}}}"
#define DEVICE_Notify_REQ_PAYLOAD @"{\"Device\":{\
\"X_ZyXEL_Ext\":{\
\"MagicNum\":"APP_MAGIC_NUM",\
\"AppInfo\":\
\}\"SysetmInfo\":{\
\"SystemName\":\"\",\
}}}}}"

#define DISCOVERY_System_Keys [[NSArray alloc] initWithObjects:@"Device",@"X_ZyXEL_Ext",@"AppInfo",@"MagicNum",@"AppVersion",nil]
#define Guest_WLAN_Keys [[NSArray alloc] initWithObjects:@"Device",@"WiFi",@"X_ZyXEL_GuestAP",@"PreShareKey",@"SSID",@"Enable",nil]

#define PARAMETER_GET_Keys [[NSArray alloc] initWithObjects:@"Device",@"X_ZyXEL_3GPP",@"Interface",@"i1",@"SignalStrength",@"CellularMode",@"ServiceProvider",@"Stats",@"BytesReceived",@"BytesSent",@"DataPlanManagement",@"LastResetDate",@"MonthlyLimit",@"X_ZyXEL_Ext",@"BatteryStatus",@"ChargeStat",@"TotalCapacity",@"RemainCapacity",@"WiFi",@"SSID",@"i1",@"Radio",@"Channel",@"TransmitPowerSupported",@"TransmitPower",@"AutoChannelSupported",@"AutoChannelEnable",@"AccessPointNumberOfEntries",@"AssociatedDevice",@"MACAddress",@"Hosts",@"Host",@"PhysAddress",@"HostName",nil]

#define PARAMETER_SET_Keys [[NSArray alloc] initWithObjects:@"Device",@"X_ZyXEL_3GPP",@"Interface",@"i3",@"Stats",@"DataPlanManagement",@"MonthlyLimit",@"MonthlyResetEnable",@"MonthlyResetDay",@"ResetCounter",@"WiFi",@"SSID",@"MonthlyLimit",@"i1",@"ASHole",@"Radio",@"TransmitPower",@"AutoChannelEnable",@"Channel",@"AccessPoint",@"Security",@"ModeEnabled",@"PreShareKey",nil]



#endif
