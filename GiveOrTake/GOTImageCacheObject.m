//
//  GOTImageCacheObject.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 9/9/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTImageCacheObject.h"

@implementation GOTImageCacheObject

@synthesize image, updateDate;

- (id)initWithImage:(UIImage *)newImage {
    self = [super init];
    if (self != nil) {
        [self setImage:newImage];
        [self setUpdateDate:[NSDate date]];
    }
    return self;
}

@end
