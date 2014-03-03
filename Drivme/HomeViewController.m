//
//  HomeViewController.m
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import "NavigationViewController.h"
#import "ConfirmationViewController.h"

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface HomeViewController ()

@end

@implementation HomeViewController {
    CLLocationManager *locationManager;
    BOOL isFirstTime;
    BOOL isConfirmation;
    BOOL isTimePickerViewFirstTime;
    UIBarButtonItem *menuButtonItem;
    NSInteger previousSelectedRow;
    
    NSNumber *initialQuote;
    PFObject *finalVehicle;
    PFObject *finalOrder;
    
    
}
@synthesize loadingSpinnerView, googleMapView, pickupLocationButton, pickupLocationDetailView,pickupLocationDetailButton, pickupLocationAddressLabel, pickupLocationAddressView, bottomDetailView, carserviceTypeControl;

@synthesize hourButton, hourView, hourPickerView, hourArray;

@synthesize quoteView, quoteLabel, pickupTimeView, pickupTimeDatePickerView, pickupTimeButton, confirmButton;

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
    NSLog(@"Home View Controller");
    locationManager = [APP_DELEGATE locationManager];
    [locationManager setDelegate:self];
    
    //self.title = @"Home";
    //[self.navigationItem setTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"taxi"]]];
    [self setTitle:@"Car Service"];
    
    isFirstTime = YES;
    isConfirmation = NO;
    isTimePickerViewFirstTime = YES;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude
                                                            longitude:locationManager.location.coordinate.longitude
                                                                 zoom:12];
    [googleMapView setCamera: camera];
    [googleMapView setMyLocationEnabled:YES];
    
    // Add pickup location address view
    [pickupLocationAddressView setTag:100];
    [googleMapView addSubview:pickupLocationAddressView];
    
    // Add pickup location pin button
    [pickupLocationButton setTag:200];
    [googleMapView addSubview:pickupLocationButton];
    
    // Add pickup location detail view
    [pickupLocationDetailView setTag:300];
    [googleMapView addSubview:pickupLocationDetailView];
    
    // Add bottom detail view (service type segmented control)
    [bottomDetailView setTag:400];
    [googleMapView addSubview:bottomDetailView];
    
    UIPanGestureRecognizer *pinDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePickupLocationButtonDrag:)];
    [pinDrag setDelegate:self];
    [googleMapView addGestureRecognizer:pinDrag];
    
    UITapGestureRecognizer *googleMapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGoogleMapTap:)];
    [googleMapTap setNumberOfTapsRequired:1];
    [googleMapTap setEnabled:NO];
    [googleMapTap setDelegate:self];
    [googleMapView addGestureRecognizer:googleMapTap];
    
    // Add segmented control for car service type
    carserviceTypeControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Basic", @"Premium", @"Luxury"]];
    [carserviceTypeControl setSelectionStyle:HMSegmentedControlSelectionStyleFullWidthStripe];
    [carserviceTypeControl setSelectionIndicatorColor:[UIColor colorWithRed:0.0/255.0 green:213.0/255.0 blue:161.0/255.0 alpha:1]];
    [carserviceTypeControl setSelectedTextColor:[UIColor colorWithRed:0.0/255.0 green:146.0/255.0 blue:111.0/255.0 alpha:1]];
    [carserviceTypeControl setFrame:CGRectMake(0.0, 0.0, 250.0, 78.0)];
    [carserviceTypeControl addTarget:self action:@selector(carserviceTypeControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [bottomDetailView addSubview:carserviceTypeControl];
    
    // Add hour button, hourview.
    [hourButton setBackgroundColor:[UIColor whiteColor]];
    hourArray = [[NSArray alloc] initWithObjects:@"Select number of hours", @1, @2, @3, @4, @5, @8, @12, @24, nil];
    [hourView setTag:500];
    [self.view addSubview:hourView];
    [hourView setHidden:YES];
    
    // Add spinner
    [self.view addSubview:loadingSpinnerView];
    
    // Add quotation view
    [quoteView.layer setCornerRadius:4.0];
    [quoteView.layer setMasksToBounds:NO];
    [quoteView.layer setShadowColor:[UIColor blackColor].CGColor];
    [quoteView.layer setShadowOffset:CGSizeMake(0.2, 0.2)];
    [quoteView.layer setShadowOpacity:0.2];
    [googleMapView addSubview:quoteView];
    [quoteView setHidden:YES];
    
    // Add date picker view
    [pickupTimeView setTag:600];
    [self.view addSubview:pickupTimeView];
    [pickupTimeView setHidden:YES];
    
    // Add confirm button
    [googleMapView addSubview:confirmButton];
    [confirmButton setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Get the latest updated user's location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    // Animate the camera view for the first time
    if (isFirstTime) {
        pickupLocationButton.latitude = location.coordinate.latitude;
        pickupLocationButton.longitude = location.coordinate.longitude;
        CGPoint pt = [googleMapView.projection pointForCoordinate:location.coordinate];
        [pickupLocationButton setFrame:CGRectMake(pt.x, pt.y, 14, 37)];
        [pickupLocationButton setCenter:CGPointMake(pt.x, pt.y - pickupLocationButton.frame.size.height / 2 )];
        
        //[pickupLocationLabel setCenter:CGPointMake(pt.x, pt.y - 50)];
        [pickupLocationDetailView setCenter:CGPointMake(pt.x, pt.y - 70)];
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location.coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
            if (error == nil) {
                GMSReverseGeocodeResult *result = response.firstResult;
                pickupLocationAddressLabel.text = [NSString stringWithFormat:@"%@", result.addressLine1];
                //NSLog(@"%@, %@", result.addressLine1, result.addressLine2);
            }
        }];
        [self showNearbyVehicles:location.coordinate];
        isFirstTime = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        NSLog(@"Home view controller Authorized");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

// Current location button pressed, animate to the user's current location
- (IBAction)currentLocationButtonPressed:(id)sender
{
    CLLocation *location = googleMapView.myLocation;
    if (location) {
        [googleMapView animateToLocation:location.coordinate];
    }
}

// During confirmation, hide some views and zoom to the location, change the menu button to cancel button.
- (IBAction)pickupLocationDetailButtonPressed:(id)sender
{
    NSLog(@"Pickup location detail button pressed");
    
    NSLog(@"%ld", (long)[hourPickerView selectedRowInComponent:0]);
    if ([hourPickerView selectedRowInComponent:0] > 0) {
        isConfirmation = YES;
        isTimePickerViewFirstTime = YES;
        
        [loadingSpinnerView startAnimating];
        
        CGPoint center = googleMapView.center;
        CLLocationCoordinate2D centerCoord = [googleMapView.projection coordinateForPoint:center];
        
        PFGeoPoint *currentGeoPoint = [PFGeoPoint geoPointWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
        PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
        [query whereKey:@"location" nearGeoPoint:currentGeoPoint withinKilometers:3.0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && [objects count] > 0) {
                PFObject *nearestVehicle = [objects firstObject];
                if (nearestVehicle) {
                    PFRelation *ratesRelation = [nearestVehicle relationForKey:@"rental_rates"];
                    PFQuery *vehicleRatesQuery = [ratesRelation query];
                    [vehicleRatesQuery findObjectsInBackgroundWithBlock:^(NSArray *rates, NSError *error) {
                        if (!error && [rates count] > 0) {
                            [loadingSpinnerView stopAnimating];
//                            NSNumber *quote = nearestVehicle[@"additional_hourly_rate"];
                            NSInteger hour = [[hourArray objectAtIndex:[hourPickerView selectedRowInComponent:0]] integerValue];
                            PFObject *rate = [self getRate:rates forHour:hour];
                            NSNumber *quote = rate[@"price"];
                            initialQuote = quote;
                            
                            // assign nearest vehicle
                            finalVehicle = nearestVehicle;
                            
                            // Reset the pick up time button title
                            [pickupTimeButton setTitle:@"Set Pickup Time" forState:UIControlStateNormal];
                            
                            // Hide the subviews
                            [pickupLocationDetailView setAlpha:0.0];
                            [bottomDetailView setAlpha:0.0];
                            [quoteView setAlpha:0.0];
                            [confirmButton setAlpha:0.0];
                            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            } completion:^(BOOL finished) {
                                NSLog(@"Done hiding bottom detail view");
                                [UIView animateWithDuration:0.5 animations:^{
                                    [pickupLocationDetailView setAlpha:1.0];
                                    [pickupLocationDetailView setHidden:YES];
                                    [bottomDetailView setAlpha:1.0];
                                    [bottomDetailView setHidden:YES];
                                    
                                    [quoteView setAlpha:1.0];
                                    [quoteView setHidden:NO];
                                    [quoteLabel setText:[NSString stringWithFormat:@"Rp %@", [self quoteToFormattedString:quote]]];
                                    
                                    [confirmButton setAlpha:1.0];
                                    [confirmButton setHidden:NO];
                                    
                                }];
                            }];
                            
                            // Zoom google map camera in
                            [googleMapView animateToZoom:18];
                            
                            // Keep pointer to the menu button item before setting to cancel button item
                            menuButtonItem = [self.navigationItem leftBarButtonItem];
                            UIBarButtonItem *cancelComfirmationButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelConfirmation:)];
                            [cancelComfirmationButtonItem setTintColor:[UIColor whiteColor]];
                            [self.navigationItem setLeftBarButtonItem:cancelComfirmationButtonItem];
                        
                        } else {
                            NSLog(@"Rates null");
                        }
                        
                    }];
                    
                    
                } else {
                    NSLog(@"Nearest vehicle null");
                }
            }
        }];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"# Hours not selected"
                                                        message:@"Please select the number of hours."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)hourButtonPressed:(id)sender {
    // Enable single tap gesture
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:YES];
    
    // Unhide hour view with fading animation, but hide the location detail view.
    [hourView setAlpha:0.0];
    [pickupLocationDetailView setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done unhiding hour view");
        [UIView animateWithDuration:0.5 animations:^{
            [hourView setAlpha:1.0];
            [hourView setHidden:NO];
            [pickupLocationDetailView setAlpha:1.0];
            [pickupLocationDetailView setHidden:YES];
            
        }];
    }];
    
    // If there is selected row then the hour picker select that row, select mid element otherwise.
    if ([hourPickerView selectedRowInComponent:0]) {
        [hourPickerView selectRow:[hourPickerView selectedRowInComponent:0] inComponent:0 animated:YES];
    } else {
        [hourPickerView selectRow:0 inComponent:0 animated:YES];
    }
    
}

