//
//  GOTItemMetadataView.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 6/5/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GOTItem;

@interface GOTItemMetadataView : UIView {
    
    __weak IBOutlet UILabel *postedByLabel;
    __weak IBOutlet UIImageView *karmaImage;
    __weak IBOutlet UILabel *karmaLabel;

    __weak IBOutlet UIImageView *statusImage;
    __weak IBOutlet UILabel *statusLabel;
    
    __weak IBOutlet UILabel *distanceLabel;
    
    __weak IBOutlet UILabel *updatedLabel;
    __weak IBOutlet UILabel *postedLabel;
}

- (void)loadItemData:(GOTItem *)item;
- (void)loadUserForItem:(GOTItem *)item;
- (NSString *)timeAgo:(NSDate *)date;

@end
