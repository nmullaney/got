//
//  GOTOffersViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTOffersViewController.h"

#import "GOTEditItemViewController.h"
#import "GOTItem.h"
#import "GOTItemsStore.h"
#import "GOTItemList.h"

@implementation GOTOffersViewController

@synthesize offers;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        offers = [[NSMutableArray alloc] init];
        [self updateOffers];
        
        [[self navigationItem] setTitle:@"My Offers"];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        [[self navigationItem]  setRightBarButtonItem:bbi];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self deleteEmptyItems];
    [[self tableView] reloadData];
}

#pragma mark table source/delegate methods

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[self offers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    GOTItem *item = [offers objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item name]];
    [[cell detailTextLabel] setText:[item desc]];
    if ([item thumbnail]) {
        [[cell imageView] setImage:[item thumbnail]];
    } else if ([item thumbnailURL]) {
        [[cell imageView] setImage:nil];
        [self fetchThumbnailForItem:item atIndexPath:indexPath];
    } else {
        [[cell imageView] setImage:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOTItem *editItem = [[self offers] objectAtIndex:[indexPath row]];
    GOTEditItemViewController *eic = [[GOTEditItemViewController alloc] init];
    [eic setItem:editItem];
    [[self navigationController] pushViewController:eic animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self offers] removeObjectAtIndex:[indexPath row]];
        [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
    }
}

// This is just a little hack to prevent empty rows from appearing
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

#pragma mark -

#pragma mark add item

- (void)addNewItem:(id)sender
{
    NSLog(@"Creating new item");
    GOTItem *newItem = [[GOTItem alloc] init];
    GOTEditItemViewController *eic = [[GOTEditItemViewController alloc] init];
    [eic setItem:newItem];
    [[self offers] addObject:newItem];
    [[self navigationController] pushViewController:eic animated:YES];
}

// If the GOTEditItemViewController sends back a completely empty object,
// we should just delete it.
- (void)deleteEmptyItems
{
    for (GOTItem *i in [self offers]) {
        if ([i isEmpty]) {
            NSLog(@"Item is empty: %@", [i description]);
            [[self offers] removeObject:i];
        } else {
            NSLog(@"Item is not empty: %@", [i description]);
        }
    }
}

#pragma mark -

#pragma mark update offers from web

- (void)updateOffers
{
    [[GOTItemsStore sharedStore] fetchMyItemsWithCompletion:^(GOTItemList *list, NSError *err) {
        if (list) {
            [self setOffers:[list items]];
            [[self tableView] reloadData];
        }
        if (err) {
            NSString *errorString = [NSString stringWithFormat:@"Failed to fetch offers: %@",
                                     [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    }];
}

// This is duped from GOTItemsViewController.  They can probably be combined somehow.
- (void)fetchThumbnailForItem:(GOTItem *)item atIndexPath:(NSIndexPath *)path
{
    NSURL *url = [item thumbnailURL];
    void (^block)(id, NSError *) = ^void(id image, NSError *err) {
        NSData *data = (NSData *)image;
        [item setThumbnailData:data];
        [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:path]
                                withRowAnimation:UITableViewRowAnimationNone];
    };
    [[GOTItemsStore sharedStore] fetchThumbnailAtURL:url withCompletion:block];
}

#pragma mark -

@end
