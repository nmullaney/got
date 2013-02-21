//
//  GOTSingleItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTSingleItemView;

@interface GOTSingleItemViewController : UIViewController <UIGestureRecognizerDelegate>
{
    GOTSingleItemView *siView;
    UIScrollView *scrollView;
}


- (id)initWithItems:(NSArray *)items selectedIndex:(NSInteger)i;
- (void)updateViewFromItem;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic) NSInteger selectedIndex;

@end
