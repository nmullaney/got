//
//  GOTEditItemViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/17/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTEditItemViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "GOTItem.h"
#import "GOTImageStore.h"

@implementation GOTEditItemViewController

@synthesize item;

- (id) init
{
    self = [super self];
    if (self) {
        // This hides the TabBar used for main navigation
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)setItem:(GOTItem *)i
{
    [[self navigationItem] setTitle:[i name]];
    item = i;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self enhanceDescField];
    
    [nameField setText:[[self item] name]];
    [descField setText:[[self item] desc]];
    if ([[self item] image]) {
        [imageView setImage:[[self item] image]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self item] setName:[nameField text]];
    [[self item] setDesc:[descField text]];
}


- (void)enhanceDescField
{
    // This creates a border around the textField
    // A little rough -- it doesn't have a shadow
    [descField setBackgroundColor:[UIColor whiteColor]];
    descField.layer.borderWidth = 2.0f;
    descField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    descField.layer.cornerRadius = 8;
    descField.layer.masksToBounds = YES;
    
    descField.layer.backgroundColor = [[UIColor whiteColor] CGColor];
}

#pragma mark camera methods

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Create a unique ID for this image, and store it in the image store
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *key = (__bridge NSString *)newUniqueIDString;
    [item setImageKey:key];
    [[GOTImageStore sharedStore] setImage:image forKey:key];
    [item setThumbnailDataFromImage:image];
    
    [imageView setImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UI control methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)nameEditingEnded:(id)sender {
    [[self navigationItem] setTitle:[nameField text]];
}

- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
}

#pragma mark -

@end
