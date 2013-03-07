//
//  GOTProfileViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTProfileViewController.h"

#import "GOTAppDelegate.h"
#import "GOTUserStore.h"
#import "GOTUser.h"

@implementation GOTProfileViewController

- (void)loadView
{
    [super loadView];
    [[self navigationItem] setTitle:@"Profile"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    GOTUser *user = [[GOTUserStore sharedStore] activeUser];
    [username setText:[user username]];
    [email setText:[user emailAddress]];
}

- (IBAction)logout:(id)sender {
    NSLog(@"logout");
    GOTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate logout];
}
@end
