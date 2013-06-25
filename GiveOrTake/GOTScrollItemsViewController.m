//
//  GOTSingleItemViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTScrollItemsViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "GOTItem.h"
#import "GOTItemList.h"
#import "GOTItemState.h"
#import "GOTItemsStore.h"
#import "GOTFreeItemDetailViewController.h"
#import "GOTSendMessageViewController.h"
#import "GOTConstants.h"
#import "GOTActiveUser.h"

@implementation GOTScrollItemsViewController

@synthesize itemList, height;

- (void)setItemList:(GOTItemList *)list
{
    viewControllers = [[NSMutableArray alloc] initWithCapacity:[list itemCount]];
    for (int i = 0; i < [list itemCount]; i++) {
        [viewControllers addObject:[NSNull null]];
    }
    itemList = list;
}

- (void)itemListSizeChangedFrom:(NSUInteger)originalSize to:(NSUInteger)newSize
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    // height may be smaller, because of navigation and tab bar
    if ([self height] > 0) {
        bounds.size.height = [self height];
    }
    float width = bounds.size.width * [[self itemList] itemCount];
    scrollView.contentSize = CGSizeMake(width,
                                        bounds.size.height);
    [self cleanupViews:NO];
    viewControllers = [[NSMutableArray alloc] initWithCapacity:[[self itemList] itemCount]];
    for (int i = 0; i < [[self itemList] itemCount]; i++) {
        [viewControllers addObject:[NSNull null]];
    }
    // Re-adding viewable indices
    [self addViewAtIndex:[self selectedIndex] - 1];
    [self addViewAtIndex:[self selectedIndex]];
    [self addViewAtIndex:[self selectedIndex] + 1];
    // Reset the title, in case the visible item has changed.
    [[self navigationItem] setTitle:[[self item] name]];
    [[self view] setNeedsDisplay];
    
}

- (void)setSelectedIndex:(NSInteger)index
{
    _selectedIndex = index;
    [[self navigationItem] setTitle:[[self item] name]];
}

- (void)initScrollView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    // height may be smaller, because of navigation and tab bar
    if ([self height] > 0) {
        bounds.size.height = [self height];
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    [scrollView setDelegate:self];
    scrollView.contentSize = CGSizeMake(bounds.size.width * [[self itemList] itemCount],
                                        bounds.size.height);
    
    [scrollView setPagingEnabled:YES];
    [scrollView setDirectionalLockEnabled:YES];
    [scrollView setShowsHorizontalScrollIndicator:YES];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [self setView:scrollView];
}

- (CGRect)frameForViewAtIndex:(int)index
{
    int viewWidth = [scrollView bounds].size.width;
    int viewHeight = [scrollView bounds].size.height;
    int viewOriginX = index * viewWidth;
    int viewOriginY = scrollView.contentOffset.y;
    
    return CGRectMake(viewOriginX, viewOriginY, viewWidth, viewHeight);
}

- (void)addViewAtIndex:(int)index
{
    if (index < 0) {
        // TODO: fetch at high end?
        NSLog(@"ERROR: Negative index");
        return;
    } else if (index > [[self itemList] itemCount] - 1) {
        int origSize = [[self itemList] itemCount];
        [itemList fetchItemAtIndex:index withCompletion:^(id item, NSError *err) {
            int newSize = [[self itemList] itemCount];
            if (newSize != origSize) {
                [self itemListSizeChangedFrom:origSize to:newSize];
            }
        }];
        return;
    }
    id currentController = [viewControllers objectAtIndex:index];
    if (currentController == [NSNull null]) {
        GOTFreeItemDetailViewController *viewController =
            [[GOTFreeItemDetailViewController alloc] init];
        [viewController setItem:[[self itemList] getItemAtIndex:index]];
        [viewControllers replaceObjectAtIndex:index withObject:viewController];
        [[viewController view] setFrame:[self frameForViewAtIndex:index]];
        [scrollView addSubview:[viewController view]];
        [scrollView setNeedsDisplay];
    } else {
      // This ensures that the data will be up-to-date
      [currentController setItem:[[self itemList] getItemAtIndex:index]];
    }
}

- (GOTItem *)item {
    return [[self itemList] getItemAtIndex:[self selectedIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self navigationController] navigationBar] setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:[GOTConstants defaultLargeFont] forKey:UITextAttributeFont]];
    [[self navigationController] setToolbarHidden:NO animated:YES];
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGRect scrollViewFrame = [scrollView frame];
    scrollViewFrame.origin.x = [self selectedIndex] * bounds.size.width;
    [scrollView scrollRectToVisible:scrollViewFrame
                           animated:NO];
    
    [self addViewAtIndex:[self selectedIndex]];
    [self addViewAtIndex:[self selectedIndex] - 1];
    [self addViewAtIndex:[self selectedIndex] + 1];
    
    [self notifyViewControllerAppearing:[self selectedIndex]];
    [self notifyViewControllerAppearing:[self selectedIndex] - 1];
    [self notifyViewControllerAppearing:[self selectedIndex] + 1];
    [scrollView setNeedsDisplay];
}

