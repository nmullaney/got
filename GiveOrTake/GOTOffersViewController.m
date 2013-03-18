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
#import "GOTConstants.h"

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
        GOTItem *deletedItem = [[self offers] objectAtIndex:[indexPath row]];
        [deletedItem setState:DELETED];
        [[GOTItemsStore sharedStore] uploadItem:deletedItem withCompletion:^(id result, NSError *err) {
            if (!err) {
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
        // It would be nice to set the background color to gray here, but
        // I'm getting some inconsistencies in how the background of the table
        // affects the background of this component, so for now, I'll leave it white.
        tv.sectionFooterHeight = [tv bounds].size.height;
        float border = 10;
        float width = [tv bounds].size.width - 2 * border;
        NSString *title = @"You haven't created any offers.";
        CGSize titleLabelSize = [title sizeWithFont:[GOTConstants defaultVeryLargeFont]];
        UILabel *titleLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(border, width/4, width, titleLabelSize.height)];
        [titleLabel setText:title];
        [titleLabel setFont:[GOTConstants defaultVeryLargeFont]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [footer addSubview:titleLabel];
        
        NSString *info = @"To give away an item, touch the '+' button, fill out information about your item, and press the 'Post Item' button.";
        CGSize infoLabelSize = [info sizeWithFont:[GOTConstants defaultLargeFont] constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        float infoLabely = width/4 + titleLabelSize.height + border;
        UILabel *infoLabel = [[UILabel alloc]
                              initWithFrame:CGRectMake(border, infoLabely, width, infoLabelSize.height)];
        [infoLabel setText:info];
        [infoLabel setTextAlignment:NSTextAlignmentLeft];
        [infoLabel setTextColor:[UIColor darkGrayColor]];
        [infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [infoLabel setNumberOfLines:0];
        [infoLabel setBackgroundColor:[UIColor clearColor]];
        [footer addSubview:infoLabel];
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
    [[self offers] addObject:newItem];
    [[self navigationController] pushViewController:eic animated:YES];
}

// If the GOTEditItemViewController sends back a completely empty object,
// we should just delete it.
- (void)deleteEmptyItems
{
    for (GOTItem *i in [self offers]) {
        if ([i isEmpty]) {
            [[self offers] removeObject:i];
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

