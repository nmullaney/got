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
#import "GOTUserStore.h"
#import "GOTUser.h"
#import "GOTActiveUser.h"
#import "GOTConstants.h"
#import "JSONUtil.h"
#import "GOTShareViewController.h"

@implementation GOTEditItemViewController

@synthesize item, draftState, draftStateUserID, usersWantItem;

int PICKER_VIEW_TAG = 1;

- (id) init
{
    self = [super init];
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
    [self setDraftState:[i state]];
    [[GOTUserStore sharedStore] fetchUsersWhoRequestedItemID:[i itemID] withCompletion:^(NSArray *users, NSError *err) {
        if (err) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to fetch users who want this item" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        [self setUsersWantItem:users];
        [self setDraftStateUserID:[i stateUserID]];
        if ([[self view] viewWithTag:PICKER_VIEW_TAG]) {
            UIPickerView *pickerView = (UIPickerView *)[[self view] viewWithTag:PICKER_VIEW_TAG];
            [pickerView reloadAllComponents];
        }
    }];
    item = i;
}

- (NSUInteger)draftUserIndex
{
    NSUInteger selectedUser = 0;
    if (![self draftStateUserID]) {
        return selectedUser;
    }
    for (int i = 0; i < [[self usersWantItem] count]; i++) {
        GOTUser *user = [[self usersWantItem] objectAtIndex:i];
        if ([[user userID] intValue] == [[self draftStateUserID] intValue]) {
            selectedUser = i;
        }
    }
    return selectedUser;
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
    }
    [postOfferButton setTitle:[self offerActionString] forState:UIControlStateNormal];
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
    int threequartWidth = fullScreenRect.size.width * 3 / 4 - 2 * border;
    int threequartStartX = fullScreenRect.size.width / 2 - threequartWidth / 2;
    int halfx = fullScreenRect.size.width / 2 - halfWidth / 2;
    int fullWidth = fullScreenRect.size.width - 2 * border;
    int picButtonHeight = 30;
    int currentY = border;
    
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
                                               currentY,
                                               fullWidth,
                                               nameFieldHeight)];
    [control addSubview:nameField];
    [nameField setPlaceholder:@"Choose a name for your item."];
    [nameField setBorderStyle:UITextBorderStyleRoundedRect];
    [nameField setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [nameField setDelegate:self];
    [nameField addTarget:self action:@selector(nameEditingEnded:) forControlEvents:UIControlEventEditingDidEnd];
    currentY = currentY + border + nameFieldHeight;
    
    NSString *stateLabelLabelStr = @" Item State: ";
    CGSize stateLabelLabelSize = [stateLabelLabelStr sizeWithFont:[GOTConstants defaultMediumFont] constrainedToSize:CGSizeMake(fullWidth, stateButtonHeight)];
    UILabel *stateLabelLabel = [[UILabel alloc] initWithFrame:CGRectMake(border, currentY, stateLabelLabelSize.width, stateButtonHeight)];
    [stateLabelLabel setFont:[GOTConstants defaultMediumFont]];
    [stateLabelLabel setText:stateLabelLabelStr];
    [stateLabelLabel setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:stateLabelLabel];
    float currentX = border * 2 + stateLabelLabelSize.width;
    
    float stateLabelWidth = [self maxStatusLabelWidth];
    UIView *stateLabelView = [[UIView alloc] initWithFrame:CGRectMake(currentX, currentY, stateLabelWidth + 30, stateButtonHeight)];
    [stateLabelView setBackgroundColor:[UIColor whiteColor]];
    stateLabelView.layer.cornerRadius = 8.0;
    stateImage = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 7.5, 15, 15)];
    [stateLabelView addSubview:stateImage];
    stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, stateLabelWidth, stateButtonHeight)];
    [stateLabel setBackgroundColor:[UIColor clearColor]];
    [stateLabelView addSubview:stateLabel];
    [scrollView addSubview:stateLabelView];
    currentX = currentX + stateLabelWidth + 30 + border;
    
    stateButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stateButton setFrame:CGRectMake(currentX, currentY, fullWidth - currentX + border, stateButtonHeight)];
    [stateButton setTitle:@"Change" forState:UIControlStateNormal];
    if ([[self item] state] == [GOTItemState DRAFT]) {
        [stateButton setHidden:YES];
    }
    [stateButton addTarget:self
                    action:@selector(stateButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:stateButton];
    currentY = currentY + border + stateButtonHeight;
  
    descField = [[GOTTextView alloc]
                 initWithFrame:CGRectMake(border,
                                          currentY,
                                          fullWidth,
                                          descFieldHeight)];
    [descField setPlaceholder:@"Describe your item."];
    [descField setFont:[nameField font]];
    [control addSubview:descField];
    currentY = currentY + border + descFieldHeight;
    
    UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takePhotoButton setFrame:CGRectMake(halfx,
                                         currentY,
                                         halfWidth,
                                         picButtonHeight)];
    [takePhotoButton addTarget:self
                        action:@selector(takePicture:)
              forControlEvents:UIControlEventTouchUpInside];
    currentY = currentY + border + picButtonHeight;
 
    // TODO: be nice to have a camera icon, instead of text here
    [takePhotoButton setTitle:@"Add Photo" forState:UIControlStateNormal];
    [control addSubview:takePhotoButton];
    
    imageView = [[UIImageView alloc]
                 initWithFrame:CGRectMake(border,
                                          currentY,
                                          fullWidth,
                                          fullWidth)];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    [control addSubview:imageView];
    currentY = currentY + border + fullWidth;
    
    imageActivityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageActivityIndicator setHidesWhenStopped:YES];
    [imageActivityIndicator stopAnimating];
    [imageActivityIndicator setFrame:[imageView frame]];
    [control addSubview:imageActivityIndicator];
    
    if (![[[self item] state] isEqual:[GOTItemState DRAFT]]) {
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setFrame:CGRectMake(threequartStartX, currentY, threequartWidth, picButtonHeight)];
        [shareButton setTitle:@"Share on Facebook" forState:UIControlStateNormal];
        [[shareButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        shareButton.layer.cornerRadius = 10.0;
        [shareButton setBackgroundColor:[GOTConstants defaultDarkBlueColor]];
        [shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [control addSubview:shareButton];
        currentY = currentY + border + picButtonHeight;
    }
    
    // TODO: this button should change to "Update Offer"
    // once the offer is posted
    postOfferButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postOfferButton setFrame:CGRectMake(threequartStartX,
                                         currentY,
                                         threequartWidth,
                                         picButtonHeight)];
    [control addSubview:postOfferButton];
    [postOfferButton setBackgroundColor:[UIColor redColor]];
    [[postOfferButton titleLabel] setFont:[UIFont boldSystemFontOfSize:16]];
    postOfferButton.layer.cornerRadius = 10.0;
    [postOfferButton addTarget:self
                        action:@selector(uploadItem)
              forControlEvents:UIControlEventTouchUpInside];
    currentY = currentY + border + picButtonHeight;
    
    scrollView.contentSize = CGSizeMake(fullScreenRect.size.width, currentY);
    [scrollView becomeFirstResponder];

    self.view = scrollView;
}

