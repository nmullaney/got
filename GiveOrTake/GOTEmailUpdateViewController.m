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
#import "GOTAppDelegate.h"
#import "GOTConstants.h"
#import "UIBarButtonItem+FlatBarButtonItem.h"

@implementation GOTEmailUpdateViewController

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
        [self showEditEmail];
    }
    
    [errorLabel setTextColor:[UIColor redColor]];
    
    UIBarButtonItem *backButton = [UIBarButtonItem flatBackBarButtonItemForNavigationController:[self navigationController]];
    [[self navigationItem] setLeftBarButtonItem:backButton];
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
                if (isNewUserFlow) {
                    GOTAppDelegate *myApp = [[UIApplication sharedApplication] delegate];
                    [myApp setupTabBarControllersWithURL:nil];
                } else {
                    [[self navigationController] popViewControllerAnimated:YES];
                }
            }
            
        }];
    } else {
        NSString *newEmail = [emailField text];
        // TODO: real email validation
        if (!newEmail || [newEmail length] == 0) {
            [errorLabel setText:@"Unable to update email to an empty string"];
            [errorLabel setHidden:NO];
            return;
        } else if ([newEmail isEqualToString:[[GOTActiveUser activeUser] email]]) {
            // no change
            [errorLabel setHidden:YES];
            if (isNewUserFlow) {
                GOTAppDelegate *myApp = [[UIApplication sharedApplication] delegate];
                [myApp setupTabBarControllersWithURL:nil];
            } else {
                [[self navigationController] popViewControllerAnimated:YES];
            }
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

- (IBAction)cancelPendingEmail:(id)sender {
    [activityIndicator startAnimating];
    [[GOTUserStore sharedStore] removePendingEmailWithCompletion:^(id result, NSError *err) {
        [activityIndicator stopAnimating];
        if (err) {
            [errorLabel setText:[err localizedDescription]];
            [errorLabel setHidden:NO];
            return;
        }
        [self showEditEmail];
    }];
}

- (void)showEditEmail {
    self->hasPendingEmail = NO;
    [infoLabel setText:@"Please enter the email address you would like to use.  If you change your email, we'll send an email to this address to verify that it's yours."];
    [actionButton setTitle:@"Set Email" forState:UIControlStateNormal];
    [emailField setText:[[GOTActiveUser activeUser] email]];
    [emailField setEnabled:YES];
    [codeField setHidden:YES];
    [cancelChangeButton setHidden:YES];
    [errorLabel setHidden:YES];
}

- (void)showCodeVerification {
    self->hasPendingEmail = YES;
    [infoLabel setText:@"An email has been sent to the new address with a 4 digit code.  Please enter it below to update your email address."];
    [actionButton setTitle:@"Send Code" forState:UIControlStateNormal];
    [emailField setEnabled:NO];
    [codeField setHidden:NO];
    [codeField setDelegate:self];
    [cancelChangeButton setHidden:NO];
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
