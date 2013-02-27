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
    
    void (^block)(id, NSError *) = ^void(id obj, NSError *err) {
        NSLog(@"calling item upload completion block");
        if (obj) {
            GOTItemID *itemIDHolder = (GOTItemID *)obj;
            [[self item] setItemID:[itemIDHolder itemID]];
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
