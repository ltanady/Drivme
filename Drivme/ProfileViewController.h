//
//  ProfileViewController.h
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ProfileViewController : ViewController <CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *numberOfHoursPickerView;
@property (strong, nonatomic) NSArray *hourArray;

@end
