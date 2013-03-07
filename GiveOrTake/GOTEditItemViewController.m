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
#import "GOTItemsStore.h"
#import "GOTItemID.h"
#import "GOTTextView.h"

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

- (void)loadView {

    CGRect fullScreenRect = [[UIScreen mainScreen] applicationFrame];
    int viewHeight = 2000;
    int border = 10;
    int nameFieldHeight = 25;
    int descFieldHeight = 100;
    int halfWidth = fullScreenRect.size.width / 2 - 2 * border;
    int halfx = fullScreenRect.size.width / 2 - halfWidth / 2;
    int fullWidth = fullScreenRect.size.width - 2 * border;
    int picButtonHeight = 30;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.contentSize = CGSizeMake(fullScreenRect.size.width, viewHeight);
    //scrollView.contentInset=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
    //scrollView.scrollIndicatorInsets=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, fullScreenRect.size.width, viewHeight)];    
    [control setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    [control addTarget:self
             action:@selector(backgroundTapped:)
   forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:control];
    
    
    nameField = [[UITextField alloc]
                      initWithFrame:CGRectMake(border,
                                               border,
                                               fullWidth,
                                               nameFieldHeight)];
    [control addSubview:nameField];
    [nameField setPlaceholder:@"Choose a name for your item."];
    [nameField setBorderStyle:UITextBorderStyleRoundedRect];
    [nameField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [nameField setDelegate:self];
    [nameField addTarget:self action:@selector(nameEditingEnded:) forControlEvents:UIControlEventEditingDidEnd];
  
    descField = [[GOTTextView alloc]
                 initWithFrame:CGRectMake(border,
                                          border * 2 + nameFieldHeight,
                                          fullWidth,
                                          descFieldHeight)];
    [descField setPlaceholder:@"Describe your item."];
    [descField setFont:[nameField font]];
    [control addSubview:descField];
    
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takePhotoButton setFrame:CGRectMake(halfx,
                                         border * 3 + nameFieldHeight + descFieldHeight,
                                         halfWidth,
                                         picButtonHeight)];
    [takePhotoButton addTarget:self
                        action:@selector(takePicture:)
              forControlEvents:UIControlEventAllTouchEvents];
 
    // TODO: be nice to have a camera icon, instead of text here
    [takePhotoButton setTitle:@"Take a Photo" forState:UIControlStateNormal];
    [control addSubview:takePhotoButton];
    
    imageView = [[UIImageView alloc]
                 initWithFrame:CGRectMake(border,
                                          border * 4 + nameFieldHeight + descFieldHeight + picButtonHeight,
                                          fullWidth,
                                          fullWidth)];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    [control addSubview:imageView];
    
    postOfferButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [postOfferButton setFrame:CGRectMake(halfx,
                                         border * 5 + nameFieldHeight + descFieldHeight + picButtonHeight + fullWidth,
                                         halfWidth,
                                         picButtonHeight)];
    [control addSubview:postOfferButton];
    [postOfferButton setTitle:@"Post Offer" forState:UIControlStateNormal];
    // TODO make this red on appearance, not on selected
    [postOfferButton setTintColor:[UIColor redColor]];
    [postOfferButton addTarget:self
                        action:@selector(uploadItem)
              forControlEvents:UIControlEventTouchUpInside];
    
    int totalHeight = border * 6 + nameFieldHeight + descFieldHeight + picButtonHeight * 2 + fullWidth;
    scrollView.contentSize = CGSizeMake(fullScreenRect.size.width, totalHeight);
    [scrollView becomeFirstResponder];

    self.view = scrollView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self updateValues];
}

- (void)updateValues
{
    [[self item] setName:[nameField text]];
    [[self item] setDesc:[descField text]];
}

- (void)uploadItem
{
    // Check for valid item -- we require name and photo
    [self updateValues];
    NSString *errorMsg = nil;
    if (![[self item] name]) {
        errorMsg = @"You must add a name for your item before you can post it.";
    } else if (![[self item] thumbnailData]) {
        errorMsg = @"You must take a picture of your item before you can post it.";
    }
    
    if (errorMsg) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Cannot Post Item"
                                                     message:errorMsg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    void (^block)(id, NSError *) = ^void(id obj, NSError *err) {
        NSLog(@"calling item upload completion block, error: %@", err);
        if (obj) {
            GOTItemID *itemIDHolder = (GOTItemID *)obj;
            [[self item] setItemID:[itemIDHolder itemID]];
            // Go back to the table view
            [[self navigationController] popViewControllerAnimated:YES];
        } else if (err) {
            // TODO centralize the errror code
            NSString *errorString = [NSString stringWithFormat:@"Failed to upload: %@",
                                     [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    };
    
    [[GOTItemsStore sharedStore] uploadItem:[self item] withCompletion:block];
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

- (void)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePicker setDelegate:self];
    void (^takingPictureDone)() = ^void() {
        // Make sure the user can clearly see the "Post Offer" button, after
        // they've added a photo
        UIScrollView *scrollView = (UIScrollView *)[self view];
        [scrollView scrollRectToVisible:postOfferButton.frame animated:YES];
        [scrollView becomeFirstResponder];
    };
    [self presentViewController:imagePicker animated:YES completion:takingPictureDone];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *origImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Crop image into a square
    // TODO: this could be better
    float sqSize = 0;
    float originX = 0;
    float originY = 0;
    if (origImage.size.width < origImage.size.height) {
        sqSize = origImage.size.width;
        originY = (origImage.size.height - origImage.size.width) / 2;
    } else {
        sqSize = origImage.size.height;
        originX = (origImage.size.width - origImage.size.height) / 2;
    }
    
    CGRect squareRect = CGRectMake(originX, originY, sqSize, sqSize);
    CGImageRef cgImage = CGImageCreateWithImageInRect([origImage CGImage], squareRect);
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:origImage.scale
                                   orientation:origImage.imageOrientation];
    
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UI control methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)nameEditingEnded:(id)sender {
    [[self navigationItem] setTitle:[nameField text]];
}

- (void)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [[self view] becomeFirstResponder];
}

#pragma mark -

@end
