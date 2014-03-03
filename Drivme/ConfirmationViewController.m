//
//  ConfirmationViewController.m
//  Drivme
//
//  Created by Leo Tanady on 21/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "ConfirmationViewController.h"
#import "AppDelegate.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface ConfirmationViewController ()

@end
@implementation ConfirmationViewController {
    CLLocationManager *locationManager;
    
}
@synthesize order, googleMapView, informationView, vehicleModelLabel, vehiclePlateNumberLabel, pickupTimeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    locationManager = [APP_DELEGATE locationManager];
    [locationManager setDelegate:self];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude
                                                            longitude:locationManager.location.coordinate.longitude
                                                                 zoom:14];

    [googleMapView setCamera:camera];
    [googleMapView setMyLocationEnabled:YES];
    
    // Create marker for pick up location
    PFGeoPoint *pickupGeoPoint = [order objectForKey:@"pickup_location"];
    CLLocationCoordinate2D pickupCoordinate = CLLocationCoordinate2DMake(pickupGeoPoint.latitude, pickupGeoPoint.longitude);
    GMSMarker *pickupMarker = [GMSMarker markerWithPosition:pickupCoordinate];
    [pickupMarker setTitle:@"Pickup Location"];
    [pickupMarker setMap:googleMapView];
    
    // Create assigned vehicle location
    PFObject *vehicle = [order objectForKey:@"assigned_vehicle"];
    PFGeoPoint *vehicleGeoPoint = [vehicle objectForKey:@"location"];
    CLLocationCoordinate2D vehicleCoordinate = CLLocationCoordinate2DMake(vehicleGeoPoint.latitude, vehicleGeoPoint.longitude);
    GMSMarker *vehicleMarker = [GMSMarker markerWithPosition:vehicleCoordinate];
    [vehicleMarker setTitle:@"Assigned Vehicle"];
    [vehicleMarker setIcon:[UIImage imageNamed:@"vehicle"]];
    [vehicleMarker setMap:googleMapView];
    
    [self.view addSubview:informationView];
    [vehicleModelLabel setText:[vehicle objectForKey:@"model"]];
    [vehiclePlateNumberLabel setText:[vehicle objectForKey:@"plate_number"]];
    [pickupTimeLabel setText:[NSString stringWithFormat:@"Pickup Time: %@", [self formatPickUpTime:[order objectForKey:@"pickup_date"]]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)quoteToFormattedString:(NSNumber *)quote
{
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber: quote];
    
    return numberString;
}

- (NSString *)formatPickUpTime:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *timeString = [timeFormatter stringFromDate:date];
    NSString *pickupTimeString = [NSString stringWithFormat:@"%@, %@", dateString, timeString];
    
    NSLog(@"Pick up time string: %@", pickupTimeString);
    return pickupTimeString;
}

@end
