//
//  GOTItemsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTScrollItemsViewController;
@class FilterItemSettingsViewController;
@class GOTItem;
@class GOTItemList;

@interface GOTItemsViewController : UITableViewController
{
    IBOutlet UITableView *tableView;
}

@property (nonatomic, strong) GOTItemList *itemList;
@property (nonatomic, strong) GOTScrollItemsViewController *singleItemViewController;
@property (nonatomic, strong) FilterItemSettingsViewController *fisvc;

- (void)filterSearch:(id)sender;
- (void)fetchThumbnailForItem:(GOTItem *)item atIndexPath:(NSIndexPath *)path;

@end
