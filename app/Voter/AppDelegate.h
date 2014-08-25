//
//  AppDelegate.h
//  Voter
//
//  Created by Martijn on 24/08/14.
//  Copyright (c) 2014 Martijn. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;
@import CoreBluetooth;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