- (float)maxStatusLabelWidth
{
    float maxWidth = 0;
    for (NSString *state in [GOTItemState values]) {
        CGSize size = [state sizeWithFont:[GOTConstants defaultMediumFont]];
        if (size.width > maxWidth) {
            maxWidth = size.width;
        }
    }
    // Add in a little padding
    return maxWidth + 15;
}

- (void)shareButtonPressed:(id)sender
{
    GOTShareViewController *svc = [[GOTShareViewController alloc] initWithItem:[self item]];
    [[self navigationController] pushViewController:svc animated:YES];
}

- (void)backButtonPressed:(id)sender
{
    if ([self haveUnpostedChanges]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Unsaved Changes" delegate:self cancelButtonTitle:@"Continue without posting" destructiveButtonTitle:nil otherButtonTitles:[self offerActionString], nil];
        [actionSheet showInView:self.view];
    } else {
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (NSString *)offerActionString
{
    if ([[[self item] state] isEqual:[GOTItemState DRAFT]]) {
        return @"Post Offer";
    } else {
        return @"Update Offer";
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
    NSString *descFieldText = [descField text];
    if ([descFieldText isEqualToString:@""]) {
        descFieldText = nil;
    }
    if (![[[self item] name] isEqualToString:[nameField text]] ||
        ![self nilOrEqual:[[self item] desc] to:descFieldText] ||
        ![[[self item] state] isEqualToString:[GOTItemState getValue:[stateLabel text]]] ||
        ![self nilOrEqual:[[self item] stateUserID] to:[self draftStateUserID]] ||
        [[self item] imageNeedsUpload] ||
        [[self item] hasUnsavedChanges]) {
        return YES;
    }
    return NO;
}

- (BOOL)nilOrEqual:(id)value1 to:(id)value2
{
    if (!value1 && !value2) {
        return YES;
    } else if (value1 && !value2) {
        return NO;
    } else if (!value1 && value2) {
        return NO;
    } else {
        return [value1 isEqual:value2];
    }
}

- (void)updateValues
{
    [[self item] setName:[nameField text]];
    [[self item] setDesc:[descField text]];
    [[self item] setState:[self draftState]];
    [[self item] setStateUserID:[self draftStateUserID]];
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
        if (err) {
            // TODO centralize the errror code
            NSString *errorString = [NSString stringWithFormat:@"Failed to upload: %@",
                                     [err localizedDescription]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:errorString
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
            return;
        } else if ([self item]) {
            [[self item] setHasUnsavedChanges:NO];
            NSLog(@"%@", dict);
            NSDictionary *itemDict = [dict objectForKey:@"item"];
            NSNumber *itemID = [itemDict objectForKey:@"id"];
            [[self item] setItemID:itemID];
            if ([itemDict objectForKey:@"state"]) {
                GOTItemState *state = [GOTItemState getValue:[itemDict objectForKey:@"state"]];
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
        }
        if ([dict objectForKey:@"karma"]) {
            NSDictionary *karmaDict = [dict objectForKey:@"karma"];
            [[GOTUserStore sharedStore] updateActiveUserKarma:karmaDict];
            NSNumber *karmaChange = [karmaDict objectForKey:@"karmaChange"];
            if (karmaChange > 0) {
                NSString *message = [NSString stringWithFormat:@"Your karma has increased by %@ points!", karmaChange];
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Karma Improved!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
        }
    };
    
    [[GOTItemsStore sharedStore] uploadItem:[self item] withCompletion:block];
}

#pragma mark camera methods

- (void)takePicture:(id)sender {
    // Dismiss any editing in progress
    [[self view] endEditing:YES];
    
    imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            // TODO: this may look wrong/bad on a non-retina screen
            CGRect bounds = [[UIScreen mainScreen] bounds];
            float bottomBarHeight = 100;
            UIButton *libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            float buttonWidth = 75;
            float buttonHeight = 35;
            float border = 15;
            [libraryButton setFrame:CGRectMake(bounds.size.width - buttonWidth - border,
                                               bounds.size.height - bottomBarHeight - buttonHeight - border,
                                               buttonWidth,
                                               buttonHeight)];
            [libraryButton setTitle:@"Library" forState:UIControlStateNormal];
            [libraryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            UIColor *backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
            [libraryButton setBackgroundColor:backgroundColor];
            libraryButton.layer.borderColor = [UIColor blackColor].CGColor;
            libraryButton.layer.borderWidth = 1.0f;
            libraryButton.layer.cornerRadius = buttonHeight / 2;
            [libraryButton addTarget:self action:@selector(showPhotoLibrary:)
                    forControlEvents:UIControlEventTouchUpInside];
            [imagePicker setCameraOverlayView:libraryButton];
        }
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePicker setShowsCameraControls:YES];
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

- (void)showPhotoLibrary:(id)sender
{
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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

- (float)statePickerHeight
{
    return 216;
}

- (float)saveButtonHeight
{
    return 30;
}

- (float)stateViewBorder
{
    return 5;
}

- (float)stateSubViewHeight
{
    return [self statePickerHeight] + [self saveButtonHeight] + [self stateViewBorder] * 2;
}

- (void)stateButtonPressed:(id)sender
{
    // Dismiss any editing in progress
    [[self view] endEditing:YES];
    
    UIPickerView *statePicker = [[UIPickerView alloc] init];
    [statePicker setShowsSelectionIndicator:YES];
    [statePicker setDataSource:self];
    [statePicker setDelegate:self];
    [statePicker setTag:PICKER_VIEW_TAG];
    GOTItemState *labelState = [GOTItemState getValue:[stateLabel text]];
    int currentRow = [[GOTItemState pickableValues] indexOfObject:labelState];
    [statePicker selectRow:currentRow inComponent:0 animated:YES];
    if ([self draftStateUserID] && [statePicker numberOfComponents] == 2) {
        [statePicker selectRow:[self draftUserIndex] inComponent:1 animated:YES];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setFrame:CGRectMake(screenRect.size.width / 4,
                                    [self stateViewBorder],
                                    screenRect.size.width / 2,
                                    [self saveButtonHeight])];
    [saveButton setTitle:@"Set Item State" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveAndDismissStatePicker:)
         forControlEvents:UIControlEventTouchUpInside];
    [statePicker setFrame:CGRectMake(0,
                                     2 * [self stateViewBorder] + [self saveButtonHeight],
                                     screenRect.size.width,
                                     [self statePickerHeight])];
    UIView *subView = [[UIView alloc]
                       initWithFrame:CGRectMake(0, screenRect.size.height, screenRect.size.width, [self stateSubViewHeight])];
    [subView addSubview:saveButton];
    [subView addSubview:statePicker];
    UIColor *subviewBackgroundColor = [UIColor colorWithRed:0.573 green:0.608 blue:0.675 alpha:0.95];
    [subView setBackgroundColor:subviewBackgroundColor];
    
    UIView *fullView = [[UIView alloc] initWithFrame:screenRect];
    UIColor *backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    [fullView setBackgroundColor:backgroundColor];
    [fullView addSubview:subView];
    
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setScrollEnabled:NO];
    [self.view addSubview:fullView];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect newSubviewFrame = CGRectMake(0,
                                            screenRect.size.height - [self stateSubViewHeight],
                                            screenRect.size.width,
                                            [self stateSubViewHeight]);
        [subView setFrame:newSubviewFrame];
        UIColor *backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [fullView setBackgroundColor:backgroundColor];
    }];
}

- (void)saveAndDismissStatePicker:(id)sender
{
    UIButton *saveButton = (UIButton *)sender;
    UIView *subView = [saveButton superview];
    UIPickerView *pickerView = (UIPickerView *)[subView viewWithTag:PICKER_VIEW_TAG];
    UIView *fullView = [subView superview];
    NSInteger row = [pickerView selectedRowInComponent:0];
    NSLog(@"row = %d", row);
    GOTItemState *state = [[self item] state];
    if (row >= 0) {
        state = [[GOTItemState pickableValues] objectAtIndex:row];
    }
    if (state == [GOTItemState AVAILABLE]) {
        [self setDraftStateUserID:nil];
    }
    [stateLabel setText:state];
    [stateImage setImage:[GOTItemState imageForState:state]];
    [stateLabel setNeedsDisplay];
    [stateImage setNeedsDisplay];
    UIScrollView *scrollView = (UIScrollView *)self.view;
    [scrollView setScrollEnabled:YES];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect newFrame = CGRectMake(0,
                                                      screenRect.size.height,
                                                      screenRect.size.width,
                                                      [self stateSubViewHeight]);
                         subView.frame = newFrame;
                         UIColor *backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
                         [[pickerView superview] setBackgroundColor:backgroundColor];
                     }
                     completion:^(BOOL finished) {
                         [fullView removeFromSuperview];
                     }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        GOTItemState *state = [[GOTItemState pickableValues] objectAtIndex:row];
        [self setDraftState:state];
        NSLog(@"reloading all components");
        [pickerView reloadAllComponents];
        [pickerView setNeedsDisplay];
    } else if (component == 1) {
        GOTUser *stateUser = [[self usersWantItem] objectAtIndex:row];
        [self setDraftStateUserID:[stateUser userID]];
        NSLog(@"Setting Draft user to: %@, current item id value: %@", stateUser, [[self item] stateUserID]);
    }
}

#pragma mark -
#pragma mark picker view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([self draftState] == [GOTItemState AVAILABLE] || [[self usersWantItem] count] == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [GOTItemState pickableCount];
    } else if (component == 1){
        return [[self usersWantItem] count];
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)rowView
{
    if (component == 0) {
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
    } else {
        if (!rowView) {
            CGSize rowSize = [pickerView rowSizeForComponent:component];
            rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rowSize.width, rowSize.height)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, rowSize.width, rowSize.height)];
            [label setBackgroundColor:[UIColor clearColor]];
            [rowView addSubview:label];
           
        }
        UILabel *userName = [[rowView subviews] objectAtIndex:0];
        GOTUser *user = [[self usersWantItem] objectAtIndex:row];
        [userName setText:[user username]];
        return rowView;
    }
}

#pragma mark -

@end
