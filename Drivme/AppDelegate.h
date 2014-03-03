//
//  AppDelegate.h
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
