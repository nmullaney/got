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
#import "GOTUser.h"
#import "GOTUserStore.h"

#import "GOTUsernameUpdateViewController.h"
#import "GOTEmailUpdateViewController.h"
#import "GOTLocationUpdateViewController.h"
#import "GOTConstants.h"
#import "GOTWebViewController.h"

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
    
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:TRUE];
    
    // Attempt to fill in user data that may be stale
    if ([GOTActiveUser activeUser]) {
        [self displayUserData:[GOTActiveUser activeUser]];
    }
    
    // Refresh the user
    NSArray *extraFields = [NSArray arrayWithObject:@"pending_email"];
    [[GOTUserStore sharedStore] fetchActiveUserWithExtraFields:extraFields
                                                withCompletion:^(GOTActiveUser *user, NSError *err) {
                                                    
        if (err) {
            NSString *errorString = [NSString stringWithFormat:@"Failed to refresh user: %@",
                                     [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
            return;
        }
        [self displayUserData:user];
    }];
}

- (void)displayUserData:(GOTActiveUser *)user
{
    [username setText:[user username]];
    [email setText:[user email]];
    [self setUserMapAnnotation:user];
    [karmaLabel setText:[[user karma] stringValue]];
}

- (void)setUserMapAnnotation:(GOTActiveUser *)user
{
    [mapView removeAnnotations:[mapView annotations]];
    CLLocationCoordinate2D userCoordinate =
    CLLocationCoordinate2DMake([[user latitude] doubleValue], [[user longitude] doubleValue]);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:userCoordinate];
    [mapView addAnnotation:annotation];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(userCoordinate, 1000, 1000)];
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
    GOTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate logout];
}

- (IBAction)aboutButtonPressed:(id)sender {
    NSURL *url = [NSURL URLWithString:@"/about.php?nonavbar=1" relativeToURL:[GOTConstants baseWebURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    GOTWebViewController *wvc = [[GOTWebViewController alloc] initWithURLRequest:request];
    [[wvc navigationItem] setTitle:@"About"];
    [wvc setHidesBottomBarWhenPushed:YES];
    [[self navigationController] pushViewController:wvc animated:YES];
}

@end
