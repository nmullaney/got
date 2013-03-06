//
//  GOTMutableURLPostRequest.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/5/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTMutableURLPostRequest : NSMutableURLRequest
{
    NSMutableData *body;
}

@property (nonatomic, copy) NSString *boundary;

- (id)initWithURL:(NSURL *)URL formData:(NSDictionary *)formData imageData:(NSDictionary *)imageData;
- (NSString *)generateBoundary;
- (void)appendBodyWithFormData:(NSDictionary *)formData;
- (void)appendBodyWithImageData:(NSDictionary *)imageData;

@end
