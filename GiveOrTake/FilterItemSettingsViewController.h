//
//  FilterItemSettingsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterItemSettingsViewController : UIViewController
{
    IBOutlet UIView *view;
    __weak IBOutlet UITextField *searchField;
    __weak IBOutlet UISlider *distanceSlider;
    __weak IBOutlet UILabel *distanceLabel;
    __weak IBOutlet UIButton *showItemsCheckBox;
}

@property (nonatomic) BOOL filterChanged;
- (IBAction)searchChanged:(id)sender;

- (IBAction)distanceChanged:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (void)updateDistanceToValue:(int)value;
- (int)roundDistanceValue;
- (NSString *)searchText;

- (BOOL)getCurrentShowItems;
- (BOOL)showMyItemsValue;
- (IBAction)showItemsChecked:(id)sender;

@end
