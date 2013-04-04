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
#import "GOTImageStore.h"
#import "GOTItemList.h"
#import "GOTMessageFooterViewBuilder.h"
#import "GOTItemCell.h"
#import "GOTConstants.h"
#import "GOTItemState.h"

@implementation GOTOffersViewController

@synthesize offers;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        offers = [[NSMutableArray alloc] init];
        
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
    if ([[self offers] count] == 0) {
        [self updateOffers];
    }
    [[self tableView] reloadData];
}

#pragma mark table source/delegate methods

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[self offers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOTItemCell *cell = (GOTItemCell *)[tv dequeueReusableCellWithIdentifier:@"GOTItemCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GOTItemCell" owner:[GOTItemCell class] options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    GOTItem *item = [offers objectAtIndex:[indexPath row]];
    [cell setTitle:[item name]];
    [cell setState:[item state]];
    if ([item thumbnail]) {
        [cell setItemImage:[item thumbnail]];
    } else if ([item thumbnailURL]) {
        [cell setItemImage:nil];
        [self fetchThumbnailForItem:item atIndexPath:indexPath];
    } else {
        [cell setItemImage:nil];
    }
    return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    GOTItem *editItem = [[self offers] objectAtIndex:[indexPath row]];
    GOTEditItemViewController *eic = [[GOTEditItemViewController alloc] init];
    [eic setItem:editItem];
    [[self navigationController] pushViewController:eic animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"commitEditingStyle");
        GOTItem *deletedItem = [[self offers] objectAtIndex:[indexPath row]];
        [deletedItem setState:[GOTItemState DELETED]];
        [[GOTItemsStore sharedStore] uploadItem:deletedItem withCompletion:^(id result, NSError *err) {
            if (!err) {
                NSLog(@"Removing object at index");
                [[self offers] removeObjectAtIndex:[indexPath row]];
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                        withRowAnimation:UITableViewRowAnimationFade];
                // TODO itemsStore update?
                [[GOTImageStore sharedStore] deleteImageForKey:[deletedItem imageKey]];
                
            }
        }];
    }
}

// If there are no rows, give information about how to add an offer.
- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    if ([[self offers] count] > 0) {
        tv.sectionFooterHeight = 1;
    } else {
        CGRect frame = tv.bounds;
        UIView *messageView = [[[GOTMessageFooterViewBuilder alloc]
                                initWithFrame:frame
                                title:@"You haven't created any offers."
                                message:@"To give away an item, touch the '+' button, fill out information about your item, and press the 'Post Item' button."] view];
        tv.sectionFooterHeight = [tv bounds].size.height;
        [footer addSubview:messageView];
    }
    return footer;
}

#pragma mark -

#pragma mark add item

- (void)addNewItem:(id)sender
{
    NSLog(@"Creating new item");
    GOTItem *newItem = [[GOTItem alloc] init];
    GOTEditItemViewController *eic = [[GOTEditItemViewController alloc] init];
    [eic setItem:newItem];
    // We display the newest items first
    [[self offers] insertObject:newItem atIndex:0];
    [[self navigationController] pushViewController:eic animated:YES];
}

// If the GOTEditItemViewController sends back a completely empty object,
// we should just delete it.
- (void)deleteEmptyItems
{
    // only the first item could be empty
    if ([[self offers] count] > 0) {
        GOTItem *firstItem = [[self offers] objectAtIndex:0];
        if ([firstItem isEmpty]) {
            [[self offers] removeObjectAtIndex:0];
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

