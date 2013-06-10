//
//  GOTItemsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GADBannerViewDelegate.h"

@class GOTScrollItemsViewController;
@class FilterItemSettingsViewController;
@class GOTItem;
@class GOTItemList;
@class GADBannerView, GADRequest;

@interface GOTItemsViewController : UITableViewController <GADBannerViewDelegate>
{
    IBOutlet UITableView *tableView;
    UIActivityIndicatorView *activityIndicator;
    GADBannerView *bannerView;
    GADRequest *bannerRequest;
    int adIndex;
}

@property (nonatomic, strong) GOTItemList *itemList;
@property (nonatomic, strong) FilterItemSettingsViewController *fisvc;

// This is used for openURL for a specific item
@property (nonatomic, strong) NSNumber *freeItemID;

- (void)filterSearch:(id)sender;
- (void)fetchThumbnailForItem:(GOTItem *)item atIndexPath:(NSIndexPath *)path;

- (int)indexForIndexPath:(NSIndexPath *)path;

- (GADBannerView *)bannerView;
- (GADRequest *)bannerRequest;
- (void)reloadBannerView;
- (UITableViewCell *)tableView:(UITableView *)tv itemCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tv adCellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
