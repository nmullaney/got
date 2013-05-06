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

@implementation GOTScrollItemsViewController

@synthesize itemList, height;

- (void)setItemList:(GOTItemList *)list
{
    NSLog(@"Resetting item list");
    if (itemList) {
        // remove observer
        [itemList removeObserver:self forKeyPath:@"items"];
    }
    viewControllers = [[NSMutableArray alloc] initWithCapacity:[list itemCount]];
    for (int i = 0; i < [list itemCount]; i++) {
        [viewControllers addObject:[NSNull null]];
    }
    itemList = list;
    [itemList addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"items changed value!");
    // Sanity check
    if ([keyPath isEqualToString:@"items"] && object == [self itemList]) {
        NSArray *oldItems = [change objectForKey:NSKeyValueChangeOldKey];
        NSArray *newItems = [change objectForKey:NSKeyValueChangeNewKey];
        if (![oldItems isEqualToArray:newItems]) {
            [self itemListSizeChangedFrom:[oldItems count] to:[newItems count]];
        }
    }
}

- (void)itemListSizeChangedFrom:(NSUInteger)originalSize to:(NSUInteger)newSize
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    // height may be smaller, because of navigation and tab bar
    if ([self height] > 0) {
        bounds.size.height = [self height];
    }
    float width = bounds.size.width * [[self itemList] itemCount];
    NSLog(@"Setting content width to %f, (for %d items)", width, [[self itemList] itemCount]);
    scrollView.contentSize = CGSizeMake(width,
                                        bounds.size.height);
    [self cleanupViews:NO];
    NSLog(@"Clearing viewControllers because items changed");
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
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = NO;
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
        return;
    } else if (index > [[self itemList] itemCount] - 1) {
        [itemList fetchItemAtIndex:index withCompletion:nil];
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
    }
}

- (GOTItem *)item {
    return [[self itemList] getItemAtIndex:[self selectedIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear");
    [super viewWillAppear:animated];
    
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
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"I want this!"
                                                             style:UIBarButtonItemStyleBordered target:self
                                                            action:@selector(wantButtonPressed:)];
    [item setTintColor:[UIColor redColor]];
    // It doesn't seem to be possible to set the width and the font simultaneously here,
    // so we'll use the default font.
    [item setWidth:(bounds.size.width - 10)];
    [self setToolbarItems:[NSArray arrayWithObject:item]];
    [[self navigationController] setToolbarHidden:NO animated:YES];
}

- (void)loadView
{
    NSLog(@"Load view");
    [super loadView];
    [self initScrollView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[self navigationController] setToolbarHidden:YES animated:animated];
}

- (void)wantButtonPressed:(id)sender
{
    NSLog(@"Want button pressed in scrollview!");
    GOTItem *currentItem = [[self itemList] getItemAtIndex:[self selectedIndex]];
    if ([currentItem state] == [GOTItemState AVAILABLE]) {
        GOTSendMessageViewController *smvc = [[GOTSendMessageViewController alloc] initWithItem:currentItem];
        [[self navigationController] pushViewController:smvc animated:YES];
    } else {
        [[GOTItemsStore sharedStore] sendWantItem:currentItem withCompletion:^(NSDictionary *result, NSError *err) {
            if (err) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error registering for item" message:[err localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            } else {
                [currentItem setNumMessagesSent:[result objectForKey:@"numMessagesSent"]];
                GOTFreeItemDetailViewController *currentVC = [viewControllers objectAtIndex:[self selectedIndex]];
                [currentVC updateMessagesSent];
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
    //NSLog(@"super scrollViewDidScroll");
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
        NSLog(@"Cleanup views");
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

- (void)dealloc
{
    NSLog(@"dealloc for GOTScrollItemsViewController");
    [[self itemList] removeObserver:self forKeyPath:@"items"];
}

@end
