//
//  GOTWelcomeViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/4/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTWelcomeViewController.h"

#import "GOTUsernameUpdateViewController.h"

@interface GOTWelcomeViewController ()

@end

@implementation GOTWelcomeViewController

- (IBAction)startButtonPressed:(id)sender {
    GOTUsernameUpdateViewController *uvc = [[GOTUsernameUpdateViewController alloc] init];
    [uvc setNewUserFlow];
    [self presentViewController:uvc animated:YES completion:nil];
}
@end
