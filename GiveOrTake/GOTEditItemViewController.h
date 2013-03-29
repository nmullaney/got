//
//  GOTEditItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/17/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTItem;
@class GOTTextView;

@interface GOTEditItemViewController : UIViewController
    <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>
{
    UIScrollView *view;
    UITextField *nameField;
    UIControl *stateButton;
    UIImageView *stateImage;
    UILabel *stateLabel;
    UIImageView *stateChevronView;
    GOTTextView *descField;
    UIImageView *imageView;
    UIActivityIndicatorView *imageActivityIndicator;
    UIButton *postOfferButton;
}

@property (nonatomic, strong) GOTItem *item;

- (void)enhanceDescField;
- (void)backgroundTapped:(id)sender;
- (void)takePicture:(id)sender;
- (void)nameEditingEnded:(id)sender;
- (void)uploadItem;
- (void)updateValues;

- (void)stateButtonPressed:(id)sender;

@end
