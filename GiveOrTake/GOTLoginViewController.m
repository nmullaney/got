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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createLoginView];
}

- (void)createLoginView
{
    NSLog(@"Create login view");
    FBLoginView *loginView = [[FBLoginView alloc]
                              initWithReadPermissions:[NSArray arrayWithObject:@"email"]];
    [loginView setCenter:[[self view] center]];
    [loginView setDelegate:self];
    [[self view] addSubview:loginView];
    [loginView sizeToFit];
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

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    NSLog(@"Got user info: %@", user);
    [[GOTUserStore sharedStore] createActiveUserFromFBUser:user];
    
    GOTAppDelegate *myApp = [[UIApplication sharedApplication] delegate];
    [myApp setupTabBarControllers];
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

}

@end
