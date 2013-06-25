//
//  GOTShareViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 5/16/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTShareViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>

#import "GOTItem.h"
#import "GOTActiveUser.h"
#import "GOTConstants.h"
#import "GOTTextView.h"

#import "UIBarButtonItem+FlatBarButtonItem.h"

@implementation GOTShareViewController

@synthesize item;

static float border = 10;

- (id)initWithItem:(GOTItem *)it
{
    self = [super init];
    if (self) {
        item = it;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"Share %@", [[self item] name]]];
    UIBarButtonItem *cancelButton = [UIBarButtonItem flatBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancelPost:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    
    postButton = [UIBarButtonItem flatBarButtonItemWithTitle:@"Post" target:self action:@selector(sendPost:)];
    
    [[self navigationItem] setRightBarButtonItem:postButton];
    
    [self.view setBackgroundColor:[GOTConstants defaultBackgroundColor]];
    
    float contentWidth = [UIScreen mainScreen].bounds.size.width - 2 * border;
    float textViewHeight = 150;
    textView = [[GOTTextView alloc] initWithFrame:CGRectMake(border, border, contentWidth, textViewHeight)];
    [textView setFont:[GOTConstants defaultMediumFont]];
    [textView setScrollEnabled:YES];
    NSString *actionDesc = @"Write something to post on facebook.";
    if ([self userPostedItem]) {
        [textView setText:@"I'm giving this away on Give or Take!"];
    } else {
        [textView setText:@"This is free on Give or Take!"];
    }
    [textView setPlaceholder:actionDesc];
    [self.view addSubview:textView];
    float heightSoFar = border * 2 + textViewHeight;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[self item] thumbnail]];
    [imageView setFrame:CGRectMake(border, heightSoFar, 80, 80)];
    [imageView setBackgroundColor:[GOTConstants defaultBackgroundColor]];
    imageView.layer.cornerRadius = 8.0;
    imageView.layer.masksToBounds = YES;
    imageView.layer.opaque = NO;
    [self.view addSubview:imageView];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor darkGrayColor];
    [activityIndicator setFrame:[self view].frame];
    [activityIndicator setHidesWhenStopped:YES];
    [self.view addSubview:activityIndicator];
    
}

// Returns true if this item belongs to the active user
- (BOOL)userPostedItem
{
    return [[[GOTActiveUser activeUser] userID] intValue] == [[[self item] userID] intValue];
}

- (void)publishWithGraphAPI
{
    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
    [postParams setValue:[[[self item] itemURL] absoluteString] forKey:@"link"];
    [postParams setValue:[textView text] forKey:@"message"];
    [postParams setValue:FBSession.activeSession.accessTokenData.accessToken
                  forKey:@"access_token"];
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         [activityIndicator stopAnimating];
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = @"Posted successfully.";
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
         [[self navigationController] popViewControllerAnimated:YES];
     }];
}

- (void)sendPost:(id)sender
{
    [postButton setEnabled:NO];
    [activityIndicator startAnimating];
    if ([[FBSession activeSession] isOpen]) {
        if ([FBSession.activeSession.permissions
             indexOfObject:@"publish_actions"] == NSNotFound) {
            // No permissions found in session, ask for it
            [FBSession.activeSession
             requestNewPublishPermissions:
             [NSArray arrayWithObject:@"publish_actions"]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error) {
                     // If permissions granted, publish the story
                     [self publishWithGraphAPI];
                 }
             }];
        } else {
            [self publishWithGraphAPI];
        }
    } else {
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error && status == FBSessionStateOpen) {
                // If permissions granted, publish the story
                [self publishWithGraphAPI];
            } else {
                NSLog(@"Failed to post to Facebook");
                [postButton setEnabled:YES];
            }
        }];
    }
}

- (void)cancelPost:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
