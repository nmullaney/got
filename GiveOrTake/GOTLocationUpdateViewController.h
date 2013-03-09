//
//  GOTLocationUpdateViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/8/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GOTLocationUpdateViewController : UIViewController
    <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    
    __weak IBOutlet MKMapView *mapView;
}

- (IBAction)updateLocation:(id)sender;
- (IBAction)centerOnCurrentLocation:(id)sender;
- (IBAction)dropLocationPin:(id)sender;

@end
