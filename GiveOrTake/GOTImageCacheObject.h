//
//  GOTImageCacheObject.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 9/9/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTImageCacheObject : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSDate *updateDate;

- (id)initWithImage:(UIImage *)newImage;

@end
