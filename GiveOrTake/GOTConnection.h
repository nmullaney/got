//
//  GOTConnection.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerializable.h"

@interface GOTConnection : NSObject
    <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *connection;
    BOOL receivedData;
}

- (id)initWithRequest:(NSURLRequest *)req;

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);
@property (nonatomic, strong) id <JSONSerializable> jsonRootObject;
@property (nonatomic, strong) NSMutableData *dataObject;

- (void)start;

@end
