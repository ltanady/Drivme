//
//  ViewController.m
//  Drivme
//
//  Created by Leo Tanady on 12/2/14.
//  Copyright (c) 2014 Leo Tanady. All rights reserved.
//

#import "ViewController.h"
#import "NavigationViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.leftBarButtonItem.action = @selector(toggleMenu);    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
