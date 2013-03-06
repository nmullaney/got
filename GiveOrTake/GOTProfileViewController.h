//
//  GOTProfileViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTProfileViewController : UITableViewController
{
    IBOutlet UITableView *tableView;
    __weak IBOutlet UILabel *username;
    __weak IBOutlet UILabel *email;
}


- (IBAction)logout:(id)sender;

@end
