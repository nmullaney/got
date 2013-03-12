//
//  GOTFreeItemDetailViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTFreeItemDetailViewController.h"

#import "GOTItem.h"
#import "GOTImageStore.h"
#import "GOTConstants.h"

@implementation GOTFreeItemDetailViewController

@synthesize item;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [imageLoadingIndicator startAnimating];
    [[GOTImageStore sharedStore] fetchImageForItem:[self item] withCompletion:^(id image, NSError *err) {
        [imageLoadingIndicator stopAnimating];
        if (image) {
            [imageView setImage:image];
            [[self view] setNeedsDisplay];
        }
        if (err) {
            NSLog(@"error fetching image: %@", [err localizedDescription]);
        }
    }];
    
    float borderSize = 5.0;
    float width = [[UIScreen mainScreen] bounds].size.width - 2 * borderSize;
    int heightSoFar = imageView.bounds.origin.y + imageView.bounds.size.height + borderSize;
    UIFont *font = [GOTConstants defaultSmallFont];
    
    CGSize labelSize = [[[self item] desc] sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(borderSize, heightSoFar, width, labelSize.height)];
    [descLabel setText:[[self item] desc]];
    [descLabel setFont:font];
    [descLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [descLabel setNumberOfLines:0];
    [scrollView addSubview:descLabel];
    heightSoFar = heightSoFar + labelSize.height + borderSize;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [dateFormatter stringFromDate:[[self item] datePosted]];
    
    NSString *fullDateLabelString = [NSString stringWithFormat:@"Posted on %@", dateString];
    CGSize dateLabelSize = [fullDateLabelString sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT)];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(borderSize, heightSoFar, width, dateLabelSize.height)];
    [dateLabel setText:fullDateLabelString];
    [dateLabel setFont:font];
    [scrollView addSubview:dateLabel];
    heightSoFar = heightSoFar + dateLabelSize.height + borderSize;

    [scrollView setContentSize:CGSizeMake(width + 2 * borderSize, heightSoFar)];
    [scrollView setNeedsDisplay];
}

- (IBAction)wantButtonPressed:(id)sender {
    // TODO
    NSLog(@"Want pressed");
}

- (void)dealloc
{
    NSLog(@"Dealloc for FreeItemDetailViewController: %@", [[self item] name]);
}

@end
