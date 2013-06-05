//
//  GOTFreeItemDetailViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTItem;
@class GOTItemMetadataView;

@interface GOTFreeItemDetailViewController : UIViewController
{
    IBOutlet UIView *view;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIActivityIndicatorView *imageLoadingIndicator;
    
    UILabel *descLabel;
    UILabel *messagesSentLabel;
    GOTItemMetadataView *metaView;
    
    NSMutableArray *allConstraints;
    
}

@property (nonatomic, strong) GOTItem *item;

- (UILabel *)addLabelWithText:(NSString *)labelText;
- (UILabel *)addLabelWithText:(NSString *)labelText withFont:(UIFont *)font;
- (UILabel *)createLabelWithText:(NSString *)labelText;
- (UILabel *)createLabelWithText:(NSString *)labelText withFont:(UIFont *)font;
- (NSNumber *)heightForLabel:(UILabel *)label;
- (NSString *)messagesSentString;
- (void)addMessagesSentLabel;
- (void)updateMessagesSent;
- (void)autolayout;
- (NSArray *)constraintsForView:(UIView *)view
               withPreviousView:(UIView *)prev
                     withHeight:(NSNumber *)height;
- (NSArray *)constraintsForMessagesSentLabel:(UILabel *)label;
- (void)reloadItem;

@end
