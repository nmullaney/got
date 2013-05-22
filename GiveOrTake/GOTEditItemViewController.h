//
//  GOTEditItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/17/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTItem;
@class GOTItemState;
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
@property (nonatomic, strong) GOTItemState *draftState;
@property (nonatomic, strong) NSNumber *draftStateUserID;
@property (nonatomic, strong) NSArray *usersWantItem;

- (void)updateViewForItem;
- (void)backgroundTapped:(id)sender;
- (void)takePicture:(id)sender;
- (void)nameEditingEnded:(id)sender;
- (void)uploadItem;
- (BOOL)haveUnpostedChanges;
- (void)updateValues;
- (NSString *)offerActionString;

- (void)shareButtonPressed:(id)sender;
- (void)backButtonPressed:(id)sender;
- (void)stateButtonPressed:(id)sender;
- (void)saveAndDismissStatePicker:(id)sender;


@end
