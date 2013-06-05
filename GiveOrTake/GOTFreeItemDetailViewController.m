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

#import "GOTItemMetadataView.h"

#import <QuartzCore/QuartzCore.h>

@implementation GOTFreeItemDetailViewController

@synthesize item;

static float kBorderSize = 5.0;
static float kPadding = 2.0;
static float kMetaHeight = 140.0;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self messagesSentString] && !messagesSentLabel) {
        [self addMessagesSentLabel];
        
    }
    NSLog(@"Showing item: %@", item);
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
    
    descLabel = [self addLabelWithText:[[self item] desc] withFont:[GOTConstants defaultMediumFont]];
    
    [self addMessagesSentLabel];
    
    metaView = [[GOTItemMetadataView alloc] init];
    //[metaView setFrame:CGRectMake(300, 200, 200, 200)];
    [metaView loadItemData:[self item]];
    [metaView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView addSubview:metaView];
    
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
    
    [metaView loadItemData:[self item]];
    
    // Only update the image if it's local
    if ([[self item] image]) {
        [imageView setImage:[[self item] image]];
    }
    
    [self autolayout];
}

- (void)autolayout
{
    NSLog(@"Layout for item: %@", [self item]);
    if (allConstraints) {
        [[self view] removeConstraints:allConstraints];
    }
    allConstraints = [[NSMutableArray alloc] init];

    UIView *previous = imageView;
    NSNumber *height = nil;
    
    if (![descLabel.text isEqual:@""]) {
        height = [self heightForLabel:descLabel];
        [allConstraints addObjectsFromArray:[self constraintsForView:descLabel withPreviousView:previous withHeight:height]];
        previous = descLabel;
    }
    
    if (messagesSentLabel) {
        height = [NSNumber numberWithFloat:[[self heightForLabel:messagesSentLabel] floatValue] + 2 * kPadding];
        [allConstraints addObjectsFromArray:[self constraintsForView:[messagesSentLabel superview] withPreviousView:previous withHeight:height]];
        previous = [messagesSentLabel superview];
        [allConstraints addObjectsFromArray:[self constraintsForMessagesSentLabel:messagesSentLabel]];
    }
    
    [allConstraints addObjectsFromArray:[self constraintsForView:metaView withPreviousView:previous withHeight:[NSNumber numberWithFloat:kMetaHeight]]];
    
    [[self view] addConstraints:allConstraints];
    [[self view] needsUpdateConstraints];
}

- (NSArray *)constraintsForView:(UIView *)current
              withPreviousView :(UIView *)prev
                     withHeight:(NSNumber *)height
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithFloat:kBorderSize] forKey:@"border"];
    [metrics setValue:height forKey:@"height"];
    NSDictionary *viewSet = [NSDictionary dictionaryWithObjectsAndKeys:prev, @"prev", current, @"current", nil];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-border-[current(height)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-border-[current]-border-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
    return constraints;
}

- (NSArray *)constraintsForMessagesSentLabel:(UILabel *)label
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    NSMutableDictionary *metrics = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithFloat:kPadding] forKey:@"padding"];
    NSNumber *messagesSentLabelHeight = [self heightForLabel:label];
    [metrics setValue:messagesSentLabelHeight forKey:@"height"];
    NSDictionary *viewSet = [NSDictionary dictionaryWithObjectsAndKeys:messagesSentLabel, @"messagesSentLabel", nil];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[messagesSentLabel]-padding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[messagesSentLabel(height)]-padding-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:viewSet]];
    return constraints;
}

- (NSNumber *)heightForLabel:(UILabel *)label
{
    NSString *labelText = [label text];
    float height = 0;
    if (labelText) {
        UIFont *font = [label font];
        float contentWidth = [[UIScreen mainScreen] bounds].size.width - 2 * kBorderSize;
        CGSize labelSize = [labelText sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        height = labelSize.height;
    }
    return [NSNumber numberWithFloat:height];
}

- (UILabel *)addLabelWithText:(NSString *)labelText
{
    return [self addLabelWithText:labelText withFont:[GOTConstants defaultSmallFont]];
}

// Adds a label that can be multi-line and is guaranteed to fit
- (UILabel *)addLabelWithText:(NSString *)labelText withFont:(UIFont *)font
{
    UILabel *newLabel = [self createLabelWithText:labelText withFont:font];
    [scrollView addSubview:newLabel];
    return newLabel;
}

- (UILabel *)createLabelWithText:(NSString *)labelText
{
    return [self createLabelWithText:labelText withFont:[GOTConstants defaultSmallFont]];
}

- (UILabel *)createLabelWithText:(NSString *)labelText withFont:(UIFont *)font
{
    UILabel *newLabel = [[UILabel alloc] init];
    [newLabel setText:labelText];
    [newLabel setFont:font];
    [newLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [newLabel setNumberOfLines:0];
    [newLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    return newLabel;
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
        return nil;
    } else if ([numMessages isEqual:[NSNumber numberWithInt:0]]) {
        // The user has expressed interest, but has not sent a message
        if (state == [GOTItemState PENDING]) {
            msg = [NSString stringWithFormat:@"We'll email you if this item becomes available."];
        } else {
            msg = [NSString stringWithFormat:@"You want this item, but haven't sent a message yet."];
        }
    } else {
        // The user has successfully sent a message to the owner
        if (isStateUserActiveUser) {
            msg = [NSString stringWithFormat:@"Congrats! This item has been promised to you!"];
        } else if (state == [GOTItemState PENDING]) {
            msg = [NSString stringWithFormat:@"We'll email you if this item becomes available."];
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
