//
//  GOTSendMessageViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/8/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GOTTextView.h"

@class GOTItem;

@interface GOTSendMessageViewController : UIViewController
{
    GOTTextView *messageTextView;
}

- (id)initWithItem:(GOTItem *)item;
- (IBAction)backgroundTapped:(id)sender;
- (void)cancelMessage:(id)sender;
- (void)sendMessage:(id)sender;
- (void)keyboardWasShown:(NSNotification *)notification;
- (void)keyboardWasHidden:(NSNotification *)notification;

@property (nonatomic, strong) GOTItem *item;

@end
