//
//  GOTSingleItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTItemList;

@interface GOTScrollItemsViewController : UIViewController
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
- (void)itemListSizeChangedFrom:(NSUInteger)originalSize to:(NSUInteger)newSize;

@property (nonatomic, strong) GOTItemList *itemList;
@property (nonatomic) NSInteger selectedIndex;

// The viewable height of this controller
@property (nonatomic) float height;

@end