- (void)loadView
{
    [super loadView];
    [self initScrollView];
    
    CGRect toolbarFrame = [[[self navigationController] toolbar] frame];
    // The toolbar leaves a margin of 10px at the edge, so to
    // center the button, we need to remove 20 from the width
    float wantButtonWidth = toolbarFrame.size.width - 20;
    float wantButtonX = 0;
    float wantButtonY = toolbarFrame.origin.y;
    float wantButtonHeight = toolbarFrame.size.height;
    
    UIButton *wantButton = [[UIButton alloc] init];
    [wantButton setFrame:CGRectMake(wantButtonX, wantButtonY, wantButtonWidth, wantButtonHeight)];
    [wantButton setTitle:@"I want this!" forState:UIControlStateNormal];
    wantButton.titleLabel.font = [GOTConstants defaultBoldLargeFont];
    [wantButton addTarget:self action:@selector(wantButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:wantButton];
    
    [self setToolbarItems:[NSArray arrayWithObject:item]];
    self.navigationController.toolbar.tintColor = [GOTConstants actionButtonColor];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
    [[[self navigationController] navigationBar] setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:[GOTConstants defaultVeryLargeFont] forKey:UITextAttributeFont]];
}

- (void)wantButtonPressed:(id)sender
{
    GOTItem *currentItem = [[self itemList] getItemAtIndex:[self selectedIndex]];
    if ([[currentItem userID] intValue] == [[[GOTActiveUser activeUser] userID] intValue]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"You cannot request your own item!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([currentItem state] == [GOTItemState PENDING] && [currentItem numMessagesSent] != nil) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:@"You've already signed up to be notified about this item." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    if ([currentItem state] == [GOTItemState AVAILABLE]) {
        GOTSendMessageViewController *smvc = [[GOTSendMessageViewController alloc] initWithItemList:[self itemList] selectedIndex:[self selectedIndex]];
        [[self navigationController] pushViewController:smvc animated:YES];
    } else {
        [[GOTItemsStore sharedStore] sendWantItem:currentItem withCompletion:^(NSDictionary *result, NSError *err) {
            if (err) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error registering for item" message:[err localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                return;
            } else {
                [currentItem setNumMessagesSent:[result objectForKey:@"numMessagesSent"]];
                GOTFreeItemDetailViewController *currentVC = [viewControllers objectAtIndex:[self selectedIndex]];
                [currentVC updateMessagesSent];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Success" message:@"We will email you if this item becomes available." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                return;
            }
        }];
    }
}

// During viewWillAppear, the added viewControllers are not having
// their own viewWillAppear called.  I'm not sure what the root cause is,
// but this will ensure their viewWillAppear method will be called.
// This happens correctly during scrollViewDidScroll.
- (void)notifyViewControllerAppearing:(int)index
{
    if (index < 0 || index > [[self itemList] itemCount] - 1) {
        return;
    }
    UIViewController *viewController = [viewControllers objectAtIndex:index];
    [viewController viewWillAppear:NO];
}

#pragma mark Scroll handling

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    CGFloat viewWidth = sv.frame.size.width;
    int index = floor((sv.contentOffset.x - viewWidth / 2) / viewWidth) + 1;
    if (index < 0) {
        index = 0;
    } else if (index > ([[self itemList] itemCount] - 1)) {
        index = [[self itemList] itemCount];
    }
    if (index == [self selectedIndex]) {
        // We're on the same view, so we can just wait
        return;
    }
    [self setSelectedIndex:index];
    [self addViewAtIndex:[self selectedIndex] - 1];
    [self addViewAtIndex:[self selectedIndex]];
    [self addViewAtIndex:[self selectedIndex] + 1];
}

#pragma mark -

- (void)cleanupViews:(BOOL)keepViewable
{
    for (int i = 0; i < [viewControllers count]; i++) {
        if (keepViewable && i >= ([self selectedIndex] - 1) && i <= ([self selectedIndex] + 1)) {
            // This leaves the 3 viewable views
            continue;
        }
        if ([viewControllers objectAtIndex:i] == [NSNull null]) {
            continue;
        }
        UIViewController *viewController = [viewControllers objectAtIndex:i];
        [viewController viewWillAppear:NO];
        [[viewController view] removeFromSuperview];
        [viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
        viewController = nil;
    }
}


// When we get a memory warning, we should clean up
// unneeded views
- (void)didReceiveMemoryWarning
{
    [self cleanupViews:YES];
}

@end
