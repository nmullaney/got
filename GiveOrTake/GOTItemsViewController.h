//
//  GOTItemsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTSingleItemViewController;
@class FilterItemSettingsViewController;

@interface GOTItemsViewController : UITableViewController
{
    IBOutlet UITableView *tableView;
}

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) GOTSingleItemViewController *singleItemViewController;
@property (nonatomic, strong) FilterItemSettingsViewController *fisvc;

- (void)filterSearch:(id)sender;
- (BOOL)shouldUpdateItems;

@end
