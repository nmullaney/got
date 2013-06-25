//
//  UIBarButtonItem+FlatBarButtonItem.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 6/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "UIBarButtonItem+FlatBarButtonItem.h"

#import "GOTConstants.h"

@implementation UIBarButtonItem (FlatBarButtonItem)

+ (UIBarButtonItem *)flatBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton setTitle:title forState:UIControlStateNormal];
    [filterButton setBackgroundColor:[UIColor clearColor]];
    [filterButton setTitleColor:[GOTConstants navButtonTextColor] forState:UIControlStateNormal];
    [[filterButton titleLabel] setFont:[GOTConstants barButtonItemFont]];
    [filterButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [filterButton sizeToFit];
    
    return [[UIBarButtonItem alloc] initWithCustomView:filterButton];
}

+ (UIBarButtonItem *)flatBackBarButtonItemForNavigationController:(UINavigationController *)navController
{
    NSArray *navViewControllers = navController.viewControllers;
    UIViewController *previousVC = navViewControllers[[navViewControllers count] - 2];
    return [UIBarButtonItem flatBarButtonItemWithTitle:previousVC.navigationItem.title
                                                target:navController
                                                action:@selector(popViewControllerAnimated:)];
}

@end
