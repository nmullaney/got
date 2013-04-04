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
    [loginView setHidden:YES];
    [activityIndicatorView startAnimating];
}

- (void)showCanLogIn
{
    [pleaseLoginLabel setText:@"Please log in with Facebook"];
    [loginView setHidden:NO];
    [activityIndicatorView stopAnimating];
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
    NSLog(@"Logging in with: %@", user);
    FBSession *activeSession = [FBSession activeSession];
    FBAccessTokenData *tokenData = activeSession.accessTokenData;
    NSString *accessToken = tokenData.accessToken;
    NSDate *expireDate = tokenData.expirationDate;
    NSLog(@"Got FB token %@, expires %@", accessToken, expireDate);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:10];
    [params setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];
    [params setObject:accessToken forKey:@"fb_access_token"];
    [params setObject:[user objectForKey:@"username"] forKey:@"username"];
    [params setObject:[user objectForKey:@"email"] forKey:@"email"];
    
    [[GOTUserStore sharedStore] updateUserWithParams:params
                                      withCompletion:^(id user, NSError *err) {
        if (err) {
            NSLog(@"Got an error while creating new user: %@", err);
            UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                          message:@"An error occurred while trying to login.  Please logout and try again."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [uav show];
            [self showCanLogIn];
            return;
            
        } else {
            NSLog(@"Switching from login to tabs with user: %@", user);
            GOTAppDelegate *myApp = [[UIApplication sharedApplication] delegate];
            [myApp setupTabBarControllers];
        }
    }];
}

#pragma mark -

@end
