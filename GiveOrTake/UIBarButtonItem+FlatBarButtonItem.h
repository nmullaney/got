//
//  UIBarButtonItem+FlatBarButtonItem.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 6/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (FlatBarButtonItem)

+ (UIBarButtonItem *)flatBarButtonItemWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)flatBackBarButtonItemForNavigationController:(UINavigationController *)navController;

@end
