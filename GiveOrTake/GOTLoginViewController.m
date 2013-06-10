//
//  GOTLoginViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/1/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTLoginViewController.h"

#import "GOTActiveUser.h"
#import "GOTUserStore.h"
#import "GOTConstants.h"

@implementation GOTLoginViewController

@synthesize loggingIn, postLoginBlock;

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
    
    [[self view] setBackgroundColor:[GOTConstants greenBackgroundColor]];
    
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
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)lv user:(id<FBGraphUser>)user
{
    [self showLoggingIn];
    FBSession *activeSession = [FBSession activeSession];
    FBAccessTokenData *tokenData = activeSession.accessTokenData;
    NSString *accessToken = tokenData.accessToken;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:10];
    [params setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];
    [params setObject:accessToken forKey:@"fb_access_token"];
    if ([user objectForKey:@"username"]) {
        [params setObject:[user objectForKey:@"username"] forKey:@"username"];
    }
    if ([user objectForKey:@"email"]) {
        [params setObject:[user objectForKey:@"email"] forKey:@"email"];
    }
    
    [[GOTUserStore sharedStore] updateUserWithParams:params
                                      withCompletion:^(GOTActiveUser *user, NSError *err) {
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
            if ([self postLoginBlock]) {
                [self postLoginBlock]();
            }
        }
    }];
}

#pragma mark -

@end
