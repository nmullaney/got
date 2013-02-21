//
//  GOTToolbarViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTToolbarViewController.h"

@implementation GOTToolbarViewController

static int toolbarHeight = 60;

@synthesize contentViewController, toolbar;

- (id)initWithContentViewController:(UIViewController *)cvc
{
    self = [super init];
    if (self) {
        contentViewController = cvc;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect toolbarBounds = CGRectMake(0, screenBounds.size.height - toolbarHeight, screenBounds.size.width, toolbarHeight);
    [self createToolbarWithBounds:toolbarBounds];
    
    UIView *contentView = [[self contentViewController] view];
    CGRect contentBounds = CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height - toolbarHeight);
    contentView.frame = contentBounds;
    
    UIView *view = [[UIView alloc] initWithFrame:screenBounds];
    [view addSubview:[self toolbar]];
    [view addSubview:contentView];
    
    [self setView:view];
}

- (void)createToolbarWithBounds:(CGRect)bounds
{
    toolbar = [[UIToolbar alloc] initWithFrame:bounds];
    [toolbar setBackgroundColor:[UIColor redColor]];
}

@end
