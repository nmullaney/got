//
//  GOTFreeItemDetailViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTItem;

@interface GOTFreeItemDetailViewController : UIViewController
{
    IBOutlet UIView *view;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIBarButtonItem *wantButton;
    __weak IBOutlet UIActivityIndicatorView *imageLoadingIndicator;
    
    UILabel *descLabel;
    UILabel *distanceLabel;
    UILabel *usernameLabel;
    UILabel *dateLabel;
    
    // The height of the scrollview content
    float contentHeight;
    float contentWidth;
}

@property (nonatomic, strong) GOTItem *item;

- (void)loadDescriptionLabel;
- (void)loadDistanceLabel;
- (void)loadDateLabel;
- (void)loadUsernameLabel;

- (IBAction)wantButtonPressed:(id)sender;

@end
