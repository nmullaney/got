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
        dataObject = [[NSMutableData alloc] init];
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
    if (!data) {
        return;
    } else {
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
    if ([[self dataObject] length] == 0) {
        NSError *err = [self errorWithLocalizedDescription:@"Server failed to respond."];
        [self completionBlock](nil, err);
        jsonRootObject = nil;
        dataObject = nil;
        return;
    }
    
    if ([self jsonRootObject]) {
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[self dataObject]
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
        [self completionBlock]([self jsonRootObject], nil);
        jsonRootObject = nil;
        dataObject = nil;
        return;
    }

    [self completionBlock](dataObject, nil);
    jsonRootObject = nil;
    dataObject = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{    
    connection = nil;
    [self completionBlock](nil, error);
}

@end
