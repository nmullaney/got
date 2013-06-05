//
//  GOTItemMetadataView.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 6/5/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemMetadataView.h"

#import "GOTItem.h"
#import "GOTItemState.h"
#import "GOTUser.h"
#import "GOTUserStore.h"

@implementation GOTItemMetadataView

- (id)init
{
    NSLog(@"In init");
    NSArray *objs = [[NSBundle mainBundle] loadNibNamed:@"GOTItemMetadataView" owner:self options:nil];
    self = [objs objectAtIndex:0];
    return self;
}

- (void)loadItemData:(GOTItem *)item
{
    NSLog(@"In loadItemData");
    [self loadUserForItem:item];
    [statusImage setImage:[GOTItemState imageForState:[item state]]];
    [statusLabel setText:[item state]];
    
    NSString *distanceStr = nil;
    if ([[item distance] intValue] < 1) {
        distanceStr = @"Less than 1 mile";
    } else {
        distanceStr = [NSString stringWithFormat:@"%@ Miles", [item distance]];
    }
    [distanceLabel setText:distanceStr];
    
    [updatedLabel setText:[self timeAgo:[item dateUpdated]]];
    [postedLabel setText:[self timeAgo:[item datePosted]]];
}

- (void)loadUserForItem:(GOTItem *)item
{
    [[GOTUserStore sharedStore] fetchUserWithUserID:[item userID] withCompletion:^(GOTUser *user, NSError *err) {
        if (err) {
            NSLog(@"Could not load user: %@", [err localizedDescription]);
        }
        if (user) {
            [postedByLabel setText:[user username]];
            [karmaImage setImage:[UIImage imageNamed:@"karma"]];
            [karmaLabel setText:[NSString stringWithFormat:@"%@", [user karma]]];
        }
    }];
}

- (NSString *)timeAgo:(NSDate *)date
{
    NSTimeInterval timeInterval = -[date timeIntervalSinceNow];
    if (timeInterval < 60) {
        return @"Less than 1 minute ago";
    } else if (timeInterval < 60 * 2) {
        return @"1 minute ago";
    } else if (timeInterval < 60 * 60) {
        NSInteger minutes = (NSInteger)(timeInterval / 60.0);
        return [NSString stringWithFormat:@"%d minutes ago", minutes];
    } else if (timeInterval < 2 * 60 * 60) {
        return @"1 hour ago";
    } else if (timeInterval < 24 * 60 * 60) {
        NSInteger hours = (NSInteger) (timeInterval / (60.0 * 60.0));
        return [NSString stringWithFormat:@"%d hours ago", hours];
    } else if (timeInterval <= 2 * 24 * 60 * 60) {
        return @"1 day ago";
    } else if (timeInterval < 30 * 24 * 60 * 60) {
        NSInteger days = (NSInteger) (timeInterval / (24.0 * 60.0 * 60.0));
        return [NSString stringWithFormat:@"%d days ago", days];
    } else {
        return @"More than a month ago";
    }
}

@end
