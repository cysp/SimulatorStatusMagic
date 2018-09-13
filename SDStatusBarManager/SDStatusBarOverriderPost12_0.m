//
//  SDStatusBarOverriderPost12_0.m
//  SimulatorStatusMagic
//
//  Created by Scott Talbot on 6/6/18.
//  Copyright © 2018 Shiny Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDStatusBarOverriderPost12_0.h"

typedef NS_ENUM(int, StatusBarItem) {
  // 0
  // 1
  QuietMode = 2,
  AirplaneMode = 3,
  SignalStrengthBars = 4,
  // 5
  // 6
  // 7
  // 8
  // 9
  BatteryDetail = 10,
  // 11
  // 12
  Bluetooth = 13,
  // 14
  // 15
  // 16
  // 17
  // 18
  // 19
  // 20
  // 21
  // 22
  // 23
  // 24
  // 25
  // 26
  // 27
  // 28
  // 29
  // 30
  // 31
  // 32
  // 33
  // 34
};

typedef NS_ENUM(unsigned int, BatteryState) {
  BatteryStateUnplugged = 0
};

typedef struct {
  bool itemIsEnabled[37];
  char timeString[64];
  char shortTimeString[64];
  char dateString[256];
  int gsmSignalStrengthRaw;
  int gsmSignalStrengthBars;
  char serviceString[100];
  char serviceCrossfadeString[100];
  char serviceImages[2][100];
  char operatorDirectory[1024];
  unsigned int serviceContentType;
  int wifiSignalStrengthRaw;
  int wifiSignalStrengthBars;
  unsigned int dataNetworkType;
  int batteryCapacity;
  unsigned int batteryState;
  char batteryDetailString[150];
  int bluetoothBatteryCapacity;
  int thermalColor;
  unsigned int thermalSunlightMode : 1;
  unsigned int slowActivity : 1;
  unsigned int syncActivity : 1;
  char activityDisplayId[256];
  unsigned int bluetoothConnected : 1;
  unsigned int displayRawGSMSignal : 1;
  unsigned int displayRawWifiSignal : 1;
  unsigned int locationIconType : 1;
  unsigned int quietModeInactive : 1;
  unsigned int tetheringConnectionCount;
  unsigned int batterySaverModeActive : 1;
  unsigned int deviceIsRTL : 1;
  unsigned int lock : 1;
  char breadcrumbTitle[256];
  char breadcrumbSecondaryTitle[256];
  char personName[100];
  unsigned int electronicTollCollectionAvailable : 1;
  unsigned int wifiLinkWarning : 1;
  unsigned int wifiSearching : 1;
  double backgroundActivityDisplayStartDate;
  unsigned int shouldShowEmergencyOnlyStatus : 1;
} StatusBarRawData;

typedef struct {
  bool overrideItemIsEnabled[37];
  unsigned int overrideTimeString : 1;
  unsigned int overrideDateString : 1;
  unsigned int overrideGsmSignalStrengthRaw : 1;
  unsigned int overrideGsmSignalStrengthBars : 1;
  unsigned int overrideServiceString : 1;
  unsigned int overrideServiceImages : 2;
  unsigned int overrideOperatorDirectory : 1;
  unsigned int overrideServiceContentType : 1;
  unsigned int overrideWifiSignalStrengthRaw : 1;
  unsigned int overrideWifiSignalStrengthBars : 1;
  unsigned int overrideDataNetworkType : 1;
  unsigned int disallowsCellularDataNetworkTypes : 1;
  unsigned int overrideBatteryCapacity : 1;
  unsigned int overrideBatteryState : 1;
  unsigned int overrideBatteryDetailString : 1;
  unsigned int overrideBluetoothBatteryCapacity : 1;
  unsigned int overrideThermalColor : 1;
  unsigned int overrideSlowActivity : 1;
  unsigned int overrideActivityDisplayId : 1;
  unsigned int overrideBluetoothConnected : 1;
  unsigned int overrideBreadcrumb : 1;
  unsigned int overrideLock;
  unsigned int overrideDisplayRawGSMSignal : 1;
  unsigned int overrideDisplayRawWifiSignal : 1;
  unsigned int overridePersonName : 1;
  unsigned int overrideWifiLinkWarning : 1;
  StatusBarRawData values;
} StatusBarOverrideData;

@interface UIStatusBarServer : NSObject

+ (StatusBarRawData const *)getStatusBarData;
+ (StatusBarOverrideData *)getStatusBarOverrideData;
+ (void)postStatusBarData:(StatusBarRawData const *)arg1 withActions:(int)arg2;
+ (void)postStatusBarOverrideData:(StatusBarOverrideData *)arg1;
+ (void)permanentizeStatusBarOverrideData;

@end

@implementation SDStatusBarOverriderPost12_0 {
  @private
  StatusBarOverrideData _overrideData;
}

- (instancetype)init {
  if ((self = [super init])) {
    [self refreshOverrideData];
  }
  return self;
}

@synthesize bluetoothConnected;
@synthesize bluetoothEnabled;
@synthesize networkType;

- (void)clearOverrideData {
  memset(&_overrideData, 0, sizeof(StatusBarOverrideData));
}

- (void)refreshOverrideData {
  memcpy(&_overrideData, [UIStatusBarServer getStatusBarOverrideData], sizeof(StatusBarOverrideData));
}

