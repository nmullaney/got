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
#import "GOTConnection.h"
#import "GOTMutableURLPostRequest.h"
#import "GOTUserStore.h"
#import "GOTActiveUser.h"
#import "GOTConstants.h"

@implementation GOTItemsStore

@synthesize items;

+ (GOTItemsStore *)sharedStore
{
    static GOTItemsStore *store = nil;
    if (!store) {
        store = [[GOTItemsStore alloc] init];
    }
    return store;
}

- (id)init
{
    self = [super init];
    if (self) {
        items = [[NSMutableDictionary alloc] init];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearItems)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

- (void)fetchItemsWithParams:(NSDictionary *)params
               forRootObject:(GOTItemList *)list
              withCompletion:(void (^)(GOTItemList *, NSError *))block {
    
    NSMutableString *urlStr = [NSMutableString stringWithString:@"/items.php?"];
    NSMutableArray *strParams = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
        [strParams addObject:param];
    }];
    [urlStr appendString:[strParams componentsJoinedByString:@"&"]];
    
    NSURL *url = [NSURL URLWithString:urlStr
                        relativeToURL:[GOTConstants baseURL]];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    [conn setCompletionBlock:block];
    [conn setJsonRootObject:list];
    [conn start];
}

- (void)fetchThumbnailAtURL:(NSURL *)url withCompletion:(void (^)(id, NSError *))block
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setCompletionBlock:block];
    [conn start];
}

- (void)uploadItem:(GOTItem *)item withCompletion:(void (^)(id, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"/item.php" relativeToURL:[GOTConstants baseURL]];
    
    NSDictionary *imageData = nil;
    if ([item thumbnailData]) {
        imageData = [NSDictionary
                     dictionaryWithObjects:[NSArray arrayWithObjects:@"thumbnail",@"thumbnail.png",@"image/png",[item thumbnailData], nil]
                     forKeys:[NSArray arrayWithObjects:@"name",@"filename",@"contentType",@"data",nil]
                    ];
    }
    NSDictionary *formData = [item uploadDictionary];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:formData
                                                                        imageData:imageData];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

- (void)sendWantItem:(GOTItem *)item withCompletion:(void (^)(id, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"/item/want.php" relativeToURL:[GOTConstants baseURL]];
    NSMutableDictionary *formData = [[NSMutableDictionary alloc] initWithCapacity:4];
    [formData setObject:[item itemID] forKey:@"item_id"];
    [formData setObject:[[GOTActiveUser activeUser] userID] forKey:@"user_id"];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url formData:formData imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

- (void)sendMessage:(NSString *)message
            forItem:(GOTItem *)item
     withCompletion:(void (^)(id, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"/item/message.php" relativeToURL:[GOTConstants baseURL]];
    NSMutableDictionary *formData = [[NSMutableDictionary alloc] initWithCapacity:5];
    [formData setObject:[item itemID] forKey:@"item_id"];
    [formData setObject:[[GOTActiveUser activeUser] userID] forKey:@"user_id"];
    [formData setObject:message forKey:@"message"];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url formData:formData imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

#pragma mark Item storage methods

- (void)addItem:(GOTItem *)item
{
    NSString *key = [self keyFromItemID:[item itemID]];
    [[self items] setValue:item forKey:key];
}

- (NSString *)keyFromItemID:(NSNumber *)itemID
{
    return [NSString stringWithFormat:@"%@", itemID];
}

- (GOTItem *)itemWithID:(NSNumber *)itemID
{
    NSString *key = [self keyFromItemID:itemID];
    return [[self items] objectForKey:key];
}

- (NSArray *)itemsWithIDs:(NSArray *)itemIDs
{
    NSMutableArray *itemsWithIDs = [[NSMutableArray alloc] initWithCapacity:[itemIDs count]];
    [itemIDs enumerateObjectsUsingBlock:^(NSNumber *itemID, NSUInteger idx, BOOL *stop) {
        [itemsWithIDs addObject:[self itemWithID:itemID]];
    }];
    return itemsWithIDs;
}

- (void)deleteItemWithID:(NSNumber *)itemID
{
    NSString *key = [self keyFromItemID:itemID];
    [[self items] removeObjectForKey:key];
}

- (void)deleteItem:(GOTItem *)item
{
    [self deleteItemWithID:[item itemID]];
}

- (void)clearItems
{
    [[self items] removeAllObjects];
}

@end
