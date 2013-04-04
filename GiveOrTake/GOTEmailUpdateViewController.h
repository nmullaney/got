//
//  GOTEmailUpdateViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTEmailUpdateViewController : UIViewController <UITextFieldDelegate>
{
    
    IBOutlet UIControl *view;
    __weak IBOutlet UILabel *infoLabel;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UILabel *errorLabel;
    __weak IBOutlet UITextField *codeField;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *actionButton;
    BOOL hasPendingEmail;
    
    BOOL isNewUserFlow;
}

- (void)setNewUserFlow;

- (IBAction)updateEmail:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

@end
