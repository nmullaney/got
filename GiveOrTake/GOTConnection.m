//
//  GOTConnection.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTConnection.h"

@implementation GOTConnection

@synthesize request, completionBlock, jsonRootObject, dataObject;

- (id)initWithRequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        [self setRequest:req];
        receivedData = NO;
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
        [self completionBlock](rootObject, nil);
    } else if ([self dataObject]) {
        [[self dataObject] appendData:data];
    }

    receivedData = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    connection = nil;
    jsonRootObject = nil;
    
    if ([self dataObject]) {
        [self completionBlock](dataObject, nil);
    }
    
    if (!receivedData) {
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"Server failed to respond"
                                                        forKey:NSLocalizedDescriptionKey];
        NSError *err = [NSError errorWithDomain:NSURLErrorDomain
                                                  code:NSURLErrorBadServerResponse
                                              userInfo:info];
        [self completionBlock](nil, err);
        receivedData = YES;
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{    
    connection = nil;
    [self completionBlock](nil, error);
}

@end
