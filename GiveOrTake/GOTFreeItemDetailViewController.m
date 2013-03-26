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

    [self loadDescriptionLabel];
    [self loadDistanceLabel];
    [self loadUsernameLabel];
    [self loadDateLabel];
    
    [scrollView setContentSize:CGSizeMake(self->contentWidth + 2 * kBorderSize, self->contentHeight)];
    [scrollView setNeedsDisplay];
}

- (void)loadDescriptionLabel
{
    UIFont *font = [GOTConstants defaultSmallFont];
    CGSize labelSize = [[[self item] desc] sizeWithFont:font constrainedToSize:CGSizeMake(self->contentWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorderSize, self->contentHeight, self->contentWidth, labelSize.height)];
    [descLabel setText:[[self item] desc]];
    [descLabel setFont:font];
    [descLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [descLabel setNumberOfLines:0];
    [scrollView addSubview:descLabel];
    self->contentHeight = self->contentHeight + labelSize.height + kBorderSize;
}

- (void)loadDistanceLabel
{
    UIFont *font = [GOTConstants defaultSmallFont];
    NSString *distanceStr = [NSString stringWithFormat:@"Distance: %@ Miles", [[self item] distance]];
    CGSize labelSize = [distanceStr sizeWithFont:font constrainedToSize:CGSizeMake(self->contentWidth, MAXFLOAT)];
    
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorderSize, self->contentHeight, self->contentWidth, labelSize.height)];
    [distanceLabel setText:distanceStr];
    [distanceLabel setFont:font];
    [scrollView addSubview:distanceLabel];
    self->contentHeight = self->contentHeight + labelSize.height + kBorderSize;
}

- (void)loadUsernameLabel
{
    // We may need to load the user from the web, so we'll need to setup a blank
    // label of the correct size first, then asynchronously fill in the data
    // once we have it.
    UIFont *font = [GOTConstants defaultSmallFont];
    NSString *postedByStr = [NSString stringWithFormat:@"Posted by:"];
    CGSize labelSize = [postedByStr sizeWithFont:font
                               constrainedToSize:CGSizeMake(self->contentWidth, MAXFLOAT)];
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorderSize,
                                                              self->contentHeight,
                                                              self->contentWidth,
                                                              labelSize.height)];
   
    [usernameLabel setFont:font];
    [scrollView addSubview:usernameLabel];
    self->contentHeight = self->contentHeight + labelSize.height + kBorderSize;
    
    [[GOTUserStore sharedStore] fetchUserWithUserID:[[self item] userID] withFacebookID:nil withCompletion:^(id usr, NSError *err) {
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

- (void)loadDateLabel
{
    UIFont *font = [GOTConstants defaultSmallFont];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [dateFormatter stringFromDate:[[self item] datePosted]];
    
    NSString *fullDateLabelString = [NSString stringWithFormat:@"Posted on: %@", dateString];
    CGSize dateLabelSize = [fullDateLabelString sizeWithFont:font constrainedToSize:CGSizeMake(self->contentWidth, MAXFLOAT)];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kBorderSize, self->contentHeight, self->contentWidth, dateLabelSize.height)];
    [dateLabel setText:fullDateLabelString];
    [dateLabel setFont:font];
    [scrollView addSubview:dateLabel];
    self->contentHeight = self->contentHeight + dateLabelSize.height + kBorderSize;
}

- (IBAction)wantButtonPressed:(id)sender {
    // TODO
    NSLog(@"Want pressed");
}

- (void)dealloc
{
    NSLog(@"Dealloc for FreeItemDetailViewController: %@", [[self item] name]);
}

@end
