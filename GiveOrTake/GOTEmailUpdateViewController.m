//
//  GOTEmailUpdateViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTEmailUpdateViewController.h"

#import "GOTUserStore.h"
#import "GOTActiveUser.h"

@implementation GOTEmailUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:@"Edit Email Address"];
    GOTActiveUser *activeUser = [GOTActiveUser activeUser];
    NSString *currentEmail = [activeUser email];
    NSString *pendingEmail = [activeUser pendingEmail];
    if (pendingEmail) {
        self->hasPendingEmail = YES;
        [emailField setText:pendingEmail];
        [self showCodeVerification];
    } else {
        self->hasPendingEmail = NO;
        [emailField setText:currentEmail];
    }
    
    [errorLabel setTextColor:[UIColor redColor]];
}

- (IBAction)updateEmail:(id)sender
{
    [activityIndicator startAnimating];
    if (self->hasPendingEmail) {
        NSString *code = [codeField text];
        [[GOTUserStore sharedStore] verifyPendingEmailCode:code withCompletion:^(id result, NSError *err) {
            [activityIndicator stopAnimating];
            if (err) {
                [errorLabel setText:[err localizedDescription]];
                [errorLabel setHidden:NO];
                return;
            } else {
                // successfully updated!
                [errorLabel setHidden:YES];
                [[self navigationController] popViewControllerAnimated:YES];
            }
            
        }];
    } else {
        NSString *newEmail = [emailField text];
        // TODO: real email validation
        if (!newEmail || [newEmail length] == 0) {
            [errorLabel setText:@"Unable to update email to an empty string"];
            [errorLabel setHidden:NO];
            return;
        } else {
            [errorLabel setHidden:YES];
            [errorLabel setText:@""];
        }
        
        [[GOTUserStore sharedStore] addPendingEmail:newEmail withCompletion:^(id result, NSError *err) {
            [activityIndicator stopAnimating];
            if (err) {
                [errorLabel setText:[err localizedDescription]];
                [errorLabel setHidden:NO];
                return;
            }
            // Otherwise, we got a positive result
            [errorLabel setHidden:YES];
            [self showCodeVerification];
        }];
    }
}

- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [[self view] becomeFirstResponder];
}

- (void)showCodeVerification {
    self->hasPendingEmail = YES;
    [infoLabel setText:@"An email has been sent to the new address with a 4 digit code.  Please enter it below to update your email address."];
    [emailField setEnabled:NO];
    [codeField setHidden:NO];
    [codeField setDelegate:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:codeField]) {
        // limit to 4 charaters
        NSUInteger newLength = [[textField text] length] + [string length] - range.length;
        return (newLength > 4)? NO : YES;
    }
    return YES;
}
     
@end
