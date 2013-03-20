//
//  GOTItemList.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemList.h"

#import "GOTItem.h"
#import "GOTItemsStore.h"
#import "GOTUserStore.h"
#import "GOTConstants.h"

@implementation GOTItemList

@synthesize items, distance, ownedByID;

- (id)init
{
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
        self->isAllDataLoaded = NO;
    }
    return self;
}

#pragma mark setters

- (void)setOwnedByID:(NSNumber *)userID
{
    if (!ownedByID ||
        !userID ||
        [userID integerValue] != [ownedByID integerValue]) {
        // If we changed the owned user, we should
        // remove any existing items, since they
        // would be filtered out
        items = [[NSMutableArray alloc] init];
    }
    self->isAllDataLoaded = NO;
    ownedByID = userID;
}

- (void)setDistance:(NSNumber *)newDistance
{
    if (!distance ||
        !newDistance ||
        [newDistance intValue] < [distance intValue]) {
        // filter out any existing items that no longer fit the criteria
        NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc] init];
        [[self items] enumerateObjectsUsingBlock:^(GOTItem *item, NSUInteger idx, BOOL *stop) {
            if ([[item distance] intValue] < [newDistance intValue]) {
                [indicesToRemove addIndex:idx];
            }
        }];
        [[self items] removeObjectsAtIndexes:indicesToRemove];
    }
    self->isAllDataLoaded = NO;
    distance = newDistance;
}

#pragma mark -
#pragma mark add new items from JSON

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    NSArray *dits = [d objectForKey:@"items"];
    NSMutableArray *newItems = [[NSMutableArray alloc] init];
    for (NSDictionary *dit in dits) {
        GOTItem *it = [[GOTItem alloc] init];
        [it readFromJSONDictionary:dit];
        [newItems addObject:it];
    }
    if ([newItems count] < [GOTConstants itemRequestLimit]) {
        self->isAllDataLoaded = YES;
    }
    NSLog(@"Got new items: %@", newItems);
    [self mergeNewItems:newItems];
}

- (void)mergeNewItems:(NSMutableArray *)newItems
{
    NSMutableDictionary *itemsByID = [[NSMutableDictionary alloc] init];
    // Add all original items to the dictionary
    [[self items] enumerateObjectsUsingBlock:^(GOTItem *item,
                                               NSUInteger idx,
                                               BOOL *stop) {
        [itemsByID setObject:item forKey:[item itemID]];
        
    }];
    [newItems enumerateObjectsUsingBlock:^(GOTItem *newItem, NSUInteger idx, BOOL *stop) {
        GOTItem *oldItem = [itemsByID objectForKey:[newItem itemID]];
        if (!oldItem || ([[newItem dateUpdated] timeIntervalSinceDate:[oldItem dateUpdated]] > 0)) {
            NSLog(@"Adding in new item for: %@", [newItem name]);
            NSLog(@"New date = %@", [newItem dateUpdated]);
            if (oldItem) {
                NSLog(@"Old date = %@", [oldItem dateUpdated]);
            }
            [itemsByID setObject:newItem forKey:[newItem itemID]];
        }
    }];
    // Sort all the items by date updated
    NSMutableArray *allItems = [NSMutableArray arrayWithArray:[itemsByID allValues]];
    allItems = (NSMutableArray *)[allItems sortedArrayUsingComparator:^NSComparisonResult(GOTItem *item1, GOTItem *item2) {
        return [[item2 dateUpdated] compare:[item1 dateUpdated]];
    }];
    [self setItems:allItems];
}

#pragma mark load items

- (NSMutableDictionary *)getLoadParams
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[[GOTUserStore sharedStore] activeUserID] forKey:@"userID"];
    [params setObject:[NSNumber numberWithInteger:[GOTConstants itemRequestLimit]] forKey:@"limit"];
    if ([self distance]) {
        [params setObject:[self distance] forKey:@"distance"];
    }
    if ([self ownedByID]) {
        [params setObject:[self ownedByID] forKey:@"ownedByID"];
    }
    return params;
}

- (void)loadMostRecentItemsWithCompletion:(void (^)(id list, NSError *))block
{
    NSLog(@"Loading most recent items");
    NSMutableDictionary *params = [self getLoadParams];
    [params setObject:[NSNumber numberWithInteger:0]
               forKey:@"offset"];
    [[GOTItemsStore sharedStore] fetchItemsWithParams:params
                                        forRootObject:self
                                       withCompletion:block];
    
}

- (void)loadMoreItemsWithCompletion:(void (^)(id list, NSError *))block
{
    NSLog(@"Loading more items");
    if (self->isAllDataLoaded) {
        NSLog(@"All data loaded");
        if (block) {
            block(self, nil);
        }
        return;
    }
    NSMutableDictionary *params = [self getLoadParams];
    [params setObject:[NSNumber numberWithInteger:[[self items] count]]
               forKey:@"offset"];
    [[GOTItemsStore sharedStore] fetchItemsWithParams:params
                                        forRootObject:self
                                       withCompletion:block];
}

#pragma mark -
#pragma mark GetItem

- (GOTItem *)getItemAtIndex:(NSUInteger)idx
{
    if (idx > [self itemCount] - 1) {
        [NSException exceptionWithName:@"Index Error" reason:@"Index requested is beyond item list size." userInfo:nil];
    }
    return [[self items] objectAtIndex:idx];
}

- (void)fetchItemAtIndex:(NSUInteger)idx
             withCompletion:(void (^)(id item, NSError *))block
{
    NSLog(@"Fetching item at index: %d", idx);
    if (idx < [[self items] count]) {
        GOTItem *item = [[self items] objectAtIndex:idx];
        block(item, nil);
        return;
    } else if (self->isAllDataLoaded) {
        // No item for that index
        block(nil, nil);
        return;
    }
    
    void (^handler)(id list, NSError *err) = ^(id list, NSError *err){
        if (err) {
            block(nil, err);
            return;
        }
        GOTItemList *myList = (GOTItemList *)list;
        if ([[myList items] count] < idx) {
            block(nil, nil);
            return;
        }
        GOTItem *item = [[myList items] objectAtIndex:idx];
        block(item, nil);
    };
    [self loadMoreItemsWithCompletion:handler];
}

// Returns the count of the currently loaded items
- (NSUInteger)itemCount
{
    return [[self items] count];
}

@end
