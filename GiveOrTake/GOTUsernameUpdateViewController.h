//
//  GOTUsernameUpdateViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTUsernameUpdateViewController : UIViewController
{
    
    IBOutlet UIView *view;
    __weak IBOutlet UITextField *usernameField;
    __weak IBOutlet UILabel *errorLabel;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
}

- (IBAction)updateUsername:(id)sender;

@end
