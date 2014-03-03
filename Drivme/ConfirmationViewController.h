//
//  ConfirmationViewController.h
//  Drivme
//
//  Created by Leo Tanady on 21/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ConfirmationViewController : ViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) PFObject *order;
@property (strong, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (strong, nonatomic) IBOutlet UIView *informationView;
@property (strong, nonatomic) IBOutlet UILabel *vehicleModelLabel;
@property (strong, nonatomic) IBOutlet UILabel *vehiclePlateNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *pickupTimeLabel;

@end
