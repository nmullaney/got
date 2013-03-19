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
        self->noMoreData = NO;
        // Ensures we get an initial load
        [[self fisvc] setFilterChanged:YES];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self shouldUpdateItems]) {
        [self updateItems:NO];
    }
    [[self navigationItem] setTitle:@"Free Items"];
}

- (NSInteger)distance
{
    return [[GOTSettings instance] getIntValueForKey:[GOTSettings distanceKey]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = [scrollView contentOffset];
    if (contentOffset.y < 0 && abs(contentOffset.y) > [[self tableView] rowHeight] && ![[self tableView] tableHeaderView]) {
    
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[self tableView] bounds].size.width, [[self tableView] rowHeight])];
        UIColor *headerColor = [GOTConstants defaultBackgroundColor];
        [tableHeaderView setBackgroundColor:headerColor];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGRect indicatorFrame = CGRectMake(0, 0, [indicatorView bounds].size.width * 2, [indicatorView bounds].size.height * 2);
        [indicatorView setFrame:indicatorFrame];
        [tableHeaderView addSubview:indicatorView];
        [indicatorView startAnimating];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[self tableView] bounds].size.width, [[self tableView] rowHeight])];
        [label setText:@"Updating items"];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[GOTConstants defaultMediumFont]];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [tableHeaderView addSubview:label];
        [[self tableView] setTableHeaderView:tableHeaderView];
        [[self tableView] setNeedsDisplay];
        [self updateItems:NO];
    }
}

- (void)updateItems:(BOOL)loadMore
{
    NSLog(@"Updating items from WEB");
    void (^completion)(GOTItemList *, NSError *) = ^void(GOTItemList *list, NSError *err) {
        if (list) {
            NSLog(@"Got list of items in ItemsView: %@", list);
            if ([[list items] count] < [GOTConstants itemRequestLimit]) {
                // Since we got less items then we requested, we can
                // assume there is no more data
                self->noMoreData = YES;
            }
            [self mergeNewItems:[list items]];
            [self setSingleItemViewController:nil];
            [[self tableView] setTableHeaderView:nil];
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
    // We either load/update from the top or from the bottom
    int offset = 0;
    if (loadMore && !self->noMoreData) {
        offset = [[self items] count];
    }
    [[GOTItemsStore sharedStore] fetchItemsAtDistance:[self distance]
                                            withLimit:[GOTConstants itemRequestLimit]
                                           withOffset:offset
                                       withCompletion:completion];
}

- (void)mergeNewItems:(NSArray *)newItems
{
    NSMutableDictionary *itemsByID = [[NSMutableDictionary alloc] init];
    // Add all original items to the dictionary, minus any that don't match the filter
    [[self items] enumerateObjectsUsingBlock:^(GOTItem *item, NSUInteger idx, BOOL *stop) {
        if ([[item distance] integerValue] < [self distance]) {
            [itemsByID setObject:item forKey:[item itemID]];
        } else {
            NSLog(@"Not adding %@ because distance is too great: item distance: %@ vs filter distance: %@", [item name], [item distance], [NSNumber numberWithInteger:[self distance]]);
        }
    }];
    [newItems enumerateObjectsUsingBlock:^(GOTItem *newItem, NSUInteger idx, BOOL *stop) {
        GOTItem *oldItem = [itemsByID objectForKey:[newItem itemID]];
        if (!oldItem || ([[newItem dateUpdated] timeIntervalSinceDate:[oldItem dateUpdated]] > 0)) {
            NSLog(@"Adding in new item for: %@", [newItem name]);
            NSLog(@"New date = %@", [newItem dateUpdated]);
            if (oldItem) {
                NSLog(@"Old date = %@", [oldItem dateUpdated]);
            } 
            [itemsByID setObject:newItem forKey:[newItem itemID]];
        }
    }];
    // Sort all the items by date updated
    NSArray *allItems = [itemsByID allValues];
    allItems = [allItems sortedArrayUsingComparator:^NSComparisonResult(GOTItem *item1, GOTItem *item2) {
        return [[item2 dateUpdated] compare:[item1 dateUpdated]];
    }];
    [self setItems:allItems];
}

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

#pragma mark filter items methods

- (void)filterSearch:(id)sender
{
    [[self navigationController] pushViewController:[self fisvc]
                                           animated:YES];
}

- (BOOL)shouldUpdateItems
{
    BOOL shouldUpdate = [[self fisvc] filterChanged];
    if (shouldUpdate) {
        // If the filter has changed, we don't know if we have all the
        // data
        self->noMoreData = NO;
    }
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
        if ([item thumbnail]) {
            [[cell imageView] setImage:[item thumbnail]];
        } else if ([item thumbnailURL]) {
            [[cell imageView] setImage:nil];
            [self fetchThumbnailForItem:item atIndexPath:indexPath];
        } else {
            [[cell imageView] setImage:nil];
        }
    }
    if ([indexPath row] == ([items count] - 1) && !self->noMoreData) {
        [self updateItems:YES];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    if ([[self items] count] > 0) {
        tv.sectionFooterHeight = 1;
    } else {
        // It would be nice to set the background color to gray here, but
        // I'm getting some inconsistencies in how the background of the table
        // affects the background of this component, so for now, I'll leave it white.
        tv.sectionFooterHeight = [tv bounds].size.height;
        float border = 10;
        float width = [tv bounds].size.width - 2 * border;
        NSString *title = @"No free items found.";
        CGSize titleLabelSize = [title sizeWithFont:[GOTConstants defaultVeryLargeFont]];
        UILabel *titleLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(border, width/4, width, titleLabelSize.height)];
        [titleLabel setText:title];
        [titleLabel setFont:[GOTConstants defaultVeryLargeFont]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor darkGrayColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [footer addSubview:titleLabel];
        
        NSString *info = @"Try changing the filter to find more items.  You can expand your search by choosing a larger distance or removing a search term.";
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
#pragma mark delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self singleItemViewController]) {
        [self setSingleItemViewController:[[GOTScrollItemsViewController alloc] init]];
        float visibleHeight = [[self tableView] frame].size.height;
        [[self singleItemViewController] setHeight:visibleHeight];
        [[self singleItemViewController] setItems:[self items]];
        [[self singleItemViewController] setHidesBottomBarWhenPushed:YES];
    }
    [[self singleItemViewController] setSelectedIndex:[indexPath row]];
    [[self navigationController] pushViewController:[self singleItemViewController] animated:YES];
}

#pragma mark -

@end
