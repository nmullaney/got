//
//  GOTLoginViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/1/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTLoginViewController.h"

#import "GOTAppDelegate.h"
#import "GOTUserStore.h"

@implementation GOTLoginViewController

@synthesize loggingIn;

- (id)init
{
    self = [super init];
    if (self) {
        [self setLoggingIn:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createLoginView];
}

- (void)createLoginView
{
    loginView = [[FBLoginView alloc]
                 initWithReadPermissions:[NSArray arrayWithObject:@"email"]];
    [loginView setCenter:[[self view] center]];
    [loginView setDelegate:self];
    [[self view] addSubview:loginView];
    [loginView sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self loggingIn]) {
        [self showLoggingIn];
    }
}

- (void)showLoggingIn
{
    [pleaseLoginLabel setText:@"Logging in..."];
    [loginView setHidden:TRUE];
    [activityIndicatorView startAnimating];
}

#pragma mark UILoginViewDelegate methods

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"loginView got error: %@", [error localizedDescription]);
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    NSLog(@"loginView showing logged in user");
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"loginView showing logged out user");
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)lv user:(id<FBGraphUser>)user
{
    [self showLoggingIn];
    [[GOTUserStore sharedStore] createActiveUserFromFBUser:user withCompletion:^(id user, NSError *err) {
        NSLog(@"Switching from login to tabs");
        GOTAppDelegate *myApp = [[UIApplication sharedApplication] delegate];
        [myApp setupTabBarControllers];
    }];
}

#pragma mark -

@end
