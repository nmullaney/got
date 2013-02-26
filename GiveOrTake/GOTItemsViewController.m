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
#import "GOTItemList.h"
#import "GOTItemsStore.h"
#import "GOTSettings.h"
#import "GOTScrollItemsViewController.h"

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
    void (^completion)(GOTItemList *, NSError *) = ^void(GOTItemList *list, NSError *err) {
        if (list) {
            [self setItems:[list items]];
            [self setSingleItemViewController:nil];
            [[self tableView] reloadData];
        } else if (err) {
            NSString *errorString = [NSString stringWithFormat:@"Failed to fetch items: %@",
                                     [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    };
    GOTItemList *list = [[GOTItemsStore sharedStore] fetchItemsAtDistance:[self distance] withCompletion:completion];
    [self setItems:[list items]];
    [self setSingleItemViewController:nil];
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
    if (![self singleItemViewController]) {
        [self setSingleItemViewController:[[GOTScrollItemsViewController alloc] init]];
        float visibleHeight = [[self tableView] frame].size.height;
        [[self singleItemViewController] setHeight:visibleHeight];
        [[self singleItemViewController] setItems:[self items]];
    }
    [[self singleItemViewController] setSelectedIndex:[indexPath row]];
    [[self navigationController] pushViewController:[self singleItemViewController] animated:YES];
}

#pragma mark -

@end
