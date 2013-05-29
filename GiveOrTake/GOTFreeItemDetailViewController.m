//
//  GOTFreeItemDetailViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTFreeItemDetailViewController.h"

#import "GOTItem.h"
#import "GOTItemState.h"
#import "GOTActiveUser.h"
#import "GOTUser.h"
#import "GOTImageStore.h"
#import "GOTUserStore.h"
#import "GOTConstants.h"

#import <QuartzCore/QuartzCore.h>

@implementation GOTFreeItemDetailViewController

@synthesize item;

static float kBorderSize = 5.0;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self messagesSentString] && !messagesSentLabel) {
        [self addMessagesSentLabel];
        
    } 
    [self reloadItem];
}

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
    
    // This tracks the labels we want to arrange
    labels = [[NSMutableArray alloc] init];
    
    [self addMessagesSentLabel];
    
    descLabel = [self addLabelWithText:[[self item] desc]];
    
    [self loadUsernameLabel];
    NSString *statusStr = [NSString stringWithFormat:@"Status: %@", [[self item] state]];
    statusLabel = [self addLabelWithText:statusStr];
    
    NSString *distanceStr = [NSString stringWithFormat:@"Distance: %@ Miles", [[self item] distance]];
    [self addLabelWithText:distanceStr];
    
    NSString *postedDateString = [NSString stringWithFormat:@"Posted on: %@", [self dateStringForDate:[[self item] datePosted]]];
    [self addLabelWithText:postedDateString];
    
    NSString *updateDateString = [NSString stringWithFormat:@"Last updated: %@", [self dateStringForDate:[[self item] dateUpdated]]];
    updateDateLabel = [self addLabelWithText:updateDateString];
    
    [self autolayout];
    
    [scrollView sizeToFit];
    [scrollView setNeedsUpdateConstraints];
    [scrollView setNeedsDisplay];
}

- (void)reloadItem
{
    // These are the fields that could be updated via offers, so might be changed if a user is looking
    // at their own item.
    [descLabel setText:[[self item] desc]];
    
    [statusLabel setText:[NSString stringWithFormat:@"Status: %@", [[self item] state]]];
    NSString *updateDateString = [NSString stringWithFormat:@"Last updated: %@", [self dateStringForDate:[[self item] dateUpdated]]];
    [updateDateLabel setText:updateDateString];
    
    // Only update the user if you can find it locally
    GOTUser *owner = [[GOTUserStore sharedStore] fetchLocalUserWithUserID:[[self item] userID]];
    if (owner) {
        NSString *postedByStr = [NSString stringWithFormat:@"Posted by: %@ (karma: %@)", [owner username], [owner karma]];
        [usernameLabel setText:postedByStr];
    }
    
    // Only update the image if it's local
    if ([[self item] image]) {
        [imageView setImage:[[self item] image]];
    }
    
    [self autolayout];
}

