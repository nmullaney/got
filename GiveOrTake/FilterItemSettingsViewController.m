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
        [self setFilterChanged:NO];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int startDistance = [self getCurrentDistance];
    [self updateDistanceToValue:startDistance];
}

- (IBAction)distanceChanged:(id)sender {
    int value = [self roundDistanceValue];
    [self updateDistanceToValue:value];
    [self setFilterChanged:YES];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GOTSettings instance] setIntValue:[self roundDistanceValue]
                                 forKey:[GOTSettings distanceKey]];
    [GOTSettings synchronize];
}

@end
