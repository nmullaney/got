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
#import "GOTConstants.h"
#import "GOTScrollItemsViewController.h"
#import "GOTMessageFooterViewBuilder.h"
#import "GOTItemCell.h"

@implementation GOTItemsViewController

@synthesize itemList, singleItemViewController, fisvc, freeItemID;

- (id)init
{
    self = [super init];
    if (self) {
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Filter"
                                                                style:UIBarButtonItemStyleDone
                                                               target:self action:@selector(filterSearch:)];
        [[self navigationItem] setLeftBarButtonItem:bbi];
        FilterItemSettingsViewController *filterVC = [[FilterItemSettingsViewController alloc] init];
        [self setFisvc:filterVC];
        // Ensures we get an initial load
        [[self fisvc] setFilterChanged:YES];
        itemList = [[GOTItemList alloc] init];
        [itemList addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
        
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        [self setRefreshControl:refreshControl];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"items"] && object == [self itemList]) {
        [[self tableView] reloadData];
    }
}

- (void)setFreeItemID:(NSNumber *)itemID
{
    // prevents an initial load of other items
    [[self fisvc] setFilterChanged:NO];
    NSLog(@"URL: setting freeItemID to %@", itemID);
    freeItemID = itemID;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self freeItemID]) {
        [[self itemList] loadSingleItem:[self freeItemID]];
    } else if ([[self fisvc] filterChanged]) {
        NSLog(@"Filter changed, should load most recent items");
        [self setSingleItemViewController:nil];
        [[self itemList] setDistance:[NSNumber numberWithInteger:[self distance]]];
        [[self itemList] setSearchText:[[self fisvc] searchText]];
        [[self itemList] loadMostRecentItemsWithCompletion:^(id il, NSError *err) {
            if (err) {
                NSLog(@"Error occurred: %@", [err localizedDescription]);
                return;
            }
            [[self fisvc] setFilterChanged:NO];
        }];
    }
    [[self navigationItem] setTitle:@"Free Items"];
}

- (NSInteger)distance
{
    return [[GOTSettings instance] getIntValueForKey:[GOTSettings distanceKey]];
}

- (void)refresh:(id)sender
{
    // If a single item is set, clear it
    if ([self freeItemID]) {
        [self setFreeItemID:nil];
        [self setSingleItemViewController:nil];
        [[self itemList] setDistance:[NSNumber numberWithInteger:[self distance]]];
        [[self itemList] setSearchText:[[self fisvc] searchText]];
    }
    
    [[self itemList] loadMostRecentItemsWithCompletion:^(id itemList, NSError *err) {
        NSLog(@"Reloading data because most recent loaded");
        [refreshControl endRefreshing];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UITableViewCell *cell = [[[self tableView] visibleCells] lastObject];
    NSUInteger row = [[[self tableView] indexPathForCell:cell] row];
    if (row == ([[self itemList] itemCount] - 1)) {
        [[self itemList] loadMoreItemsWithCompletion:^(id items, NSError *err) {
            // reload by observer
        }];
    }
}

- (void)fetchThumbnailForItem:(GOTItem *)item atIndexPath:(NSIndexPath *)path
{
    NSURL *url = [item thumbnailURL];
    void (^block)(id, NSError *) = ^void(id image, NSError *err) {
        if (err) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Download Error" message:@"Failed to fetch thumbnail image" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        } else if (image) {
            NSData *data = (NSData *)image;
            [item setThumbnailData:data];
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:path]
                                    withRowAnimation:UITableViewRowAnimationNone];
        }
    };
    [[GOTItemsStore sharedStore] fetchThumbnailAtURL:url withCompletion:block];
}

#pragma mark filter items methods

- (void)filterSearch:(id)sender
{
    // Once the user tries to use the filter, unset any single items we may
    // be displaying
    if ([self freeItemID]) {
        [self setFreeItemID:nil];
        // Reload no matter what
        [[self fisvc] setFilterChanged:YES];
    }
    [[self navigationController] pushViewController:[self fisvc]
                                           animated:YES];
}

#pragma mark -
#pragma mark data source methods

- (int)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[self itemList] itemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GOTItemCell *cell = (GOTItemCell *)[tv dequeueReusableCellWithIdentifier:@"GOTItemCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GOTItemCell" owner:[GOTItemCell class] options:nil];
        cell = [nib objectAtIndex:0];
    }
    if ([indexPath row] < [[self itemList] itemCount]) {
        GOTItem *item = [[self itemList] getItemAtIndex:[indexPath row]];
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
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    if ([[self itemList] itemCount] == 0) {
        CGRect viewFrame = CGRectMake(0, 0, [tv bounds].size.width, [tv bounds].size.height);
        UIView *messageView = [[[GOTMessageFooterViewBuilder alloc]
                                initWithFrame:viewFrame
                                title:@"No free items found."
                                message:@"Try changing the filter to find more items.  You can expand your search by choosing a larger distance or removing a search term."] view];
        [footer addSubview:messageView];
    }
    return footer;
}

#pragma mark -
#pragma mark delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self singleItemViewController]) {
        [self setSingleItemViewController:[[GOTScrollItemsViewController alloc] init]];
        float visibleHeight = [[self tableView] frame].size.height;
        [[self singleItemViewController] setHeight:visibleHeight];
        [[self singleItemViewController] setItemList:[self itemList]];
        [[self singleItemViewController] setHidesBottomBarWhenPushed:YES];
    }
    [[self singleItemViewController] setSelectedIndex:[indexPath row]];
    [[self navigationController] pushViewController:[self singleItemViewController] animated:YES];
}

#pragma mark -

- (void)dealloc
{
    [[self itemList] removeObserver:self forKeyPath:@"items"];
}

@end
