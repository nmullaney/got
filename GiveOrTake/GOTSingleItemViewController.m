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

- (id)initWithItems:(NSArray *)its selectedIndex:(NSInteger)i
{
    self = [super init];
    if (self) {
        
        [self setItems:its];
        [self setSelectedIndex:i];
        [[self navigationItem] setTitle:[[self item] name]];
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    bounds.size.height -= 20;
    
    siView = [[GOTSingleItemView alloc] initWithFrame:bounds];
    [siView setItem:[[self items] objectAtIndex:[self selectedIndex]]];
    
    CGRect newViewBounds = [[UIScreen mainScreen] applicationFrame];
    newViewBounds.size.height -= 20;
    newViewBounds.origin.x = newViewBounds.size.width;
    GOTSingleItemView *newView = [[GOTSingleItemView alloc] initWithFrame:newViewBounds];
    int newIndex = [self selectedIndex] + 1;
    [newView setItem:[items objectAtIndex:newIndex]];
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    scrollView.contentSize = CGSizeMake(bounds.size.width * 2, bounds.size.height);
    [scrollView setPagingEnabled:YES];
    [scrollView setDirectionalLockEnabled:YES];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [scrollView addSubview:siView];
    [scrollView addSubview:newView];
    [self setView:scrollView];
}

- (GOTItem *)item {
    return [[self items] objectAtIndex:[self selectedIndex]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewFromItem];
}

- (void)updateViewFromItem
{
    GOTItem *curItem = [self item];
    [siView setItem:curItem];
}

@end
