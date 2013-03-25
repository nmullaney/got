//
//  GOTMessageFooterViewBuilder.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTMessageFooterViewBuilder.h"

#import "GOTConstants.h"

@implementation GOTMessageFooterViewBuilder

@synthesize frame, title, message, view;

- (id)initWithFrame:(CGRect)f title:(NSString *)ttl message:(NSString *)msg
{
    self = [super init];
    if (self) {
        [self setFrame:f];
        [self setTitle:ttl];
        [self setMessage:msg];
    }
    return self;
}

// Lazily initialize the view
- (UIView *)view
{
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:[self frame]];
        [view setBackgroundColor:[GOTConstants defaultBackgroundColor]];
        float border = 10;
        float width = frame.size.width - 2 * border;
        CGSize titleLabelSize = CGSizeZero;
        if ([self title]) {
            titleLabelSize = [[self title] sizeWithFont:[GOTConstants defaultVeryLargeFont]];
            UILabel *titleLabel = [[UILabel alloc]
                                   initWithFrame:CGRectMake(border, width/4, width, titleLabelSize.height)];
            [titleLabel setText:[self title]];
            [titleLabel setFont:[GOTConstants defaultVeryLargeFont]];
            [titleLabel setTextAlignment:NSTextAlignmentCenter];
            [titleLabel setTextColor:[UIColor darkGrayColor]];
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            [view addSubview:titleLabel];
        }
        
        if ([self message]) {
            CGSize infoLabelSize = [[self message] sizeWithFont:[GOTConstants defaultLargeFont]
                                              constrainedToSize:CGSizeMake(width, MAXFLOAT)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
            float infoLabely = width/4 + titleLabelSize.height + border;
            UILabel *infoLabel = [[UILabel alloc]
                                  initWithFrame:CGRectMake(border, infoLabely, width, infoLabelSize.height)];
            [infoLabel setText:[self message]];
            [infoLabel setTextAlignment:NSTextAlignmentLeft];
            [infoLabel setTextColor:[UIColor darkGrayColor]];
            [infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [infoLabel setNumberOfLines:0];
            [infoLabel setBackgroundColor:[UIColor clearColor]];
            [view addSubview:infoLabel];
        }
    }
    return view;
}

@end
