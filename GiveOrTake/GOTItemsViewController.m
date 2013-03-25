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

@implementation GOTItemsViewController

@synthesize itemList, singleItemViewController, fisvc;

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
        // Ensures we get an initial load
        [[self fisvc] setFilterChanged:YES];
        itemList = [[GOTItemList alloc] init];
        [itemList addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"items"] && object == [self itemList]) {
        [[self tableView] reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self fisvc] filterChanged]) {
        NSLog(@"Filter changed, should load most recent items");
        [self setSingleItemViewController:nil];
        [[self itemList] setDistance:[NSNumber numberWithInteger:[self distance]]];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = [scrollView contentOffset];
    if (contentOffset.y < 0 && abs(contentOffset.y) > [[self tableView] rowHeight] && ![[self tableView] tableHeaderView]) {
    
        // Update most recent items and show a header
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
        [[self itemList] loadMostRecentItemsWithCompletion:^(id itemList, NSError *err) {
            [[self tableView] setTableHeaderView:nil];
            NSLog(@"Reloading data because most recent loaded");
        }];
    }
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

#pragma mark -
#pragma mark data source methods

- (int)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[self itemList] itemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    if ([indexPath row] < [[self itemList] itemCount]) {
        GOTItem *item = [[self itemList] getItemAtIndex:[indexPath row]];
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
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    if ([[self itemList] itemCount] > 0) {
        tv.sectionFooterHeight = 1;
    } else {
        CGRect viewFrame = CGRectMake(0, 0, [tv bounds].size.width, [tv bounds].size.height);
        UIView *messageView = [[[GOTMessageFooterViewBuilder alloc]
                               initWithFrame:viewFrame
                               title:@"No free items found."
                                message:@"Try changing the filter to find more items.  You can expand your search by choosing a larger distance or removing a search term."] view];
        tv.sectionFooterHeight = [tv bounds].size.height;
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
