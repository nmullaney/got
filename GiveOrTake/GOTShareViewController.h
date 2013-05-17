//
//  GOTShareViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 5/16/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTItem, GOTTextView;

@interface GOTShareViewController : UIViewController {
    
    IBOutlet UIControl *view;
    GOTTextView *textView;
}

@property (nonatomic, strong) GOTItem *item;


- (id)initWithItem:(GOTItem *)item;
- (BOOL)userPostedItem;
- (void)sendPost:(id)sender;
- (void)cancelPost:(id)sender;

@end
