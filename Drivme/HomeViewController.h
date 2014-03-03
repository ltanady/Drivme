//
//  HomeViewController.h
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "PinButton.h"
#import "HMSegmentedControl.h"

@interface HomeViewController : ViewController <CLLocationManagerDelegate, GMSMapViewDelegate, UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

// Outlets
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinnerView;
@property (strong, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (strong, nonatomic) IBOutlet PinButton *pickupLocationButton;
@property (strong, nonatomic) IBOutlet UIView *pickupLocationDetailView;
@property (strong, nonatomic) IBOutlet UIButton *pickupLocationDetailButton;
@property (strong, nonatomic) IBOutlet UILabel *pickupLocationAddressLabel;
@property (strong, nonatomic) IBOutlet UIView *pickupLocationAddressView;
@property (strong, nonatomic) IBOutlet UIView *bottomDetailView;
@property (strong, nonatomic) HMSegmentedControl *carserviceTypeControl;
@property (strong, nonatomic) IBOutlet UIView *hourView;
@property (strong, nonatomic) IBOutlet UIPickerView *hourPickerView;
@property (strong, nonatomic) NSArray *hourArray;
@property (strong, nonatomic) IBOutlet UIButton *hourButton;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UILabel *quoteLabel;
@property (strong, nonatomic) IBOutlet UIButton *pickupTimeButton;
@property (strong, nonatomic) IBOutlet UIView *pickupTimeView;
@property (strong, nonatomic) IBOutlet UIDatePicker *pickupTimeDatePickerView;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

// Actions
- (IBAction)currentLocationButtonPressed:(id)sender;
- (IBAction)pickupLocationDetailButtonPressed:(id)sender;
- (IBAction)hourButtonPressed:(id)sender;
- (IBAction)hourDoneButtonPressed:(id)sender;
- (IBAction)hourCancelButtonPressed:(id)sender;
- (IBAction)pickupTimeButtonPressed:(id)sender;
- (IBAction)pickupTimeDoneButtonPressed:(id)sender;
- (IBAction)pickupTimeCancelButtonPressed:(id)sender;
- (IBAction)confirmButtonPressed:(id)sender;


@end
