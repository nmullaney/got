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

+ (GOTItemsStore *)sharedStore
{
    static GOTItemsStore *store = nil;
    if (!store) {
        store = [[GOTItemsStore alloc] init];
    }
    return store;
}

- (void)fetchItemsWithParams:(NSDictionary *)params
               forRootObject:(GOTItemList *)list
              withCompletion:(void (^)(GOTItemList *, NSError *))block {
    
    NSMutableString *urlStr = [NSMutableString stringWithString:@"/api/items.php?"];
    NSMutableArray *strParams = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, obj];
        [strParams addObject:param];
    }];
    [urlStr appendString:[strParams componentsJoinedByString:@"&"]];
    NSLog(@"Loading items from: %@", urlStr);
    
    NSURL *url = [NSURL URLWithString:urlStr
                        relativeToURL:[GOTConstants baseURL]];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    [conn setCompletionBlock:block];
    [conn setJsonRootObject:list];
    [conn start];
}

- (void)fetchItemsAtDistance:(int)distance
                   withLimit:(int)limit
                  withOffset:(int)offset
              withCompletion:(void (^)(GOTItemList *, NSError *))block
{
    NSString *urlStr = [NSString stringWithFormat:@"/api/items.php?distance=%d&userID=%@&limit=%d&offset=%d",
                        distance,
                        [[GOTActiveUser activeUser] userID],
                        limit,
                        offset];
    NSURL *url = [NSURL URLWithString:urlStr
                        relativeToURL:[GOTConstants baseURL]];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    [conn setCompletionBlock:block];
    
    GOTItemList *list = [[GOTItemList alloc] init];
    [conn setJsonRootObject:list];
    [conn start];
}

- (void)fetchMyItemsWithCompletion:(void (^)(GOTItemList *, NSError *))block
{
    NSLog(@"active user ID: %@", [[GOTActiveUser activeUser] userID]);
    NSLog(@"active user token: %@", [[GOTActiveUser activeUser] token]);
    NSString *urlStr = [NSString stringWithFormat:@"/api/items.php?ownedBy=%@",
                        [[GOTActiveUser activeUser] userID]];
    NSLog(@"getting my items from %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr
                        relativeToURL:[GOTConstants baseURL]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setCompletionBlock:block];
    GOTItemList *list = [[GOTItemList alloc] init];
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
    NSURL *url = [NSURL URLWithString:@"/api/item.php" relativeToURL:[GOTConstants baseURL]];
    
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

- (void)sendMessage:(NSString *)message
            forItem:(GOTItem *)item
     withCompletion:(void (^)(id, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"/api/item/message.php" relativeToURL:[GOTConstants baseURL]];
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

@end