- (void)addDefaultOverrides {
//  StatusBarOverrideData _overrideData;

  // Enable 5 bars of mobile (iPhone only)
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
    _overrideData.overrideItemIsEnabled[SignalStrengthBars] = 1;
    _overrideData.values.itemIsEnabled[SignalStrengthBars] = 1;
    _overrideData.overrideGsmSignalStrengthBars = 1;
    _overrideData.values.gsmSignalStrengthBars = 5;
  }

//  // Remove carrier text for iPhone, set it to "iPad" for the iPad
//  _overrideData.overrideServiceString = 1;
//  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
////    self.carrierName = @"iPad";
//    strcpy(_overrideData.values.serviceString, "iPad");
//  } else {
//    _overrideData.values.serviceString[0] = '\0';
//  }

  // Battery: 100% and unplugged
  _overrideData.overrideItemIsEnabled[BatteryDetail] = YES;
  _overrideData.values.itemIsEnabled[BatteryDetail] = YES;
  _overrideData.overrideBatteryCapacity = YES;
  _overrideData.values.batteryCapacity = 100;
  _overrideData.overrideBatteryState = YES;
  _overrideData.values.batteryState = BatteryStateUnplugged;
  _overrideData.overrideBatteryDetailString = YES;
  _overrideData.values.batteryDetailString[0] = '\0';
}

- (NSString *)timeString {
  if (!_overrideData.overrideTimeString) {
    return nil;
  }
  return [[NSString alloc] initWithUTF8String:_overrideData.values.timeString];
}
- (void)setTimeString:(NSString *)timeString {
  size_t const overrideTimeStringMaxLength = sizeof(_overrideData.values.timeString);

  if (!timeString) {
    _overrideData.overrideTimeString = false;
    memset(_overrideData.values.timeString, 0, overrideTimeStringMaxLength);
    return;
  }

  _overrideData.overrideTimeString = true;
  [timeString getCString:_overrideData.values.timeString maxLength:overrideTimeStringMaxLength encoding:NSUTF8StringEncoding];
}

- (NSString *)carrierName {
  if (!_overrideData.overrideServiceString) {
    return nil;
  }
  return [[NSString alloc] initWithUTF8String:_overrideData.values.serviceString];
}
- (void)setCarrierName:(NSString *)carrierName {
  size_t const overrideServiceStringMaxLength = sizeof(_overrideData.values.serviceString);

  if (!carrierName) {
    _overrideData.overrideServiceString = false;
    memset(_overrideData.values.timeString, 0, overrideServiceStringMaxLength);
    return;
  }

  _overrideData.overrideServiceString = true;
  [carrierName getCString:_overrideData.values.serviceString maxLength:overrideServiceStringMaxLength encoding:NSUTF8StringEncoding];
}

@synthesize batteryDetailEnabled = _batteryDetailEnabled;
- (void)setBatteryDetailEnabled:(BOOL)batteryDetailEnabled {
  _batteryDetailEnabled = batteryDetailEnabled;
}

- (void)enableOverrides {
  StatusBarOverrideData overrides = _overrideData;

  overrides.overrideItemIsEnabled[28] = 1;
  overrides.values.itemIsEnabled[28] = 1;
  overrides.values.thermalSunlightMode = 1;

  overrides.overrideDataNetworkType = self.networkType != SDStatusBarManagerNetworkTypeWiFi;
  overrides.values.dataNetworkType = self.networkType - 1;

  // Remove carrier text for iPhone, set it to "iPad" for the iPad
  overrides.overrideServiceString = 1;
  NSString *carrierText = self.carrierName;
  if ([carrierText length] <= 0) {
    carrierText = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"" : @"iPad";
  }
  strcpy(overrides.values.serviceString, [carrierText cStringUsingEncoding:NSUTF8StringEncoding]);

//  // Battery: 100% and unplugged
//  overrides.overrideItemIsEnabled[BatteryDetail] = YES;
//  overrides.values.itemIsEnabled[BatteryDetail] = YES;
//  overrides.overrideBatteryCapacity = YES;
//  overrides.values.batteryCapacity = 100;
//  overrides.overrideBatteryState = YES;
//  overrides.values.batteryState = BatteryStateUnplugged;
//  overrides.overrideBatteryDetailString = YES;
//  NSString *batteryDetailString = @"";
//  if (self.batteryDetailEnabled) {
//    batteryDetailString = [NSString stringWithFormat:@"%@%%", @(overrides.values.batteryCapacity)];
//  }
//  strcpy(overrides.values.batteryDetailString, [batteryDetailString cStringUsingEncoding:NSUTF8StringEncoding]);

  // Bluetooth
  overrides.overrideItemIsEnabled[Bluetooth] = !!self.bluetoothEnabled;
  overrides.values.itemIsEnabled[Bluetooth] = !!self.bluetoothEnabled;
  if (self.bluetoothEnabled) {
    overrides.overrideBluetoothConnected = self.bluetoothConnected;
    overrides.values.bluetoothConnected = self.bluetoothConnected;
  }

  // Actually update the status bar
  [UIStatusBarServer postStatusBarOverrideData:&overrides];

  // Lock in the changes, reset simulator will remove this
//  [UIStatusBarServer permanentizeStatusBarOverrideData];
}

- (void)disableOverrides {
  [self clearOverrideData];

  [UIStatusBarServer postStatusBarOverrideData:&_overrideData];
}

//- (void)publishOverride {
//  StatusBarOverrideData overrides = { 0 };
//
//  // Actually update the status bar
//  [UIStatusBarServer postStatusBarOverrideData:&overrides];
//
//  // Have to call this to remove all the overrides
////  [UIStatusBarServer permanentizeStatusBarOverrideData];
//}

@end