- (IBAction)hourDoneButtonPressed:(id)sender {
    // Disable single tap gesture
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:NO];
    
    // Set the hour button title
    NSInteger selectedRowIndex = [hourPickerView selectedRowInComponent:0];
    previousSelectedRow = selectedRowIndex;
    NSString *selectedRowString = hourArray[selectedRowIndex];
    [UIView setAnimationsEnabled:NO];
    if (selectedRowIndex == 0) {
        [hourButton setTitle:[NSString stringWithFormat:@"# Hrs"] forState:UIControlStateNormal];
    } else if (selectedRowIndex == 1) {
        [hourButton setTitle:[NSString stringWithFormat:@"%@ Hr", selectedRowString] forState:UIControlStateNormal];
    } else {
        [hourButton setTitle:[NSString stringWithFormat:@"%@ Hrs", selectedRowString] forState:UIControlStateNormal];
    }
    [UIView setAnimationsEnabled:YES];
    
    // Hide hour view with fading animation, but unhide the location detail view.
    [hourView setAlpha:0.0];
    [pickupLocationDetailView setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done hiding hour view");
        [UIView animateWithDuration:0.5 animations:^{
            [hourView setAlpha:1.0];
            [hourView setHidden:YES];
            [pickupLocationDetailView setAlpha:1.0];
            [pickupLocationDetailView setHidden:NO];
            
        }];
    }];

}

