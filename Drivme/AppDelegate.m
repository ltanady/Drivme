//
//  AppDelegate.m
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import "NavigationViewController.h"
#import "ErrorViewController.h"
#import <UIKit/UIKit.h>

@implementation AppDelegate
@synthesize locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Reset badge count
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"4bzG3LmW885yCHNV1Scsk7WltDBlOp2UTeZKbaQq" clientKey:@"CJNaYJTJBIdHmxcO3tqniG6c6acriKVptycFMdc0"];
    [GMSServices provideAPIKey:@"AIzaSyAMbbFLuguaUZD2qJDShHruQ78-crqDpvI"];
    
    // Initialize location manager
    [self intializeLocationManager];
    //self.window.rootViewController = nil;
    
//    PFObject *myPost = [PFObject objectWithClassName:@"Post"];
//    myPost[@"title"] = @"I'm Hungry";
//    myPost[@"content"] = @"Where should we go for lunch?";
//    
//    PFObject *myComment = [PFObject objectWithClassName:@"Comment"];
//    myComment[@"content"] = @"Let's do sushi";
//    
//    myComment[@"parent"] = myPost;
//    
//    [myComment saveInBackground];
    
//    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:1.3127839 longitude:103.8794163];
//    PFObject *location = [PFObject objectWithClassName:@"Location"];
//    [location setObject:point forKey:@"location"];
//    [location saveInBackground];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        for (id temp in objects) {
//            PFObject *vehicle = temp;
//            NSNumber *latitude = vehicle[@"latitude"];
//            NSNumber *longitude = vehicle[@"longitude"];
//            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
//            PFObject *locationObject = [PFObject objectWithClassName:@"Location"];
//            [locationObject setObject:point forKey:@"location"];
//            locationObject[@"parent"] = vehicle;
//            [locationObject saveInBackground];
//            //NSLog(@"%@, %@", latitude, longitude);
//        }
//    }];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        for (PFObject *vehicle in objects) {
//            NSNumber *latitude = vehicle[@"latitude"];
//            NSNumber *longitude = vehicle[@"longitude"];
//            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
//            [vehicle setObject:point forKey:@"location"];
//            [vehicle saveInBackground];
//        }
//    }];
    
//    PFQuery *innerQuery = [PFQuery queryWithClassName:@"Vehicle"];
//    [innerQuery whereKeyExists:@"plate_number"];
//    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
//    [query whereKey:@"parent" matchesQuery:innerQuery];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        for (PFObject *location in objects) {
//            PFObject *vehicle = location[@"parent"];
//            NSLog(@"%@", vehicle);
//        }
//    }];
//    PFObject *newVehicle = [PFObject objectWithClassName:@"Vehicle"];
//    newVehicle[@"model"] = @"toyota innova";
//    newVehicle[@"plate_number"] = @"KGV37UAB";
//    newVehicle[@"type"] = @"basic";
//    newVehicle[@"year"] = @"2010";
//    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:1.3330657 longitude:103.74365699999998];
//    [newVehicle setObject:point forKey:@"location"];
//    [newVehicle saveInBackground];
    
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//            PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
//            [query whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:3.0];
//            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                NSLog(@"%lu", (unsigned long)[objects count]);
//                for (PFObject *vehicle in objects) {
//                    NSLog(@"%@ %@, distance: %f", vehicle[@"model"], vehicle[@"plate_number"], [geoPoint distanceInKilometersTo:vehicle[@"location"]]);
//                    
//                }
//            }];
//        }else {
//            NSLog(@"Unable to get user's current location");
//        }
//    }];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        for (PFObject *vehicle in objects) {
//            NSLog(@"%@", vehicle);
//            PFRelation *relation = [vehicle relationForKey:@"rental_rates"];
//            NSDictionary *rates = @{@1: @70000,
//                                    @2: @140000,
//                                    @3: @200000,
//                                    @4: @250000,
//                                    @5: @300000,
//                                    @8: @400000,
//                                    @12: @500000,
//                                    @24: @600000};
//            
//            for (NSNumber *key in [rates allKeys]) {
//                PFObject *rate = [PFObject objectWithClassName:@"Rate"];
//                int keyInt = [key intValue];
//                NSNumber *value = rates[@(keyInt)];
//                
//                rate[@"hour"] = @([key intValue]);
//                rate[@"price"] = @([value intValue]);
//                [rate saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    if (succeeded) {
//                        [relation addObject:rate];
//                        [vehicle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                            NSLog(@"Created rate for vehicle: %@", [vehicle objectId]);
//                        }];
//                    }
//                }];
//                
//            }
//        }
//    }];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
//    PFQuery *pushQuery = [PFInstallation query];
//    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
//    
//    [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:@"Hello World!"];
    
    return YES;

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentINstallation = [PFInstallation currentInstallation];
    [currentINstallation setDeviceTokenFromData:deviceToken];
    [currentINstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];

}
// Location Manager
// =================================================================

- (void)intializeLocationManager
{
    if ([self locationManager] == nil) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
}

// Load navigation view controller if authorized, error view controller otherwise.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];

    UIViewController *viewController;
    if (status == kCLAuthorizationStatusAuthorized) {
        NSLog(@"User location Authorized: going to Navigation view controller");
        viewController = (NavigationViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    }else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"User location Unauthorized: going to Error view controller");
        viewController = (ErrorViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"ErrorController"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Warning" message: @"Please enable location services" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [self.window setRootViewController:viewController];
}

@end
