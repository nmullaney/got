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
#import "GOTTextView.h"
#import "GOTItemState.h"

@implementation GOTEditItemViewController

@synthesize item;

- (id) init
{
    self = [super self];
    if (self) {
        // This hides the TabBar used for main navigation
        self.hidesBottomBarWhenPushed = YES;
        
        // Custom leftBarButton allows us to check for whether or not the item
        // has been updated before popping the view
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]
                                          initWithTitle:@"All Offers"
                                          style:UIBarButtonItemStyleBordered
                                          target:self
                                          action:@selector(backButtonPressed:)];
        [[self navigationItem] setLeftBarButtonItem:leftBarButton];
    }
    return self;
}

- (void)setItem:(GOTItem *)i
{
    [[self navigationItem] setTitle:[i name]];
    item = i;
}

- (void)updateViewForItem
{
    [nameField setText:[[self item] name]];
    [descField setText:[[self item] desc]];
    [stateLabel setText:[[self item] state]];
    [stateImage setImage:[GOTItemState imageForState:[[self item] state]]];
    if ([[[self item] state] isEqual:[GOTItemState DRAFT]]) {
        [stateChevronView setHidden:YES];
        [stateButton removeTarget:self action:@selector(stateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [postOfferButton setTitle:@"Post Offer" forState:UIControlStateNormal];
    } else {
        [postOfferButton setTitle:@"Update Offer" forState:UIControlStateNormal];
    }
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

- (void)viewDidLoad
{
    [self updateViewForItem];
}

- (void)loadView {

    CGRect fullScreenRect = [[UIScreen mainScreen] applicationFrame];
    int viewHeight = 2000;
    int border = 10;
    int nameFieldHeight = 25;
    int stateButtonHeight = 30;
    int descFieldHeight = 100;
    int halfWidth = fullScreenRect.size.width / 2 - 2 * border;
    int halfx = fullScreenRect.size.width / 2 - halfWidth / 2;
    int fullWidth = fullScreenRect.size.width - 2 * border;
    int picButtonHeight = 30;
    int currentX = border;
    
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
                                               currentX,
                                               fullWidth,
                                               nameFieldHeight)];
    [control addSubview:nameField];
    [nameField setPlaceholder:@"Choose a name for your item."];
    [nameField setBorderStyle:UITextBorderStyleRoundedRect];
    [nameField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [nameField setDelegate:self];
    [nameField addTarget:self action:@selector(nameEditingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    currentX = currentX + border + nameFieldHeight;
    
    stateButton = [[UIControl alloc] initWithFrame:CGRectMake(border, currentX, fullWidth, stateButtonHeight)];
    [stateButton setBackgroundColor:[UIColor whiteColor]];
    [stateButton.layer setCornerRadius:8];
    stateImage = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 7.5, 15, 15)];
    [stateButton addSubview:stateImage];
    stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, fullWidth - 30 * 2, stateButtonHeight)];
    [stateButton addSubview:stateLabel];
    UIImage *chevron = [UIImage imageNamed:@"chevron"];
    stateChevronView = [[UIImageView alloc] initWithFrame:CGRectMake(fullWidth - 30, 12, 15, 7.5)];
    [stateChevronView setImage:chevron];
    [stateButton addTarget:self
                    action:@selector(stateButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    [stateButton addSubview:stateChevronView];
    
    [control addSubview:stateButton];
    currentX = currentX + border + stateButtonHeight;
  
    descField = [[GOTTextView alloc]
                 initWithFrame:CGRectMake(border,
                                          currentX,
                                          fullWidth,
                                          descFieldHeight)];
    [descField setPlaceholder:@"Describe your item."];
    [descField setFont:[nameField font]];
    [control addSubview:descField];
    currentX = currentX + border + descFieldHeight;
    
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takePhotoButton setFrame:CGRectMake(halfx,
                                         currentX,
                                         halfWidth,
                                         picButtonHeight)];
    [takePhotoButton addTarget:self
                        action:@selector(takePicture:)
              forControlEvents:UIControlEventTouchUpInside];
    currentX = currentX + border + picButtonHeight;
 
    // TODO: be nice to have a camera icon, instead of text here
    [takePhotoButton setTitle:@"Take a Photo" forState:UIControlStateNormal];
    [control addSubview:takePhotoButton];
    
    imageView = [[UIImageView alloc]
                 initWithFrame:CGRectMake(border,
                                          currentX,
                                          fullWidth,
                                          fullWidth)];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    [control addSubview:imageView];
    currentX = currentX + border + fullWidth;
    
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
                                         currentX,
                                         halfWidth,
                                         picButtonHeight)];
    [control addSubview:postOfferButton];
    // TODO make this red on appearance, not on selected
    [postOfferButton setTintColor:[UIColor redColor]];
    [postOfferButton addTarget:self
                        action:@selector(uploadItem)
              forControlEvents:UIControlEventTouchUpInside];
    currentX = currentX + border + picButtonHeight;
    
    scrollView.contentSize = CGSizeMake(fullScreenRect.size.width, currentX);
    [scrollView becomeFirstResponder];

    self.view = scrollView;
}

