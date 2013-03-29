//
//  GOTProfileViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GOTProfileViewController : UITableViewController <UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
    __weak IBOutlet UILabel *username;
    __weak IBOutlet UILabel *email;
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UILabel *karmaLabel;
}


- (IBAction)karmaInfoPressed:(id)sender;

- (IBAction)logout:(id)sender;

@end
