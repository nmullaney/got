//
//  GOTItemsStore.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GOTItemList;
@class GOTItem;

@interface GOTItemsStore : NSObject
{
    NSURLConnection *connection;
}
+ (GOTItemsStore *)sharedStore;

@property (nonatomic, strong) NSMutableDictionary *items;

- (void)fetchItemsWithParams:(NSDictionary *)params
              forRootObject:(GOTItemList *)list
              withCompletion:(void (^)(GOTItemList *list, NSError *err))block;

- (void)fetchThumbnailAtURL:(NSURL *)url
             withCompletion:(void (^)(id image, NSError *err))block;

- (void)uploadItem:(GOTItem *)i
    withCompletion:(void (^)(id itemID, NSError *err))block;

- (void)sendWantItem:(GOTItem *)item
     withCompletion:(void (^)(id result, NSError *err))block;
- (void)sendMessage:(NSString *)message
            forItem:(GOTItem *)item
     withCompletion:(void (^)(id result, NSError *err))block;

// items managment
- (void)addItem:(GOTItem *)item;
- (GOTItem *)itemWithID:(NSNumber *)itemID;
- (NSArray *)itemsWithIDs:(NSArray *)itemIDs;
- (void)deleteItemWithID:(NSNumber *)itemID;
- (void)deleteItem:(GOTItem *)item;
- (void)clearItems;

@end