- (IBAction)hourCancelButtonPressed:(id)sender {
    // Disable single tap gesture
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:NO];
    
    // Set the hour button title
    NSInteger selectedRowIndex = [hourPickerView selectedRowInComponent:0];
    // Previously selected row takes precedence
    if (previousSelectedRow != selectedRowIndex) {
        selectedRowIndex = previousSelectedRow;
    }
    NSString *selectedRowString = hourArray[selectedRowIndex];
    [UIView setAnimationsEnabled:NO];
    if (selectedRowIndex == 0) {
        [hourButton setTitle:[NSString stringWithFormat:@"# Hrs"] forState:UIControlStateNormal];
    } else if (selectedRowIndex == 1) {
        [hourButton setTitle:[NSString stringWithFormat:@"%@ Hr", selectedRowString] forState:UIControlStateNormal];
    } else {
        [hourButton setTitle:[NSString stringWithFormat:@"%@ Hrs", selectedRowString] forState:UIControlStateNormal];
    }
    [UIView setAnimationsEnabled:YES];
    
    // Hide hour view with fading animation, but unhide the location detail view.
    [hourView setAlpha:0.0];
    [pickupLocationDetailView setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done hiding hour view");
        [UIView animateWithDuration:0.5 animations:^{
            [hourView setAlpha:1.0];
            [hourView setHidden:YES];
            [pickupLocationDetailView setAlpha:1.0];
            [pickupLocationDetailView setHidden:NO];
            
        }];
    }];
}

