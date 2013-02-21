//
//  GOTSingleItemView.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/14/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTSingleItemView.h"
#import "GOTItem.h"

@implementation GOTSingleItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int topBorder = 10;
        int leftBorder = 10;
        int descLabelHeight = frame.size.height / 2 - 60;
        int width = frame.size.width - 20;
        descLabel = [[UILabel alloc] initWithFrame:CGRectMake(topBorder, leftBorder, width, descLabelHeight - 10)];
        [descLabel setBackgroundColor:[UIColor redColor]];
        
        int imageViewHeight = frame.size.height / 2 - 60;
        //int imageViewHeight = 0;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftBorder, topBorder + descLabelHeight, width, imageViewHeight - 10)];
        [imageView setBackgroundColor:[UIColor greenColor]];
        
        int dateLabelHeight = 20;
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftBorder, topBorder + descLabelHeight + imageViewHeight, width, dateLabelHeight)];
        [dateLabel setTextAlignment:NSTextAlignmentCenter];
        [dateLabel setBackgroundColor:[UIColor blueColor]];
        
        [self addSubview:descLabel];
        [self addSubview:imageView];
        [self addSubview:dateLabel];
    }
    return self;
}

- (void)setItem:(GOTItem *)i
{
    _item = i;
    [descLabel setText:[_item desc]];
    [imageView setImage:[_item image]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [dateFormatter stringFromDate:[_item datePosted]];
    [dateLabel setText:dateString];
    [self setNeedsDisplay];
}

@end
