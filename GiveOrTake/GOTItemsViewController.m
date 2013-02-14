//
//  GOTItemsViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemsViewController.h"
#import "GOTItem.h"
#import "GOTItemsStore.h"

@implementation GOTItemsViewController

- (id)init
{
    self = [super init];
    if (self) {
        distance = 15;
        items = [[GOTItemsStore sharedStore] itemsAtDistance:distance];
        [[self navigationItem] setTitle:@"Free Items Near You"];
    }
    return self;
}

- (IBAction)distanceChanged:(id)sender {
    UISegmentedControl *distanceControl = sender;
    distance = [[distanceControl titleForSegmentAtIndex:[distanceControl selectedSegmentIndex]] intValue];
    NSLog(@"distance is now %d", distance);
    [self updateItems];
}

- (void)updateItems
{
    NSLog(@"Updating items");
    items = [[GOTItemsStore sharedStore] itemsAtDistance:distance];
    [itemTableView reloadData];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    if ([indexPath row] < [items count]) {
        GOTItem *item = [items objectAtIndex:[indexPath row]];
        //NSLog(@"Display cell for %@", item);
        [[cell textLabel] setText:[item name]];
        [[cell detailTextLabel] setText:[item desc]];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}


@end