- (void)backButtonPressed:(id)sender
{
    if ([self haveUnpostedChanges]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Unsaved Changes" delegate:self cancelButtonTitle:@"Continue without posting" destructiveButtonTitle:nil otherButtonTitles:@"Update offer", nil];
        [actionSheet showInView:self.view];
    } else {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self uploadItem];
    } else {
        // If we're not posting, we update the changed values and mark the
        // item as having unsaved changes, which can be uploaded later.
        [self updateValues];
        [[self item] setHasUnsavedChanges:YES];
    }
    [[self navigationController] popViewControllerAnimated:YES];
    NSLog(@"Clicked actionSheet button: %ld", (long)buttonIndex);
}

- (BOOL)haveUnpostedChanges
{
    if (![[[self item] name] isEqualToString:[nameField text]] ||
        ![[[self item] desc] isEqualToString:[descField text]] ||
        ![[[self item] state] isEqualToString:[GOTItemState getValue:[stateLabel text]]] ||
        [[self item] imageNeedsUpload] ||
        [[self item] hasUnsavedChanges]) {
        return YES;
    }
    return NO;
}

- (void)updateValues
{
    [[self item] setName:[nameField text]];
    [[self item] setDesc:[descField text]];
    [[self item] setState:[GOTItemState getValue:[stateLabel text]]];
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
    
    void (^block)(NSDictionary *, NSError *) = ^void(NSDictionary *dict, NSError *err) {
        NSLog(@"calling item upload completion block, error: %@", err);
        if (item) {
            [[self item] setHasUnsavedChanges:NO];
            NSLog(@"%@", dict);
            NSNumber *itemID = [dict objectForKey:@"id"];
             [[self item] setItemID:itemID];
            if ([dict objectForKey:@"state"]) {
                GOTItemState *state = [GOTItemState getValue:[dict objectForKey:@"state"]];
                [[self item] setState:state];
            }
           
            // Upload the image
            if ([[self item] imageNeedsUpload]) {
                NSLog(@"Updating the image because it changed");
                [[GOTImageStore sharedStore] uploadImageForItem:[self item]];
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

#pragma mark camera methods

- (void)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePicker setAllowsEditing:YES];
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
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!pickerImage) {
        pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    UIImage *image = [item imageFromPicture:pickerImage];
    
    // Create a unique ID for this image, and store it in the image store
    NSString *key = [GOTImageStore createImageKey];
    [item setImageKey:key];
    [item setImageNeedsUpload:YES];
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
#pragma mark state button methods

- (void)stateButtonPressed:(id)sender
{
    UIPickerView *statePicker = [[UIPickerView alloc] init];
    [statePicker setShowsSelectionIndicator:YES];
    [statePicker setDataSource:self];
    [statePicker setDelegate:self];
    GOTItemState *labelState = [GOTItemState getValue:[stateLabel text]];
    int currentRow = [[GOTItemState pickableValues] indexOfObject:labelState];
    [statePicker selectRow:currentRow inComponent:0 animated:YES];
    int statePickerHeight = 216; // Standard picker height
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [statePicker setFrame:CGRectMake(0, screenRect.size.height - statePickerHeight, screenRect.size.width, statePickerHeight)];
    UIView *fullView = [[UIView alloc] initWithFrame:screenRect];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [fullView setBackgroundColor:backgroundColor];
    [fullView addSubview:statePicker];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setScrollEnabled:NO];
    [self.view addSubview:fullView];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    GOTItemState *state = [[GOTItemState pickableValues] objectAtIndex:row];
    [stateLabel setText:state];
    [stateImage setImage:[GOTItemState imageForState:state]];
    [stateLabel setNeedsDisplay];
    [stateImage setNeedsDisplay];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setScrollEnabled:YES];
    [[pickerView superview] removeFromSuperview];
}

#pragma mark -
#pragma mark picker view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [GOTItemState pickableCount];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)rowView
{
    if (!rowView) {
        CGSize rowSize = [pickerView rowSizeForComponent:component];
        rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rowSize.width, rowSize.height)];
        float iconBorder = (rowSize.height - 15) / 2;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconBorder, iconBorder, 15, 15)];
        [rowView addSubview:iconView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconBorder * 2 + 15, 0, rowSize.width - iconBorder * 2 - 15, rowSize.height)];
        [label setBackgroundColor:[UIColor clearColor]];
        [rowView addSubview:label];
    }
    GOTItemState *state = [[GOTItemState pickableValues] objectAtIndex:row];
    UIImageView *stateIcon = [[rowView subviews] objectAtIndex:0];
    UILabel *stateName = [[rowView subviews] objectAtIndex:1];
    [stateIcon setImage:[GOTItemState imageForState:state]];
    [stateName setText:state];
    return rowView;
}

#pragma mark -

@end
