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
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[self fisvc] filterChanged]) {
        NSLog(@"Filter changed, should load most recent items");
        [[self itemList] setDistance:[NSNumber numberWithInteger:[self distance]]];
        [[self itemList] loadMostRecentItemsWithCompletion:^(id itemList, NSError *err) {
            [[self fisvc] setFilterChanged:NO];
            [[self tableView] reloadData];
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
            [[self tableView] reloadData];
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    UITableViewCell *cell = [[[self tableView] visibleCells] lastObject];
    NSUInteger row = [[[self tableView] indexPathForCell:cell] row];
    if (row == ([[self itemList] itemCount] - 1)) {
        [[self itemList] loadMoreItemsWithCompletion:^(id items, NSError *err) {
            [[self tableView] reloadData];
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
        // TODO: change this to take itemList
        [[self singleItemViewController] setItems:[[self itemList] items]];
        [[self singleItemViewController] setHidesBottomBarWhenPushed:YES];
    }
    [[self singleItemViewController] setSelectedIndex:[indexPath row]];
    [[self navigationController] pushViewController:[self singleItemViewController] animated:YES];
}

#pragma mark -

@end
