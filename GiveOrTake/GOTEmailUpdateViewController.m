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
    GOTUser *activeUser = [[GOTUserStore sharedStore] activeUser];
    NSString *currentEmail = [activeUser emailAddress];
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
    if (self->hasPendingEmail) {
        NSString *code = [codeField text];
        [[GOTUserStore sharedStore] verifyPendingEmailCode:code withCompletion:^(id result, NSError *err) {
            if (err) {
                [errorLabel setText:[err localizedDescription]];
                return;
            } else {
                // successfully updated!
                [[self navigationController] popViewControllerAnimated:YES];
            }
            
        }];
    } else {
        NSString *newEmail = [emailField text];
        // TODO: real email validation
        if (!newEmail || [newEmail length] == 0) {
            [errorLabel setText:@"Unable to update email to an empty string"];
            return;
        } else {
            [errorLabel setText:@""];
        }
        
        [[GOTUserStore sharedStore] addPendingEmail:newEmail withCompletion:^(id result, NSError *err) {
            if (err) {
                [errorLabel setText:[err localizedDescription]];
                return;
            }
            // Otherwise, we got a positive result
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
