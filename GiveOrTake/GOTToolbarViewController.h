//
//  GOTToolbarViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/15/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTToolbarViewController : UIViewController
{
}

@property (nonatomic, readonly, retain) UIToolbar *toolbar;
@property (nonatomic, readonly, retain) UIViewController *contentViewController;

- (id)initWithContentViewController:(UIViewController *)cvc;
- (void)createToolbarWithBounds:(CGRect)bounds;

@end
