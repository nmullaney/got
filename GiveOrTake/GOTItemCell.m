//
//  GOTItemCell.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/26/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemCell.h"

#import "GOTItemState.h"

@implementation GOTItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"initting new GOTItemCell");
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItemImage:(UIImage *)image
{
    [itemThumbnailView setImage:image];
}

- (void)setTitle:(NSString *)title
{
    NSLog(@"Setting title to %@", title);
    [titleLabel setText:title];
}

- (void)setState:(GOTItemState *)state
{
    [statusView setImage:[GOTItemState imageForState:state]];
}

@end
