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
    if (!data) {
        return;
    } else {
        NSLog(@"Received data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        receivedData = YES;
    }
    if ([self jsonRootObject]) {
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:nil];
        if ([d objectForKey:@"error"]) {
            NSLog(@"returning error");
            NSError *err = [self errorWithLocalizedDescription:[d objectForKey:@"error"]];
            [self completionBlock](nil, err);
            return;
        }
        NSLog(@"serializing to jsonRootObject");
        [[self jsonRootObject] readFromJSONDictionary:d];
        rootObject = [self jsonRootObject];
        [self completionBlock](rootObject, nil);
    } else if ([self dataObject]) {
        [[self dataObject] appendData:data];
    }
}

- (NSError *)errorWithLocalizedDescription:(NSString *)description
{
    NSDictionary *info = [NSDictionary dictionaryWithObject:description
                                                     forKey:NSLocalizedDescriptionKey];
    return[NSError errorWithDomain:NSURLErrorDomain
                              code:NSURLErrorBadServerResponse
                          userInfo:info];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    connection = nil;
    jsonRootObject = nil;
    NSLog(@"Finished loading");
    
    if (!receivedData) {
        NSError *err = [self errorWithLocalizedDescription:@"Server failed to respond."];
        [self completionBlock](nil, err);
        receivedData = YES;
    }

    
    if ([self dataObject]) {
        [self completionBlock](dataObject, nil);
    }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{    
    connection = nil;
    [self completionBlock](nil, error);
}

@end
