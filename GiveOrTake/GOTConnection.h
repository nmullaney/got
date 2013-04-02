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
}

enum {
    DATA = 0,
    JSON = 1
};
typedef NSUInteger GOTConnectionDataType;

- (id)initWithRequest:(NSMutableURLRequest *)req;

@property (nonatomic, copy) NSMutableURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);
@property (nonatomic) GOTConnectionDataType dataType;
@property (nonatomic, strong) id <JSONSerializable> jsonRootObject;
@property (nonatomic, readonly, strong) NSMutableData *dataObject;

- (void)start;

@end
