//
//  GOTTextView.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/28/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GOTTextView : UITextView <UITextViewDelegate>
{
    UILabel *placeholderLabel;
}

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

- (void)showPlaceholder;
- (void)hidePlaceholder;

@end
