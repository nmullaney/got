//
//  GOTConnection.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTConnection.h"

@implementation GOTConnection

@synthesize request, completionBlock, jsonRootObject;

- (id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        [self setRequest:req];
    }
    return self;
}

- (void)start
{
    connection = [[NSURLConnection alloc]
                  initWithRequest:[self request]
                  delegate:self
                  startImmediately:YES];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    id rootObject = nil;
    if ([self jsonRootObject]) {
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:nil];
        [[self jsonRootObject] readFromJSONDictionary:d];
        rootObject = [self jsonRootObject];
    }
    [self completionBlock](rootObject, nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    connection = nil;
    jsonRootObject = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{    
    connection = nil;
    [self completionBlock](nil, error);
}

@end