- (IBAction)pickupTimeButtonPressed:(id)sender
{
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:YES];
    
    // Set the time to current for the first time
    if (isTimePickerViewFirstTime) {
        [pickupTimeDatePickerView setDate:[NSDate new]];
        isTimePickerViewFirstTime = NO;
    }
    
    // Restrict minimum date to current
    [pickupTimeDatePickerView setMinimumDate:[NSDate new]];
    
    NSLog(@"Pick up time: %@", [pickupTimeDatePickerView date]);
    
    NSLog(@"isConfirmatin: %d", isConfirmation);
    // Unhide pick up time with fading animation
    [pickupTimeView setAlpha:0.0];
    [confirmButton setAlpha:0.0];
    [pickupLocationDetailView setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done unhiding pick up time view");
        [UIView animateWithDuration:0.5 animations:^{
            [pickupTimeView setAlpha:1.0];
            [pickupTimeView setHidden:NO];
            
            [confirmButton setAlpha:1.0];
            [confirmButton setHidden:YES];
            
            [pickupLocationDetailView setAlpha:1.0];
            [pickupLocationDetailView setHidden:YES];
        }];
    }];
}

- (IBAction)pickupTimeDoneButtonPressed:(id)sender {
    
    // Disable single tap gesture
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:NO];
    
    // Set pick up time button title
    [UIView setAnimationsEnabled:NO];
    [pickupTimeButton setTitle:[self formatPickUpTime:[pickupTimeDatePickerView date]] forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];
    
    // Hide pick up time view with fading animation
    [pickupTimeView setAlpha:0.0];
    [confirmButton setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done hiding pick up time view");
        [UIView animateWithDuration:0.5 animations:^{
            [pickupTimeView setAlpha:1.0];
            [pickupTimeView setHidden:YES];
            
            [confirmButton setAlpha:1.0];
            [confirmButton setHidden:NO];
        }];
    }];
    
}

- (IBAction)pickupTimeCancelButtonPressed:(id)sender {
    
    // Disable single tap gesture
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:NO];
    
    // Hide pick up time view with fading animation
    [pickupTimeView setAlpha:0.0];
    [confirmButton setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done hiding hour view");
        [UIView animateWithDuration:0.5 animations:^{
            [pickupTimeView setAlpha:1.0];
            [pickupTimeView setHidden:YES];
            
            [confirmButton setAlpha:1.0];
            [confirmButton setHidden:NO];
        }];
    }];
    
}

