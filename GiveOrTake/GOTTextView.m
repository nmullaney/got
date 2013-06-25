//
//  GOTTextView.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/28/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTTextView.h"
#import "GOTConstants.h"

#import <QuartzCore/QuartzCore.h>

@implementation GOTTextView

@synthesize placeholderColor, placeholder, maxContentLength;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        placeholderLabel = [[UILabel alloc] initWithFrame:frame];
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [self setDelegate:self];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        
        self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    }
    return self;
}

- (void)showPlaceholder
{
    [placeholderLabel setTextColor:[self placeholderColor]];
    [placeholderLabel setText:[self placeholder]];
    [placeholderLabel setFont:[self font]];
    placeholderLabel.layer.zPosition = - 1.0;
    //TODO: a little more to the left
    float border = 6;
    CGRect placeHolderFrame = CGRectMake(self.bounds.origin.x + border,
                                         self.bounds.origin.y + border,
                                         self.bounds.size.width - 2 * border,
                                         self.bounds.size.height - 2 * border);
    [placeholderLabel setFrame:placeHolderFrame];
    [placeholderLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [placeholderLabel setNumberOfLines:0];
    [placeholderLabel sizeToFit];
    [self addSubview:placeholderLabel];
}

- (void) hidePlaceholder
{
    [placeholderLabel removeFromSuperview];
}

- (void)setPlaceholder:(NSString *)holder
{
    placeholder = holder;
    if ([[self text] length] > 0) {
        [self hidePlaceholder];
    } else {
        [self showPlaceholder];
    }
}

- (void)setText:(NSString *)text
{
    if (text.length > 0) {
        [self hidePlaceholder];
    } else {
        [self showPlaceholder];
    }
    [super setText:text];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.hasText) {
        [self hidePlaceholder];
    } else {
        [self showPlaceholder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([self maxContentLength] == nil) {
        return YES;
    }
    NSUInteger newLength = textView.text.length - range.length + text.length;
    return (newLength <= [[self maxContentLength] integerValue] || newLength < textView.text.length);
}

@end
