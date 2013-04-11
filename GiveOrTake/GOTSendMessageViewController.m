//
//  GOTSendMessageViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/8/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTSendMessageViewController.h"

#import "GOTConstants.h"
#import "GOTItem.h"
#import "GOTUser.h"
#import "GOTUserStore.h"

@interface GOTSendMessageViewController ()

@end

@implementation GOTSendMessageViewController

@synthesize item;

static float border = 10;

- (id)initWithItem:(GOTItem *)it
{
    self = [super init];
    if (self) {
        [self setItem:it];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [[self navigationItem] setTitle:@"New Message"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelMessage:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
    [[self navigationItem] setRightBarButtonItem:sendButton];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float contentWidth = screenRect.size.width - 2 * border;
    float heightSoFar = border;
    
    UIFont *font = [GOTConstants defaultMediumFont];
    NSString *toLabelStr = @"To:";
    CGSize toLabelSize = [toLabelStr sizeWithFont:font forWidth:contentWidth lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(border, heightSoFar, contentWidth, toLabelSize.height)];
    [toLabel setFont:font];
    [toLabel setTextColor:[GOTConstants defaultGrayTextColor]];
    [toLabel setTextAlignment:NSTextAlignmentLeft];
    [toLabel setBackgroundColor:[UIColor clearColor]];
    [self setTextForToLabel:toLabel];
    [self.view addSubview:toLabel];
    heightSoFar += border + toLabelSize.height;
    
    NSString *subjectLabelStr = [NSString stringWithFormat:@"Subject: %@", [[self item] name]];
    CGSize subjectLabelSize = [subjectLabelStr sizeWithFont:font forWidth:contentWidth lineBreakMode:NSLineBreakByTruncatingTail];
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(border, heightSoFar, contentWidth, subjectLabelSize.height)];
    [subjectLabel setFont:font];
    [subjectLabel setTextColor:[GOTConstants defaultGrayTextColor]];
    [subjectLabel setTextAlignment:NSTextAlignmentLeft];
    [subjectLabel setBackgroundColor:[UIColor clearColor]];
    [subjectLabel setText:subjectLabelStr];
    [self.view addSubview:subjectLabel];
    heightSoFar += border + subjectLabelSize.height;
    
    // This will end up being re-sized once the keyboard appears
    float navHeight = [[[self navigationController] navigationBar] bounds].size.height;
    float statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float textViewHeight = screenRect.size.height - navHeight - heightSoFar - border - statusBarHeight;
    messageTextView = [[GOTTextView alloc] initWithFrame:CGRectMake(border, heightSoFar, contentWidth, textViewHeight)];
    [messageTextView setFont:[GOTConstants defaultMediumFont]];
    [messageTextView setScrollEnabled:YES];
     NSString *actionDesc = @"Compose a message to the owner of this item.  Ask a question about the item or inquire if it's still available.  Your email address will be shared with the recipient of this message.";
    [messageTextView setPlaceholder:actionDesc];
    [self.view addSubview:messageTextView];
}

- (void)setTextForToLabel:(UILabel *)toLabel
{
    NSNumber *userID = [[self item] userID];
    [[GOTUserStore sharedStore] fetchUserWithUserID:userID withCompletion:^(GOTUser *user, NSError *err) {
        if (err) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username fetch failed" message:@"Failed to fetch the username of the owner of this item" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        if (user) {
            [toLabel setText:[NSString stringWithFormat:@"To: %@", [user username]]];
        }
    }];
}

- (IBAction)backgroundTapped:(id)sender {
    [[self view] endEditing:YES];
    [[self view] becomeFirstResponder];
}

- (void)cancelMessage:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)sendMessage:(id)sender {
    NSLog(@"Sending message");
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    // Keyboard starts offscreen, so only the height is useful
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self resizeMessageViewWithExtraSpace:kbSize.height];
}

- (void)keyboardWasHidden:(NSNotification *)notification
{
    [self resizeMessageViewWithExtraSpace:0];
}

- (void)resizeMessageViewWithExtraSpace:(float)verticalSpace
{
    CGRect currentMessageViewFrame = [messageTextView frame];
    float navHeight = [[[self navigationController] navigationBar] bounds].size.height;
    float statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    float topOfKb = [[UIScreen mainScreen] bounds].size.height - verticalSpace;
    currentMessageViewFrame.size.height = topOfKb - currentMessageViewFrame.origin.y - navHeight - statusBarHeight - border;
    [messageTextView setFrame:currentMessageViewFrame];
    [messageTextView setNeedsDisplay];
}

@end
