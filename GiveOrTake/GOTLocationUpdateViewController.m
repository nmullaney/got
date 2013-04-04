//
//  GOTLocationUpdateViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/8/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTLocationUpdateViewController.h"

#import "GOTUserStore.h"
#import "GOTActiveUser.h"

@implementation GOTLocationUpdateViewController

- (void)viewDidLoad
{
    [mapView setDelegate:self];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    GOTActiveUser *user = [GOTActiveUser activeUser];
    
    [[self navigationItem] setTitle:@"Edit Location"];
    
    [mapView removeAnnotations:[mapView annotations]];
    CLLocationCoordinate2D userCoordinate =
        CLLocationCoordinate2DMake([[user latitude] doubleValue], [[user longitude] doubleValue]);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:userCoordinate];
    [mapView addAnnotation:annotation];
    [mapView setMapType:MKMapTypeStandard];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(userCoordinate, 1000, 1000)];
    [mapView setZoomEnabled:TRUE];
    [mapView setShowsUserLocation:YES];   
}

- (IBAction)updateLocation:(id)sender {
    MKPointAnnotation *annotation = [[mapView annotations] objectAtIndex:0];
    CLLocationCoordinate2D userCoordinate = [annotation coordinate];
    NSNumber *latitude = [NSNumber numberWithDouble:userCoordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble:userCoordinate.longitude];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:latitude,longitude,nil]
                                                       forKeys:[NSArray arrayWithObjects:@"latitude", @"longitude", nil]];
    
    [[GOTUserStore sharedStore] updateUserWithParams:params
                            withCompletion:^(GOTActiveUser *user, NSError *err) {
        if (err) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Failed to update location" message:[err localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        [[self navigationController] popViewControllerAnimated:YES];
    }];
}

- (IBAction)centerOnCurrentLocation:(id)sender {
    [locationManager startUpdatingLocation];
}

- (IBAction)dropLocationPin:(id)sender {

    UILongPressGestureRecognizer *gestureRecognizer = sender;
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        // Only respond to the final state
        return;
    }
    CGPoint dropPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D newLocation = [mapView convertPoint:dropPoint toCoordinateFromView:mapView];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:newLocation];
    // Remove previous pins
    [mapView removeAnnotations:[mapView annotations]];
    // Add the new pin
    [mapView addAnnotation:annotation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] == 0) {
        return;
    }
    CLLocation *currentLocation = [locations lastObject];

    [mapView setCenterCoordinate:[currentLocation coordinate]];
    [locationManager stopUpdatingLocation];
}

@end