- (IBAction)confirmButtonPressed:(id)sender {
    if ([pickupTimeButton.titleLabel.text isEqualToString:@"Set Pickup Time"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Pickup Time not selected"
                                                        message:@"Please select the pickup time."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        NSInteger selectedRow = [hourPickerView selectedRowInComponent:0];
        NSInteger initialHour = selectedRow != 0 ? [[hourArray objectAtIndex:selectedRow] integerValue] : 1;
        NSDate *finalPickupDate = [pickupTimeDatePickerView date];
        CGPoint center = googleMapView.center;
        CLLocationCoordinate2D centerCoord = [googleMapView.projection coordinateForPoint:center];
        PFGeoPoint *finalPickupGeoPoint = [PFGeoPoint geoPointWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
        
        // Save to Parse
        PFObject *newOrder = [[PFObject alloc] initWithClassName:@"Order"];
        [newOrder setObject:[NSNumber numberWithInteger:initialHour] forKey:@"initial_hour"];
        [newOrder setObject:initialQuote forKey:@"initial_quote"];
        [newOrder setObject:finalPickupDate forKey:@"pickup_date"];
        [newOrder setObject:finalPickupGeoPoint forKey:@"pickup_location"];
        [newOrder setObject:finalVehicle forKey:@"assigned_vehicle"];
        
        [loadingSpinnerView startAnimating];
        
        [newOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                if (succeeded) {
                    finalOrder = newOrder;
                    [loadingSpinnerView stopAnimating];
                    [self performSegueWithIdentifier:@"confirmationSegue" sender:self];
                
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Unable to order car service"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:error.description
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
        }];
        
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"confirmationSegue"]) {
        NSLog(@"Confirmation segue");
        
        NavigationViewController *navigationViewController = [segue destinationViewController];
        ConfirmationViewController *confirmationViewController = (ConfirmationViewController *)[navigationViewController topViewController];
        
        [confirmationViewController setOrder:finalOrder];
    
    }
}

// On cancel confirmation, restore the previously hidden views, change the cancel button to menu button
- (IBAction)cancelConfirmation:(id)sender
{
    NSLog(@"Cancel confirmation");
    if (menuButtonItem) {
        [self.navigationItem setLeftBarButtonItem:menuButtonItem];
    }
    
    // Unhide the subviews
    [pickupLocationDetailView setAlpha:0.0];
    [bottomDetailView setAlpha:0.0];
    [quoteView setAlpha:0.0];
    [pickupTimeView setAlpha:0.0];
    [confirmButton setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done hiding bottom detail view");
        [UIView animateWithDuration:0.5 animations:^{
            [pickupLocationDetailView setAlpha:1.0];
            [pickupLocationDetailView setHidden:NO];
            [bottomDetailView setAlpha:1.0];
            [bottomDetailView setHidden:NO];
            
            [quoteView setAlpha:1.0];
            [quoteView setHidden:YES];
            [pickupTimeView setAlpha:1.0];
            [pickupTimeView setHidden:YES];
            [confirmButton setAlpha:1.0];
            [confirmButton setHidden:YES];
        }];
    }];
    
}

- (void)handleGoogleMapTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"Google Map tap");
    
    // Disable single tap gesture after handling
    UITapGestureRecognizer *googleMapTap = [googleMapView.gestureRecognizers lastObject];
    [googleMapTap setEnabled:NO];
    
    [hourView setAlpha:0.0];
    [pickupTimeView setAlpha:0.0];
    [confirmButton setAlpha:0.0];
    [pickupLocationDetailView setAlpha:0.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
    } completion:^(BOOL finished) {
        NSLog(@"Done unhiding location detail view");
        [UIView animateWithDuration:0.5 animations:^{
            
            // User is in hour view
            if (![hourView isHidden]) {
                [hourView setAlpha:1.0];
                [hourView setHidden:YES];
                
                [pickupLocationDetailView setAlpha:1.0];
                [pickupLocationDetailView setHidden:NO];
            
                
            } else if (![pickupTimeView isHidden]) {     // User is in pick up time view
                [pickupTimeView setAlpha:1.0];
                [pickupTimeView setHidden:YES];
                
                [confirmButton setAlpha:1.0];
                [confirmButton setHidden:NO];
                
            }
            
        }];
    }];
    
}

// When the user drags the pin button, hide the bottom detail view, update the address with reverse geocode
- (void)handlePickupLocationButtonDrag:(UIPanGestureRecognizer *)sender
{
    NSLog(@"Pick up location button drag");
    
    CGPoint center = googleMapView.center;
    CLLocationCoordinate2D centerCoord = [googleMapView.projection coordinateForPoint:center];
    
    // Hide bottom detail view when gesture began if not confirmation yet
    if (!isConfirmation) {
        [bottomDetailView setAlpha:0.0];
        if (sender.state == UIGestureRecognizerStateBegan) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            } completion:^(BOOL finished) {
                NSLog(@"Done hiding bottom detail view");
                [UIView animateWithDuration:0.5 animations:^{
                    [bottomDetailView setAlpha:1.0];
                    [bottomDetailView setHidden:YES];
                }];
            }];
            
        } else if (sender.state == UIGestureRecognizerStateEnded){
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            } completion:^(BOOL finished) {
                NSLog(@"Done unhiding bottom detail view");
                [UIView animateWithDuration:0.5 animations:^{
                    [bottomDetailView setAlpha:1.0];
                    [bottomDetailView setHidden:NO];
                }];
            }];
            [self showNearbyVehicles:centerCoord];
        }
    }

    // Reverse geocode to get address
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:centerCoord completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        [pickupLocationAddressLabel setAlpha:0.0];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        } completion:^(BOOL finished) {
            NSLog(@"Done hiding bottom detail view");
            [UIView animateWithDuration:0.5 animations:^{
                [pickupLocationAddressLabel setAlpha:1.0];
                if (error == nil) {
                    GMSReverseGeocodeResult *result = response.firstResult;
                    if ([result addressLine1]) {
                        [pickupLocationAddressLabel setText:[NSString stringWithFormat:@"%@", result.addressLine1]];
                    } else {
                        [pickupLocationAddressLabel setText:[NSString stringWithFormat:@"Address unavailable"]];
                    }
                } else {
                    [pickupLocationAddressLabel setText:@"Address unavailable"];
                }
            }];
        }];
        
    }];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)carserviceTypeControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    NSLog(@"Selected index %ld", (long) segmentedControl.selectedSegmentIndex);
}