- (void)autolayout
{
    NSLog(@"Layout for item: %@", [self item]);
    if (labelConstraints) {
        [[self view] removeConstraints:labelConstraints];
    }
    labelConstraints = [[NSMutableArray alloc] initWithCapacity:([labels count] * 2)];
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithFloat:kBorderSize] forKey:@"border"];
    UIView *previousView = imageView;
    if (messagesSentLabel) {
        NSNumber *messagesSentLabelHeight = [self heightForLabel:messagesSentLabel];
        NSNumber *superViewHeight = [NSNumber numberWithFloat:[messagesSentLabelHeight floatValue] + kBorderSize * 2];
        [metrics setValue:messagesSentLabelHeight forKey:@"height"];
        [metrics setValue:superViewHeight forKey:@"superviewHeight"];
        NSDictionary *viewSet = [NSDictionary dictionaryWithObjectsAndKeys:imageView, @"imageView", [messagesSentLabel superview], @"superview", messagesSentLabel, @"messagesSentLabel", nil];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView]-border-[superview(superviewHeight)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-border-[superview]-border-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-border-[messagesSentLabel]-border-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-border-[messagesSentLabel(height)]-border-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
        previousView = [messagesSentLabel superview];
        NSLog(@"Constraints for messages sent: %@", labelConstraints);
    }
    for (UIView *currentView in labels) {
        [metrics setValue:[self heightForLabel:(UILabel *)currentView] forKey:@"height"];
        NSDictionary *viewSet = [NSDictionary dictionaryWithObjectsAndKeys:previousView, @"prev", currentView, @"current", nil];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-border-[current(height)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
        [labelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-border-[current]-border-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
        previousView = currentView;
    }
    [[self view] addConstraints:labelConstraints];
    [[self view] needsUpdateConstraints];
}

- (NSNumber *)heightForLabel:(UILabel *)label
{
    NSString *labelText = [label text];
    float height = 0;
    if (labelText) {
        UIFont *font = [GOTConstants defaultSmallFont];
        float contentWidth = [[UIScreen mainScreen] bounds].size.width - 2 * kBorderSize;
        CGSize labelSize = [labelText sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        height = labelSize.height;
    }
    return [NSNumber numberWithFloat:height];
}

// Adds a label that can be multi-line and is guaranteed to fit
- (UILabel *)addLabelWithText:(NSString *)labelText
{
    UILabel *newLabel = [self createLabelWithText:labelText];
    [scrollView addSubview:newLabel];
    [labels addObject:newLabel];
    return newLabel;
}

- (UILabel *)createLabelWithText:(NSString *)labelText
{
    UILabel *newLabel = [[UILabel alloc] init];
    [newLabel setText:labelText];
    [newLabel setFont:[GOTConstants defaultSmallFont]];
    [newLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [newLabel setNumberOfLines:0];
    [newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    return newLabel;
}

- (void)loadUsernameLabel
{
    // We may need to load the user from the web, so we'll need to setup a blank
    // label of the correct size first, then asynchronously fill in the data
    // once we have it.
    NSString *postedByStr = [NSString stringWithFormat:@"Posted by:"];
    usernameLabel = [self addLabelWithText:postedByStr];
    
    NSLog(@"Item = %@", [self item]);
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

- (NSString *)messagesSentString
{
    NSNumber *numMessages = [[self item] numMessagesSent];
    NSString *msg = nil;
    GOTItemState *state = [[self item] state];
    BOOL isStateUserActiveUser = [[[self item] stateUserID] intValue] == [[[GOTActiveUser activeUser] userID] intValue];
    
    if ([[[self item] userID] intValue] == [[[GOTActiveUser activeUser] userID] intValue]) {
        // This is your own item.
        return nil;
    }
    
    if (numMessages == nil) {
        // The user has not expressed interest in this item
        if (state == [GOTItemState PENDING]) {
            msg = [NSString stringWithFormat:@"This item has been promised to another user.  Click 'I want this' to be informed if it becomes available."];
        }
    } else if ([numMessages isEqual:[NSNumber numberWithInt:0]]) {
        // The user has expressed interest, but has not sent a message
        if (state == [GOTItemState PENDING]) {
            msg = [NSString stringWithFormat:@"This item has been promised to another user.  You will be sent an email if it becomes available."];
        } else {
            msg = [NSString stringWithFormat:@"You expressed interest in this item.  Click 'I want this' to send a message to the owner of the item."];
        }
    } else {
        // The user has successfully sent a message to the owner
        if (isStateUserActiveUser) {
            msg = [NSString stringWithFormat:@"Congratulations! This item has been promised to you!"];
        } else if (state == [GOTItemState PENDING]) {
            msg = [NSString stringWithFormat:@"This item has been promised to another user.  You will be sent an email if it becomes available."];
        } else {
            // Message has been sent, and the item is still available
            msg = [NSString stringWithFormat:@"You've sent a message to the owner of this item."];
        }
    }
    return msg;
}

- (void)addMessagesSentLabel
{
    NSString *messagesSentString = [self messagesSentString];
    if (messagesSentString) {
        NSLog(@"Setting the add Messages sent label");
        UIView *labelBackground = [[UIView alloc] init];
        [labelBackground setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelBackground setBackgroundColor:[GOTConstants defaultBackgroundColor]];
        labelBackground.layer.cornerRadius = 8;
        labelBackground.layer.masksToBounds = YES;
        
        messagesSentLabel = [self createLabelWithText:[self messagesSentString]];
        [messagesSentLabel setTextAlignment:NSTextAlignmentCenter];
        [messagesSentLabel setBackgroundColor:[UIColor clearColor]];
        [labelBackground addSubview:messagesSentLabel];
        [scrollView addSubview:labelBackground];
    }
}

- (void)updateMessagesSent
{
    if (messagesSentLabel) {
        [messagesSentLabel setText:[self messagesSentString]];
    } else {
        [self addMessagesSentLabel];
    }
    NSLog(@"Creating new message label: %@", [self messagesSentString]);
    [messagesSentLabel setNeedsDisplay];
    [self autolayout];
}

- (NSString *)dateStringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:date];
}

- (void)setItem:(GOTItem *)i
{
    if (item) {
        [self removeObserver:self forKeyPath:@"item"];
    }
    item = i;
    [self addObserver:self forKeyPath:@"item" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual: @"item"]) {
        NSLog(@"Updating for change in item: %@", object);
        [self autolayout];
    }
}

- (void)dealloc
{
    NSLog(@"Dealloc for FreeItemDetailViewController: %@", [[self item] name]);
    [self removeObserver:self forKeyPath:@"item"];
}

@end
