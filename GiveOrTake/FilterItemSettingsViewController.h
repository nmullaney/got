//
//  FilterItemSettingsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterItemSettingsViewController : UITableViewController
{
    __weak IBOutlet UISlider *distanceSlider;
    __weak IBOutlet UILabel *distanceLabel;
}

- (IBAction)distanceChanged:(id)sender;
- (void)updateDistanceToValue:(int)value;
- (int)roundDistanceValue;

@end
