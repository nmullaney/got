//
//  GOTMutableURLPostRequest.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/5/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTMutableURLPostRequest.h"

// Provides a general way to create POST requests with formData.
@implementation GOTMutableURLPostRequest

@synthesize boundary;

- (id)initWithURL:(NSURL *)URL formData:(NSDictionary *)formData imageData:(NSDictionary *)imageData
{
    self = [super initWithURL:URL];
    if (self) {
        [self setHTTPMethod:@"POST"];
        [self setBoundary:[self generateBoundary]];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundary];
        [self setValue:contentType forHTTPHeaderField:@"Content-type"];
        body = [[NSMutableData alloc] init];
        if (formData) {
            [self appendBodyWithFormData:formData];
        }
        if (imageData) {
            NSLog(@"appending body with image Data");
            [self appendBodyWithImageData:imageData];
        }
        [self setHTTPBody:body];
    }
    return self;
}

- (NSString *)generateBoundary {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    NSString *genBoundary = [NSString stringWithFormat:@"---Boundary-%@---", uuidStr];
    
    CFRelease(uuid);
    CFRelease(uuidStr);
    
    return genBoundary;
}

- (void)appendBodyWithFormData:(NSDictionary *)formData
{
    [formData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *data = [NSString stringWithFormat:@""
                          "--%@\r\n"
                          "Content-Disposition: form-data; name=\"%@\"\r\n"
                          "\r\n"
                          "%@"
                          "\r\n",
                          [self boundary],
                          key,
                          obj];
        [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }];
}

- (void)appendBodyWithImageData:(NSDictionary *)imageData
{
    NSString *fileData = [NSString stringWithFormat:@""
                          "--%@\r\n"
                          "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n"
                          "Content-Type: %@\r\n"
                          "\r\n",
                          boundary,
                          [imageData objectForKey:@"name"],
                          [imageData objectForKey:@"filename"],
                          [imageData objectForKey:@"contentType"]
                          ];
    [body appendData:[fileData dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[imageData objectForKey:@"data"]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
