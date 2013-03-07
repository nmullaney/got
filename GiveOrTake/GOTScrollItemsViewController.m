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
#import "GOTFreeItemDetailViewController.h"


@implementation GOTScrollItemsViewController

@synthesize items, height;

- (void)setItems:(NSArray *)its
{
    int startItemCount = [[self items] count];
    int endItemCount = [its count];
    items = its;
    if (endItemCount != startItemCount) {
        [self initScrollView];
    }
    viewControllers = [[NSMutableArray alloc] init];
    for (int i = 0; i < [its count]; i++) {
        [viewControllers addObject:[NSNull null]];
    }
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
    scrollView.contentSize = CGSizeMake(bounds.size.width * [[self items] count],
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
    if (index < 0 || index > [[self items] count] - 1) {
        return;
    }
    id currentController = [viewControllers objectAtIndex:index];
    if (currentController == [NSNull null]) {
        GOTFreeItemDetailViewController *viewController =
            [[GOTFreeItemDetailViewController alloc] init];
        [viewController setItem:[[self items] objectAtIndex:index]];
        [viewControllers replaceObjectAtIndex:index withObject:viewController];
        [[viewController view] setFrame:[self frameForViewAtIndex:index]];
        [scrollView addSubview:[viewController view]];
    }
}

- (GOTItem *)item {
    return [[self items] objectAtIndex:[self selectedIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
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
}

// During viewWillAppear, the added viewControllers are not having
// their own viewWillAppear called.  I'm not sure what the root cause is,
// but this will ensure their viewWillAppear method will be called.
// This happens correctly during scrollViewDidScroll.
- (void)notifyViewControllerAppearing:(int)index
{
    if (index < 0 || index > [[self items] count] - 1) {
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

- (void)dealloc
{
    NSLog(@"dealloc for GOTScrollItemsViewController");
}

@end