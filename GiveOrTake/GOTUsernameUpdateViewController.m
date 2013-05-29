//
//  GOTUsernameUpdateViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTUsernameUpdateViewController.h"

#import "GOTActiveUser.h"
#import "GOTConstants.h"
#import "GOTUserStore.h"
#import "GOTLocationUpdateViewController.h"

@implementation GOTUsernameUpdateViewController

- (id)init
{
    self = [super init];
    if (self) {
        isNewUserFlow = NO;
    }
    return self;
}

- (void)setNewUserFlow
{
    isNewUserFlow = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] setBackgroundColor:[GOTConstants greenBackgroundColor]];
    NSString *currentUsername = [[GOTActiveUser activeUser] username];
    [usernameField setText:currentUsername];
    [[self navigationItem] setTitle:@"Edit Username"];
}

- (IBAction)updateUsername:(id)sender
{
    if (![usernameField text] || [[usernameField text] length] < 6) {
        [errorLabel setText:@"Username must be at least 6 characters."];
        [errorLabel setHidden:NO];
        return;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObject:[usernameField text] forKey:@"username"];
    
    [errorLabel setHidden:TRUE];
    [activityIndicator startAnimating];
    [[GOTUserStore sharedStore] updateUserWithParams:params
                            withCompletion:^(id user, NSError *err) {
        [activityIndicator stopAnimating];
        if (err) {
            NSLog(@"Error updating user's username: setting error");
            [errorLabel setText:[err localizedDescription]];
            [errorLabel setHidden:NO];
            [[GOTUserStore sharedStore] discardChanges];
        } else {
            if (isNewUserFlow) {
                GOTLocationUpdateViewController *lvc = [[GOTLocationUpdateViewController alloc] init];
                [lvc setNewUserFlow];
                [self presentViewController:lvc animated:YES completion:nil];
            } else {
                NSLog(@"Got updated user, poping view controller");
                [[self navigationController] popViewControllerAnimated:YES];
            }
        }
    }];
}

- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [[self view] resignFirstResponder];
}

@end
