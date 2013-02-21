//
//  GOTSingleItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTSingleItemView;

@interface GOTSingleItemViewController : UIViewController
    <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    NSMutableArray *views;
}

- (void)addViewAtIndex:(int)index;
- (CGRect)frameForViewAtIndex:(int)index;
- (void)initScrollView;
- (void)cleanupViews:(BOOL)keepViewable;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSInteger selectedIndex;

@end
