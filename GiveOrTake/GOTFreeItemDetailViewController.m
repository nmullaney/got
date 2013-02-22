//
//  GOTFreeItemDetailViewController.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTFreeItemDetailViewController.h"

#import "GOTItem.h"

@implementation GOTFreeItemDetailViewController

@synthesize item;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [imageView setImage:[[self item] image]];
    [descLabel setText:[[self item] desc]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [dateFormatter stringFromDate:[[self item] datePosted]];
    [dateLabel setText:dateString];
    [[self view] setNeedsDisplay];
    
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
