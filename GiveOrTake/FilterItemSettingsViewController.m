//
//  FilterItemSettingsViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "FilterItemSettingsViewController.h"
#import "GOTSettings.h"
#import "GOTConstants.h"
#import "UIBarButtonItem+FlatBarButtonItem.h"

#import <QuartzCore/QuartzCore.h>

@implementation FilterItemSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setFilterChanged:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [[self view] setBackgroundColor:[GOTConstants greenBackgroundColor]];
    UILabel *magnifyingGlass = [[UILabel alloc] init];
    [magnifyingGlass setText:[[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"]];
    [magnifyingGlass sizeToFit];
    
    [searchField setLeftView:magnifyingGlass];
    [searchField setLeftViewMode:UITextFieldViewModeAlways];
    
    [showItemsCheckBox setImage:[UIImage imageNamed:@"notchecked"] forState:UIControlStateNormal];
    [showItemsCheckBox setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateSelected];
    
    [filterButton setBackgroundColor:[GOTConstants actionButtonColor]];
    [filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    filterButton.layer.cornerRadius = 8.0;
    
    UIBarButtonItem *backButton = [UIBarButtonItem flatBackBarButtonItemForNavigationController:[self navigationController]];
    [[self navigationItem] setLeftBarButtonItem:backButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int startDistance = [self getCurrentDistance];
    [self updateDistanceToValue:startDistance];
    [showItemsCheckBox setSelected:[self getCurrentShowItems]];
}

- (IBAction)searchChanged:(id)sender {
    [self setFilterChanged:YES];
}

- (IBAction)distanceChanged:(id)sender {
    int value = [self roundDistanceValue];
    [self updateDistanceToValue:value];
    [self setFilterChanged:YES];
}

- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
}

- (void)updateDistanceToValue:(int)value
{
    NSString *distanceText = [NSString stringWithFormat:@"Miles: %d", value];
    [distanceLabel setText:distanceText];
    [distanceSlider setValue:value];
}

- (int)roundDistanceValue
{
    return lroundf([distanceSlider value]);
}

- (int)getCurrentDistance
{
    return [[GOTSettings instance] getIntValueForKey:[GOTSettings distanceKey]];
}

- (NSString *)searchText
{
    NSString *text = [searchField text];
    if ([text isEqualToString:@""]) {
        return nil;
    }
    return text;
}

- (BOOL)getCurrentShowItems
{
    return [[GOTSettings instance] getBoolValueForKey:[GOTSettings showMyItemsKey]];
}

- (IBAction)showItemsChecked:(id)sender {
    if ([showItemsCheckBox isSelected]) {
        [showItemsCheckBox setSelected:NO];
    } else {
        [showItemsCheckBox setSelected:YES];
    }
    [self setFilterChanged:YES];
}

- (IBAction)applyFilter:(id)sender {
    [self setFilterChanged:YES];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)showMyItemsValue
{
    return [showItemsCheckBox isSelected];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GOTSettings instance] setIntValue:[self roundDistanceValue]
                                 forKey:[GOTSettings distanceKey]];
    [[GOTSettings instance] setBoolValue:[self showMyItemsValue]
                                  forKey:[GOTSettings showMyItemsKey]];
    [GOTSettings synchronize];
}

@end
