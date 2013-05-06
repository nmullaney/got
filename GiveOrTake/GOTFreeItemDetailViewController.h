//
//  GOTFreeItemDetailViewController.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTItem;

@interface GOTFreeItemDetailViewController : UIViewController
{
    IBOutlet UIView *view;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIActivityIndicatorView *imageLoadingIndicator;
    
    NSMutableArray *labels;
    NSMutableArray *labelConstraints;
    
    UILabel *messagesSentLabel;
}

@property (nonatomic, strong) GOTItem *item;

- (UILabel *)addLabelWithText:(NSString *)labelText;
- (UILabel *)createLabelWithText:(NSString *)labelText;
- (NSNumber *)heightForLabel:(UILabel *)label;
- (NSString *)dateStringForDate:(NSDate *)date;
- (void)loadUsernameLabel;
- (NSString *)messagesSentString;
- (void)addMessagesSentLabel;
- (void)autolayout;

@end
