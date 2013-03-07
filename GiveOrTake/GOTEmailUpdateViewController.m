//
//  GOTEmailUpdateViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTEmailUpdateViewController.h"

#import "GOTUserStore.h"
#import "GOTUser.h"

@implementation GOTEmailUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *currentEmail = [[[GOTUserStore sharedStore] activeUser] emailAddress];
    [emailField setText:currentEmail];
}

- (IBAction)updateEmail:(id)sender
{
    // We need to make sure we get the flow here correct, so we're not
    // spamming people.
    // I'm thinking send out a 4-5 digit code to the new email.
    // ask the user to type it in.  If it's correct, the email is update.
    NSLog(@"Update email: TODO");
}

@end
