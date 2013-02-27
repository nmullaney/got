//
//  GOTItemsStore.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemsStore.h"

#import "GOTItem.h"
#import "GOTItemList.h"
#import "GOTItemID.h"
#import "GOTConnection.h"

@implementation GOTItemsStore

+ (GOTItemsStore *)sharedStore
{
    static GOTItemsStore *store = nil;
    if (!store) {
        store = [[GOTItemsStore alloc] init];
    }
    return store;
}

// TODO: distance should be a real distance
- (GOTItemList *)fetchItemsAtDistance:(int)distance
                   withCompletion:(void (^)(GOTItemList *, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"http://nmullaney.dev/api/items.php"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    [conn setCompletionBlock:block];
    
    GOTItemList *list = [[GOTItemList alloc] init];
    [conn setJsonRootObject:list];
    [conn start];
    
    return list;
}

- (NSString *)generateBoundary {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    NSString *boundary = [NSString stringWithFormat:@"---Boundary-%@---", uuidStr];
    
    CFRelease(uuid);
    CFRelease(uuidStr);
    
    return boundary;
}

- (void)uploadItem:(GOTItem *)item withCompletion:(void (^)(id, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"http://nmullaney.dev/api/item.php"];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
     NSString *boundary = [self generateBoundary];
    [req setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", boundary]
forHTTPHeaderField:@"Content-type"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSDictionary *values = [item uploadDictionary];
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *data = [NSString stringWithFormat:@""
                          "--%@\r\n"
                          "Content-Disposition: form-data; name=\"%@\"\r\n"
                          "\r\n"
                          "%@"
                          "\r\n",
                          boundary,
                          key,
                          obj];
        NSLog(@"data = %@", data);
        [body appendData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", boundary]
                      dataUsingEncoding:NSUTF8StringEncoding]];

    
    // TODO: investicate setHTTPBodyStream for image upload
    [req setHTTPBody:body];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    GOTItemID *itemIDHolder = [[GOTItemID alloc] init];
    [conn setJsonRootObject:itemIDHolder];
    [conn setCompletionBlock:block];
    [conn start];
}

@end
