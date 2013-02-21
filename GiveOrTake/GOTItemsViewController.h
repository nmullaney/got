//
//  GOTItemsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTItemsViewController : UITableViewController
{
    NSArray *items;
    IBOutlet UITableView *tableView;
}

- (void)filterSearch:(id)sender;

@end
