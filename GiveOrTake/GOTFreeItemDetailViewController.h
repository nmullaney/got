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
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UILabel *descLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIButton *wantButton;
    
}

@property (nonatomic, strong) GOTItem *item;

- (IBAction)wantButtonPressed:(id)sender;

@end
