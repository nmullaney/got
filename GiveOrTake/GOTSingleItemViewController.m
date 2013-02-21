//
//  GOTSingleItemViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTSingleItemViewController.h"
#import "GOTItem.h"
#import "GOTSingleItemView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GOTSingleItemViewController

@synthesize items;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setItems:(NSArray *)its
{
    int startItemCount = [[self items] count];
    int endItemCount = [its count];
    // clean up any existing views
    [self cleanupViews:NO];
    if ([[self items] count] != [its count]) {
        [self initScrollView];
    }
    views = nil;
    views = [[NSMutableArray alloc] init];
    for (int i = 0; i < [its count]; i++) {
        [views addObject:[NSNull null]];
    }
    items = its;
    if (endItemCount != startItemCount) {
        [self initScrollView];
    }
}

- (void)setSelectedIndex:(NSInteger)index
{
    _selectedIndex = index;
    [[self navigationItem] setTitle:[[self item] name]];
}

- (void)loadView
{
    [super loadView];
    [self initScrollView];
    [self setView:scrollView];
}

- (void)initScrollView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    [scrollView setDelegate:self];
    scrollView.contentSize = CGSizeMake(bounds.size.width * [[self items] count], bounds.size.height);
    [scrollView setPagingEnabled:YES];
    [scrollView setDirectionalLockEnabled:YES];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self setView:scrollView];
}

- (CGRect)frameForViewAtIndex:(int)index
{
    CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
    int viewWidth = screenBounds.size.width;
    int viewHeight = screenBounds.size.height;
    int viewOriginX = index * viewWidth;
    int viewOriginY = scrollView.contentOffset.y;
    
    return CGRectMake(viewOriginX, viewOriginY, viewWidth, viewHeight);
}

- (void)addViewAtIndex:(int)index
{
    if (index < 0 || index > [[self items] count] - 1) {
        return;
    }
    id view = [views objectAtIndex:index];
    if (view == [NSNull null]) {
        view = [[GOTSingleItemView alloc]
                initWithFrame:[self frameForViewAtIndex:index]];
        [view setItem:[[self items] objectAtIndex:index]];
        [views replaceObjectAtIndex:index withObject:view];
        [scrollView addSubview:view];
    }
}

- (GOTItem *)item {
    return [[self items] objectAtIndex:[self selectedIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addViewAtIndex:[self selectedIndex]];
    [self addViewAtIndex:[self selectedIndex] - 1];
    [self addViewAtIndex:[self selectedIndex] + 1];
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    CGRect scrollViewFrame = [scrollView frame];
    scrollViewFrame.origin.x = [self selectedIndex] * bounds.size.width;
    [scrollView scrollRectToVisible:scrollViewFrame
                           animated:NO];
}

#pragma mark Scroll handling

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
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
    for (int i = 0; i < [views count]; i++) {
        if (keepViewable && i >= ([self selectedIndex] - 1) && i <= ([self selectedIndex] + 1)) {
            // This leaves the 3 viewable views
            continue;
        }
        if ([views objectAtIndex:i] == [NSNull null]) {
            continue;
        }
        UIView *view = [views objectAtIndex:i];
        [view removeFromSuperview];
        [views replaceObjectAtIndex:i withObject:[NSNull null]];
        view = nil;
    }
}


// When we get a memory warning, we should clean up
// unneeded views
- (void)didReceiveMemoryWarning
{
    [self cleanupViews:YES];
}

@end
