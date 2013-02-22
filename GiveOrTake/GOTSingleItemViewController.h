//
//  GOTSingleItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTSingleItemViewController : UIViewController
    <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    NSMutableArray *viewControllers;
}

- (void)addViewAtIndex:(int)index;
- (CGRect)frameForViewAtIndex:(int)index;
- (void)initScrollView;
- (void)cleanupViews:(BOOL)keepViewable;
- (void)notifyViewControllerAppearing:(int)index;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSInteger selectedIndex;

@end
