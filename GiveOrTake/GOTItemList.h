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

- (void)mergeNewItems:(NSMutableArray *)newItems;
- (void)loadMostRecentItemsWithCompletion:(void (^)(id items, NSError *err))block;
- (void)loadMoreItemsWithCompletion:(void (^)(id items, NSError *err))block;
- (GOTItem *)getItemAtIndex:(NSUInteger)idx;
- (void)fetchItemAtIndex:(NSUInteger)idx
             withCompletion:(void (^)(id item, NSError *err))block;
- (NSUInteger)itemCount;

@end
