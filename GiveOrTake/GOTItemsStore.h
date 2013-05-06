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

- (void)fetchItemsWithParams:(NSDictionary *)params
              forRootObject:(GOTItemList *)list
              withCompletion:(void (^)(GOTItemList *list, NSError *err))block;
- (void)fetchItemsAtDistance:(int)distance
                   withLimit:(int)limit
                  withOffset:(int)offset
              withCompletion:(void (^)(GOTItemList *list, NSError *err))block;
- (void)fetchMyItemsWithCompletion:(void (^)(GOTItemList *list, NSError *err))block;

- (void)fetchThumbnailAtURL:(NSURL *)url
             withCompletion:(void (^)(id image, NSError *err))block;

- (void)uploadItem:(GOTItem *)i
    withCompletion:(void (^)(id itemID, NSError *err))block;

- (void)sendWantItem:(GOTItem *)item
     withCompletion:(void (^)(id result, NSError *err))block;
- (void)sendMessage:(NSString *)message
            forItem:(GOTItem *)item
     withCompletion:(void (^)(id result, NSError *err))block;

@end
