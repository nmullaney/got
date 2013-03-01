//
//  GOTOffersViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTOffersViewController : UITableViewController
{
    
    IBOutlet UITableView *tableView;
}

@property (nonatomic, strong) NSMutableArray *offers;

- (void)addNewItem:(id)sender;
- (void)deleteEmptyItems;

@end
