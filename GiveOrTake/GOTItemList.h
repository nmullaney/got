//
//  GOTItemList.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerializable.h"

@class GOTItem;

@interface GOTItemList : NSObject <JSONSerializable>
{
    BOOL isAllDataLoaded;
}

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) NSNumber *distance;
@property (nonatomic) NSString *searchText;
@property (nonatomic) NSNumber *ownedByID;
@property (nonatomic) BOOL showMyItems;

- (void)mergeNewItems:(NSMutableArray *)newItems;
- (void)loadMostRecentItemsWithCompletion:(void (^)(id items, NSError *err))block;
- (void)loadMoreItemsWithCompletion:(void (^)(id items, NSError *err))block;
- (void)loadSingleItem:(NSNumber *)singleItemID;

- (void)fetchItemAtIndex:(NSUInteger)idx
             withCompletion:(void (^)(id item, NSError *err))block;

- (GOTItem *)getItemAtIndex:(NSUInteger)idx;
- (NSUInteger)itemCount;
- (void)removeItemAtIndex:(NSUInteger)idx;
- (void)insertItem:(GOTItem *)item atIndex:(NSUInteger)idx;
- (void)refreshItems;

@end
