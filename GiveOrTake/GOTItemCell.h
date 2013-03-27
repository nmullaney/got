//
//  GOTItemCell.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/26/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GOTItem.h"

@interface GOTItemCell : UITableViewCell
{
    __weak IBOutlet UIImageView *itemThumbnailView;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIImageView *statusView;
}

- (void)setItemImage:(UIImage *)image;
- (void)setTitle:(NSString *)title;
- (void)setState:(ItemState)state;

@end
