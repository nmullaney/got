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
#import "GOTActiveUser.h"

@implementation GOTOffersViewController

@synthesize offersList;

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        offersList = [[GOTItemList alloc] init];
        
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
    if ([[self offersList] itemCount] == 0) {
        [self updateOffers];
    } 
    [[self tableView] reloadData];
}

#pragma mark table source/delegate methods

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[self offersList] itemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOTItemCell *cell = (GOTItemCell *)[tv dequeueReusableCellWithIdentifier:@"GOTItemCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GOTItemCell" owner:[GOTItemCell class] options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    GOTItem *item = [[self offersList] getItemAtIndex:[indexPath row]];
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
    GOTItem *editItem = [[self offersList] getItemAtIndex:[indexPath row]];
    GOTEditItemViewController *eic = [[GOTEditItemViewController alloc] init];
    [eic setItem:editItem];
    [[self navigationController] pushViewController:eic animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GOTItem *deletedItem = [[self offersList] getItemAtIndex:[indexPath row]];
        [deletedItem setState:[GOTItemState DELETED]];
        [[self offersList] removeItemAtIndex:[indexPath row]];
        [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
        [[GOTItemsStore sharedStore] uploadItem:deletedItem withCompletion:^(id result, NSError *err) {
            if (!err) {
                // TODO itemsStore update?
                [[GOTImageStore sharedStore] deleteImageForKey:[deletedItem imageKey]];
                
            }
        }];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [[self tableView] setEditing:editing animated:animated];
    if (editing) {
        [[self navigationItem] rightBarButtonItem].enabled = NO;
    } else {
        [[self navigationItem] rightBarButtonItem].enabled = YES;
    }
}

// If there are no rows, give information about how to add an offer.
- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    if ([[self offersList] itemCount] == 0) {
        CGRect frame = tv.bounds;
        UIView *messageView = [[[GOTMessageFooterViewBuilder alloc]
                                initWithFrame:frame
                                title:@"You haven't created any offers."
                                message:@"To give away an item, touch the '+' button, fill out information about your item, and press the 'Post Item' button."] view];
        [footer addSubview:messageView];
    }
    return footer;
}

#pragma mark -

#pragma ScrollView methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UITableViewCell *cell = [[[self tableView] visibleCells] lastObject];
    NSUInteger row = [[[self tableView] indexPathForCell:cell] row];
    if (row == ([[self offersList] itemCount] - 1)) {
        [[self offersList] loadMoreItemsWithCompletion:^(id items, NSError *err) {
            [[self tableView] reloadData];
        }];
    }
}

#pragma mark -

#pragma mark add item

- (void)addNewItem:(id)sender
{
    GOTItem *newItem = [[GOTItem alloc] init];
    GOTEditItemViewController *eic = [[GOTEditItemViewController alloc] init];
    [eic setItem:newItem];
    // We display the newest items first
    [[self offersList] insertItem:newItem atIndex:0];
    [[self navigationController] pushViewController:eic animated:YES];
}

// If the GOTEditItemViewController sends back a completely empty object,
// we should just delete it.
- (void)deleteEmptyItems
{
    // only the first item could be empty
    if ([[self offersList] itemCount] > 0) {
        GOTItem *firstItem = [[self offersList] getItemAtIndex:0];
        if ([firstItem isEmpty]) {
            [[self offersList] removeItemAtIndex:0];
        }
    }
}

#pragma mark -

#pragma mark update offers from web

- (void)updateOffers
{
    [[self offersList] setOwnedByID:[[GOTActiveUser activeUser] userID]];
    [[self offersList] loadMostRecentItemsWithCompletion:^(id items, NSError *err) {
        if (err) {
            NSString *errorString = [NSString stringWithFormat:@"Failed to fetch offers: %@",
                                     [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        } else {
            [[self tableView] reloadData];
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

