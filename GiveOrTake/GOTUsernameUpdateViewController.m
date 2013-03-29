//
//  GOTUsernameUpdateViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTUsernameUpdateViewController.h"

#import "GOTUser.h"
#import "GOTUserStore.h"

@implementation GOTUsernameUpdateViewController

- (void)viewDidLoad
{
    NSString *currentUsername = [[[GOTUserStore sharedStore] activeUser] username];
    [usernameField setText:currentUsername];
    [[self navigationItem] setTitle:@"Edit Username"];
}

- (IBAction)updateUsername:(id)sender
{
    GOTUser *activeUser = [[GOTUserStore sharedStore] activeUser];
    if (![usernameField text] || [[usernameField text] length] < 6) {
        [errorLabel setText:@"Username must be at least 6 characters."];
        [errorLabel setHidden:NO];
        return;
    }
    [activeUser setUsername:[usernameField text]];
    
    [errorLabel setHidden:TRUE];
    [activityIndicator startAnimating];
    [[GOTUserStore sharedStore] updateUser:activeUser withCompletion:^(id user, NSError *err) {
        [activityIndicator stopAnimating];
        if (err) {
            NSLog(@"Error updating user's username: setting error");
            [errorLabel setText:[err localizedDescription]];
            [errorLabel setHidden:NO];
            [[GOTUserStore sharedStore] discardChanges];
        } else {
            NSLog(@"Got updated user, poping view controller");
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }];
}

@end
