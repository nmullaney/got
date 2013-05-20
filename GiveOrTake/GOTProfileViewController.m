//
//  GOTProfileViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTProfileViewController.h"

#import "GOTAppDelegate.h"
#import "GOTActiveUser.h"
#import "GOTUserStore.h"

#import "GOTUsernameUpdateViewController.h"
#import "GOTEmailUpdateViewController.h"
#import "GOTLocationUpdateViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation GOTProfileViewController

- (void)loadView
{
    [super loadView];
    [[self navigationItem] setTitle:@"Profile"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [logoutButton setBackgroundColor:[UIColor redColor]];
    [logoutButton.titleLabel setTextColor:[UIColor whiteColor]];
    [logoutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    logoutButton.layer.cornerRadius = 8.0;
    
    // Refresh the user
    NSArray *extraFields = [NSArray arrayWithObject:@"pending_email"];
    [[GOTUserStore sharedStore] fetchActiveUserWithExtraFields:extraFields
                                                withCompletion:^(GOTActiveUser *user, NSError *err) {
                                         
        [username setText:[user username]];
        // TODO: bug is here
        [email setText:[user email]];
        
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if ([indexPath row] == 0) {
            GOTUsernameUpdateViewController *usernameUpdateVC = [[GOTUsernameUpdateViewController alloc] init];
            [[self navigationController] pushViewController:usernameUpdateVC animated:YES];
        }
        if ([indexPath row] == 1) {
            GOTEmailUpdateViewController *emailUpdateVC = [[GOTEmailUpdateViewController alloc] init];
            [[self navigationController] pushViewController:emailUpdateVC animated:YES];
        }
    } else if ([indexPath section] == 1) {
        GOTLocationUpdateViewController *locUpdateVC = [[GOTLocationUpdateViewController alloc] init];
        [[self navigationController] pushViewController:locUpdateVC animated:YES];
    }
    NSLog(@"Tapped accessory at: %@", indexPath);
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
