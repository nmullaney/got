//
//  GOTItemsViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTItemsViewController : UIViewController
    <UITableViewDataSource>
{
    IBOutlet UIView *view;
    __weak IBOutlet UITableView *itemTableView;
    
    int distance;
    NSArray *items;
}

- (IBAction)distanceChanged:(id)sender;

@end