// Perform request to parse to get the nearest vehicles within a certain radius in kilometers given a set of coordinate
- (void)showNearbyVehicles:(CLLocationCoordinate2D)currentCoordinate
{
    // Clear previous vehicle markers before putting new ones
    [googleMapView clear];
    PFGeoPoint *currentGeoPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
    PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
    [query whereKey:@"location" nearGeoPoint:currentGeoPoint withinKilometers:3.0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%lu", (unsigned long)[objects count]);
        for (PFObject *vehicle in objects) {
            NSLog(@"%@ %@, distance: %f", vehicle[@"model"], vehicle[@"plate_number"], [currentGeoPoint distanceInKilometersTo:vehicle[@"location"]]);
            PFGeoPoint *vehicleLocation = vehicle[@"location"];
            CLLocationCoordinate2D vehicleCoordinate = CLLocationCoordinate2DMake(vehicleLocation.latitude, vehicleLocation.longitude);
            GMSMarker *vehicleMarker = [GMSMarker markerWithPosition:vehicleCoordinate];
            [vehicleMarker setIcon:[UIImage imageNamed:@"vehicle"]];
            [vehicleMarker setMap:googleMapView];
        }
    }];
}

- (PFObject *)nearestVehicle:(CLLocationCoordinate2D)currentCoordinate
{
    CGPoint center = googleMapView.center;
    CLLocationCoordinate2D centerCoord = [googleMapView.projection coordinateForPoint:center];
    
    [googleMapView clear];
    __block PFObject *nearestVehicle = nil;
    PFGeoPoint *currentGeoPoint = [PFGeoPoint geoPointWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
    PFQuery *query = [PFQuery queryWithClassName:@"Vehicle"];
    [query whereKey:@"location" nearGeoPoint:currentGeoPoint withinKilometers:3.0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        nearestVehicle = [objects firstObject];
        NSLog(@"Nearest vehicle: %@", nearestVehicle);
    }];
    
    return nearestVehicle;
    
}

- (NSArray *)vehicleRates:(PFObject *)vehicle
{
    __block NSArray *vehicleRates = nil;
    PFRelation *ratesRelation = [vehicle relationForKey:@"rental_rates"];
    PFQuery *rentalRatesQuery = [ratesRelation query];
    [rentalRatesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            vehicleRates = objects;
        }
    }];
    return vehicleRates;
}

- (PFObject *)getRate:(NSArray *)rates forHour:(NSInteger)hour
{
    for (PFObject *rate in rates) {
        if (hour == [rate[@"hour"] integerValue]) {
            
            return rate;
        }
    }
    return nil;
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


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [hourArray count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 52.0;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, pickerView.frame.size.width, 50.0)];
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    //[label setTextColor:[UIColor colorWithRed:0.0/255.0 green:146.0/255.0 blue:111.0/255.0 alpha:1]];
    [label setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:22.0]];
    if (row == 0) {
        [label setText:[NSString stringWithFormat:@"%@", [self.hourArray objectAtIndex:row]]];
    } else if (row == 1){
        [label setText:[NSString stringWithFormat:@"%@ Hour", [self.hourArray objectAtIndex:row]]];
        
    } else {
        [label setText:[NSString stringWithFormat:@"%@ Hours", [self.hourArray objectAtIndex:row]]];
    }
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", (long)row);
    
}

@end
