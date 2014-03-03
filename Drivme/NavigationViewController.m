//
//  NavigationViewController.m
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "NavigationViewController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"

@interface NavigationViewController ()

@property (strong, readwrite, nonatomic) REMenu *menu;

@end

@implementation NavigationViewController

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
    
    __typeof (self) __weak weakSelf = self;
    
    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"Icon_Home"] highlightedImage:nil action:^(REMenuItem *item) {
        [weakSelf setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"]] animated:NO];
    }];
    
    REMenuItem *profileItem = [[REMenuItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"Icon_Profile"] highlightedImage:nil action:^(REMenuItem *item) {
        NSLog(@"Item: %@", item);
        [weakSelf setViewControllers:@[[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileController"]] animated:NO];
    
    }];
    
    self.menu = [[REMenu alloc] initWithItems:@[homeItem, profileItem]];
    [self.menu setLiveBlur:YES];
    [self.menu setLiveBlurBackgroundStyle:REMenuLiveBackgroundStyleLight];
    [self.menu setBounce:NO];
    [self.menu setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:17.0]];
    [self.menu setTextColor:[UIColor darkGrayColor]];
    [self.menu setAppearsBehindNavigationBar:NO];
    [self.menu setBorderWidth:1.0];
    [self.menu setBorderColor:[UIColor lightGrayColor]];
    [self.menu setItemHeight:50];
    [self.menu setSeparatorColor:[UIColor lightGrayColor]];
    [self.menu setSeparatorColor:nil];
    [self.menu setHighlightedSeparatorColor:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleMenu
{
    if (self.menu.isOpen) {
        return [self.menu close];
    }
    
    [self.menu showFromNavigationController:self];
}

@end
