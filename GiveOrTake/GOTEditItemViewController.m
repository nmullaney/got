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
        imageChanged = NO;
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
    [imageActivityIndicator startAnimating];
    [[GOTImageStore sharedStore] fetchImageForItem:[self item] withCompletion:^(id image, NSError *err) {
        [imageActivityIndicator stopAnimating];
        if (image) {
            [imageView setImage:image];
        }
        if (err) {
            // TODO alert view?
            NSLog(@"An error occurred while fetching the image: %@", [err localizedDescription]);
        }
    }];
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
    
    imageActivityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageActivityIndicator setHidesWhenStopped:YES];
    [imageActivityIndicator stopAnimating];
    [imageActivityIndicator setFrame:[imageView frame]];
    [control addSubview:imageActivityIndicator];
    
    // TODO: this button should change to "Update Offer"
    // once the offer is posted
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
            // Upload the image
            if (imageChanged) {
                NSLog(@"Updating the image because it changed");
                [[GOTImageStore sharedStore] uploadImageForKey:[[self item] imageKey]
                                                    withItemID:[[self item] itemID]];
                imageChanged = NO;
            } else {
                NSLog(@"Not updating the image: no change");
            }
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
    NSLog(@"Setting imageChanged to true");
    imageChanged = YES;
    UIImage *origImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *image = [item imageFromPicture:origImage];
    
    // Create a unique ID for this image, and store it in the image store
    NSString *key = [GOTImageStore createImageKey];
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
