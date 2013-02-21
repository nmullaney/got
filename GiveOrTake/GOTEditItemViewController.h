//
//  GOTEditItemViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/17/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTItem;

@interface GOTEditItemViewController : UIViewController
    <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    IBOutlet UIView *view;
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextView *descField;
    __weak IBOutlet UIImageView *imageView;
}

@property (nonatomic, strong) GOTItem *item;

- (void)enhanceDescField;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)nameEditingEnded:(id)sender;

@end
