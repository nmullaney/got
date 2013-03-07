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
#import "GOTMutableURLPostRequest.h"
#import "GOTUserStore.h"

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

- (GOTItemList *)fetchMyItemsWithCompletion:(void (^)(GOTItemList *, NSError *))block
{
    NSString *urlStr = [NSString stringWithFormat:@"http://nmullaney.dev/api/items.php?userID=%@",
                        [[GOTUserStore sharedStore] activeUserID]];
    NSLog(@"getting my items from %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setCompletionBlock:block];
    GOTItemList *list = [[GOTItemList alloc] init];
    [conn setJsonRootObject:list];
    [conn start];
    return list;
}

- (void)fetchThumbnailAtURL:(NSURL *)url withCompletion:(void (^)(id, NSError *))block
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    NSMutableData *data = [[NSMutableData alloc] init];
    [conn setCompletionBlock:block];
    [conn setDataObject:data];
    [conn start];
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
    
    NSDictionary *imageData = nil;
    if ([item thumbnailData]) {
        imageData = [NSDictionary
                     dictionaryWithObjects:[NSArray arrayWithObjects:@"thumbnail",@"thumbnail.png",@"image/png",[item thumbnailData], nil]
                     forKeys:[NSArray arrayWithObjects:@"name",@"filename",@"contentType",@"data",nil]
                    ];
    }
    NSDictionary *formData = [item uploadDictionary];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url formData:formData imageData:imageData];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    GOTItemID *itemIDHolder = [[GOTItemID alloc] init];
    [conn setJsonRootObject:itemIDHolder];
    [conn setCompletionBlock:block];
    [conn start];
}

@end
