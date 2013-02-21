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
#import "GOTSingleItemViewController.h"
#import "FilterItemSettingsViewController.h"
#import "GOTSettings.h"

@implementation GOTItemsViewController

- (id)init
{
    self = [super init];
    if (self) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                style:UIBarButtonItemStyleDone
                                                               target:self action:@selector(filterSearch:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateItems];
    [[self navigationItem] setTitle:@"Free Items"];
}

- (NSInteger)distance
{
    return [[GOTSettings instance] getIntValueForKey:[GOTSettings distanceKey]];
}

- (void)updateItems
{
    items = [[GOTItemsStore sharedStore] itemsAtDistance:[self distance]];
    [[self tableView] reloadData];
}

#pragma mark filter items methods


- (void)filterSearch:(id)sender
{
    UIStoryboard *settingStoryboard = [UIStoryboard storyboardWithName:@"FilterItemSettingsStoryboard" bundle:nil];
    UIViewController *filterItemSettingsViewController = [settingStoryboard instantiateInitialViewController];
    [[self navigationController] pushViewController:filterItemSettingsViewController
                                           animated:YES];
}

#pragma mark -
#pragma mark data source methods

- (int)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
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

- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

#pragma mark -
#pragma mark delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOTSingleItemViewController *svc = [[GOTSingleItemViewController alloc] initWithItems:items selectedIndex:[indexPath row]];
    [[self navigationController] pushViewController:svc animated:YES];
}

#pragma mark -

@end
