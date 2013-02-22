//
//  GOTItemsViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemsViewController.h"

#import "FilterItemSettingsViewController.h"
#import "GOTItem.h"
#import "GOTItemsStore.h"
#import "GOTSettings.h"
#import "GOTSingleItemViewController.h"

@implementation GOTItemsViewController

@synthesize items, singleItemViewController, fisvc;

- (id)init
{
    self = [super init];
    if (self) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                style:UIBarButtonItemStyleDone
                                                               target:self action:@selector(filterSearch:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
        [self setSingleItemViewController:[[GOTSingleItemViewController alloc] init]];
        UIStoryboard *settingStoryboard = [UIStoryboard storyboardWithName:@"FilterItemSettingsStoryboard" bundle:nil];
        [self setFisvc:[settingStoryboard instantiateInitialViewController]];
        [self updateItems];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self shouldUpdateItems]) {
        [self updateItems];
    }
    [[self navigationItem] setTitle:@"Free Items"];
}

- (NSInteger)distance
{
    return [[GOTSettings instance] getIntValueForKey:[GOTSettings distanceKey]];
}

- (void)updateItems
{
    [self setItems:[[GOTItemsStore sharedStore] itemsAtDistance:[self distance]]];
    [[self singleItemViewController] setItems:[self items]];
    [[self tableView] reloadData];
}

#pragma mark filter items methods


- (void)filterSearch:(id)sender
{
    [[self navigationController] pushViewController:[self fisvc]
                                           animated:YES];
}

- (BOOL)shouldUpdateItems
{
    BOOL shouldUpdate = [[self fisvc] filterChanged];
    [[self fisvc] setFilterChanged:NO];
    return shouldUpdate;
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
    [[self singleItemViewController] setSelectedIndex:[indexPath row]];
    [[self navigationController] pushViewController:[self singleItemViewController] animated:YES];
}

#pragma mark -

@end
