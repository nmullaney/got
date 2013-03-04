//
//  GOTProfileViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTProfileViewController.h"

#import "GOTAppDelegate.h"

@implementation GOTProfileViewController

- (void)loadView
{
    [super loadView];
    [[self navigationItem] setTitle:@"Profile"];
}



- (IBAction)logout:(id)sender {
    NSLog(@"logout");
    GOTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate logout];
}
@end
