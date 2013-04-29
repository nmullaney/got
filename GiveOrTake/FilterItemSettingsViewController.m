//
//  FilterItemSettingsViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "FilterItemSettingsViewController.h"
#import "GOTSettings.h"

@implementation FilterItemSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"Initting new Filter item settings view");
        [self setFilterChanged:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    UILabel *magnifyingGlass = [[UILabel alloc] init];
    [magnifyingGlass setText:[[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"]];
    [magnifyingGlass sizeToFit];
    
    [searchField setLeftView:magnifyingGlass];
    [searchField setLeftViewMode:UITextFieldViewModeAlways];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int startDistance = [self getCurrentDistance];
    [self updateDistanceToValue:startDistance];
}

- (IBAction)searchChanged:(id)sender {
    NSLog(@"searchChanged");
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GOTSettings instance] setIntValue:[self roundDistanceValue]
                                 forKey:[GOTSettings distanceKey]];
    [GOTSettings synchronize];
}

@end
