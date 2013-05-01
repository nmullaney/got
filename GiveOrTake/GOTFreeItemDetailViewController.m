//
//  GOTFreeItemDetailViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTFreeItemDetailViewController.h"

#import "GOTItem.h"
#import "GOTUser.h"
#import "GOTImageStore.h"
#import "GOTUserStore.h"
#import "GOTConstants.h"

@implementation GOTFreeItemDetailViewController

@synthesize item;

static float kBorderSize = 5.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [imageLoadingIndicator startAnimating];
    [[GOTImageStore sharedStore] fetchImageForItem:[self item] withCompletion:^(id image, NSError *err) {
        [imageLoadingIndicator stopAnimating];
        if (image) {
            [imageView setImage:image];
            [[self view] setNeedsDisplay];
        }
        if (err) {
            NSLog(@"error fetching image: %@", [err localizedDescription]);
        }
    }];
    
    self->contentWidth = [[UIScreen mainScreen] bounds].size.width - 2 * kBorderSize;
    self->contentHeight = imageView.bounds.origin.y + imageView.bounds.size.height + kBorderSize;

    [self addLabelWithText:[[self item] desc]];
    
    [self loadUsernameLabel];
    NSString *statusStr = [NSString stringWithFormat:@"Status: %@", [[self item] state]];
    [self addLabelWithText:statusStr];
    
    NSString *distanceStr = [NSString stringWithFormat:@"Distance: %@ Miles", [[self item] distance]];
    [self addLabelWithText:distanceStr];
    
    NSString *postedDateString = [NSString stringWithFormat:@"Posted on: %@", [self dateStringForDate:[[self item] datePosted]]];
    [self addLabelWithText:postedDateString];
    
    NSString *updateDateString = [NSString stringWithFormat:@"Last updated: %@", [self dateStringForDate:[[self item] dateUpdated]]];
    [self addLabelWithText:updateDateString];
    
    [scrollView setContentSize:CGSizeMake(self->contentWidth + 2 * kBorderSize, self->contentHeight)];
    [scrollView setNeedsDisplay];
}

// Adds a label that can be multi-line and is guaranteed to fit
- (UILabel *)addLabelWithText:(NSString *)labelText
{
    UIFont *font = [GOTConstants defaultSmallFont];
    CGSize labelSize = [labelText sizeWithFont:font constrainedToSize:CGSizeMake(self->contentWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorderSize, self->contentHeight, self->contentWidth, labelSize.height)];
    [newLabel setText:labelText];
    [newLabel setFont:font];
    [newLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [newLabel setNumberOfLines:0];
    [scrollView addSubview:newLabel];
    self->contentHeight = self->contentHeight + labelSize.height + kBorderSize;
    return newLabel;
}

- (void)loadUsernameLabel
{
    // We may need to load the user from the web, so we'll need to setup a blank
    // label of the correct size first, then asynchronously fill in the data
    // once we have it.
    NSString *postedByStr = [NSString stringWithFormat:@"Posted by:"];
    UILabel *usernameLabel = [self addLabelWithText:postedByStr];
    
    [[GOTUserStore sharedStore] fetchUserWithUserID:[[self item] userID] withCompletion:^(id usr, NSError *err) {
        if (err) {
            NSLog(@"Could not load user: %@", [err localizedDescription]);
        }
        if (usr) {
            GOTUser *user = (GOTUser *)usr;
            NSString *postedByStr = [NSString stringWithFormat:@"Posted by: %@ (karma: %@)", [user username], [user karma]];
            [usernameLabel setText:postedByStr];
            [usernameLabel setNeedsDisplay];
        }
    }];
}

- (NSString *)dateStringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:date];
}

- (void)dealloc
{
    NSLog(@"Dealloc for FreeItemDetailViewController: %@", [[self item] name]);
}

@end
