//
//  GOTTextView.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/28/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTTextView.h"

#import <QuartzCore/QuartzCore.h>

@implementation GOTTextView

@synthesize placeholderColor, placeholder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        placeholderLabel = [[UILabel alloc] initWithFrame:frame];
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [self setDelegate:self];
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
    CGRect placeHolderFrame = CGRectMake(self.bounds.origin.x + 6,
                                         self.bounds.origin.y + 6,
                                         self.bounds.size.width,
                                         self.bounds.size.height);
    [placeholderLabel setFrame:placeHolderFrame];
    [placeholderLabel sizeToFit];
    [self addSubview:placeholderLabel];
}

- (void) hidePlaceholder
{
    [placeholderLabel removeFromSuperview];
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

@end
