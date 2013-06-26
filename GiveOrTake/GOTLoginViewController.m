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
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIImage *defaultImage = [UIImage imageNamed:@"Default"];
    if ([self isLongScreen]) {
        NSLog(@"Setting default image to Default-568h");
        defaultImage = [UIImage imageNamed:@"Default-568h"];
    } else {
        NSLog(@"Setting default image to Default, height = %f", screenBounds.size.height);
    }
    [backgroundImageView setImage:defaultImage];
    [backgroundImageView setFrame:screenBounds];
    
    [self createLoginView];
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicatorView setHidesWhenStopped:YES];
    activityIndicatorView.color = [UIColor darkGrayColor];
    [activityIndicatorView setCenter:[loginView center]];
    [[self view] addSubview:activityIndicatorView];
    [[self view] sendSubviewToBack:backgroundImageView];
}

- (BOOL)isLongScreen
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return (screenBounds.size.height == 568);
}

- (void)createLoginView
{
    loginView = [[FBLoginView alloc]
                 initWithReadPermissions:[NSArray arrayWithObject:@"email"]];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float loginViewPosition = 380;
    if ([self isLongScreen]) {
        loginViewPosition = 420;
    }
    [loginView setCenter:CGPointMake(screenBounds.size.width / 2, loginViewPosition)];
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
    [loginView setHidden:YES];
    [activityIndicatorView startAnimating];
}

- (void)showCanLogIn
{
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
