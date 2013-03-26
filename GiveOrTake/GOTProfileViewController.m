//
//  GOTProfileViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTProfileViewController.h"

#import "GOTAppDelegate.h"
#import "GOTUserStore.h"
#import "GOTUser.h"

@implementation GOTProfileViewController

- (void)loadView
{
    [super loadView];
    [[self navigationItem] setTitle:@"Profile"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Refresh the user
    [[GOTUserStore sharedStore] fetchUserWithUserID:[[GOTUserStore sharedStore] activeUserID] withFacebookID:nil withCompletion:^(id user, NSError *err) {
        [username setText:[user username]];
        [email setText:[user emailAddress]];
        
        [mapView removeAnnotations:[mapView annotations]];
        CLLocationCoordinate2D userCoordinate =
        CLLocationCoordinate2DMake([[user latitude] doubleValue], [[user longitude] doubleValue]);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:userCoordinate];
        [mapView addAnnotation:annotation];
        [mapView setMapType:MKMapTypeStandard];
        [mapView setRegion:MKCoordinateRegionMakeWithDistance(userCoordinate, 1000, 1000)];
        [mapView setZoomEnabled:TRUE];
        
        [karmaLabel setText:[[user karma] stringValue]];
    }];
}

- (IBAction)karmaInfoPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Karma"
                              message:@"Everyone starts with 100 points of karma.  You can get more karma by posting, giving, or taking items.  You might lose karma if you fail to pick something up after you've agree to."
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)logout:(id)sender {
    NSLog(@"logout");
    GOTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate logout];
}
@end
