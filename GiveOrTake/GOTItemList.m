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
#import "GOTActiveUser.h"
#import "GOTConstants.h"

@implementation GOTItemList

@synthesize itemIDs, distance, searchText, ownedByID, showMyItems;

- (id)init
{
    self = [super init];
    if (self) {
        itemIDs = [[NSMutableArray alloc] init];
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
        itemIDs = [[NSMutableArray alloc] init];
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
        NSArray *items = [[GOTItemsStore sharedStore] itemsWithIDs:[self itemIDs]];
        [items enumerateObjectsUsingBlock:^(GOTItem *item, NSUInteger idx, BOOL *stop) {
            NSLog(@"Checking item");
            if ([[item distance] intValue] > [newDistance intValue]) {
                [indicesToRemove addIndex:idx];
            }
        }];
        [[self itemIDs] removeObjectsAtIndexes:indicesToRemove];
        // Explicitly setting the items ensures that the observers reload data
        [self setItemIDs:[self itemIDs]];
    }
    self->isAllDataLoaded = NO;
    distance = newDistance;
}

- (void)setSearchText:(NSString *)newSearchText
{
    if (![newSearchText isEqualToString:searchText]) {
        NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc] init];
        NSLog(@"Checking item matches %@", newSearchText);
        NSArray *items = [[GOTItemsStore sharedStore] itemsWithIDs:[self itemIDs]];
        [items enumerateObjectsUsingBlock:^(GOTItem *item, NSUInteger idx, BOOL *stop) {
            if (![item matchesText:newSearchText]) {
                [indicesToRemove addIndex:idx];
            }
        }];
        [[self itemIDs] removeObjectsAtIndexes:indicesToRemove];
        // Explicitly setting the items ensures that the observers reload data
        [self setItemIDs:[self itemIDs]];
    }
    self->isAllDataLoaded = NO;
    searchText = newSearchText;
}

- (void)setShowMyItems:(BOOL)smi
{
    // We only need to filter in the case where we had user-owned items and will no longer show them
    if (showMyItems == YES && smi == NO) {
        NSLog(@"Attempting to filter out my items");
        NSMutableIndexSet *indicesToRemove = [[NSMutableIndexSet alloc] init];
        NSNumber *activeUserID = [[GOTActiveUser activeUser] userID];
        NSArray *items = [[GOTItemsStore sharedStore] itemsWithIDs:[self itemIDs]];
        [items enumerateObjectsUsingBlock:^(GOTItem *item, NSUInteger idx, BOOL *stop) {
            if ([[item userID] integerValue]  == [activeUserID integerValue]) {
                [indicesToRemove addIndex:idx];
            }
        }];
        NSLog(@"Indicies to remove: %@", indicesToRemove);
        [[self itemIDs] removeObjectsAtIndexes:indicesToRemove];
        [self setItemIDs:[self itemIDs]];
    }
    self->isAllDataLoaded = NO;
    showMyItems = smi;
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
    if ([newItems count] == 0) {
        return;
    }
    // Use a set to ensure we have one copy of each itemID
    NSMutableSet *allItemIDs = [NSMutableSet setWithArray:[self itemIDs]];
    [newItems enumerateObjectsUsingBlock:^(GOTItem *newItem, NSUInteger idx, BOOL *stop) {
        NSLog(@"New item = %@", newItem);
        GOTItem *oldItem = [[GOTItemsStore sharedStore] itemWithID:[newItem itemID]];
        if (!oldItem || ([[newItem dateUpdated] timeIntervalSinceDate:[oldItem dateUpdated]] > 0)) {
            [[GOTItemsStore sharedStore] addItem:newItem];
        }
        [allItemIDs addObject:[newItem itemID]];
    }];
    // Sort all the items by date updated, then the name
    NSMutableArray *sortedItemIDs = [NSMutableArray arrayWithArray:
                                  [[allItemIDs allObjects]
                                   sortedArrayUsingComparator:^NSComparisonResult(NSNumber *itemID1, NSNumber *itemID2) {
                                       GOTItem *item1 = [[GOTItemsStore sharedStore] itemWithID:itemID1];
                                       GOTItem *item2 = [[GOTItemsStore sharedStore] itemWithID:itemID2];
                                       NSComparisonResult dateOrder = [[item2 dateUpdated] compare:[item1 dateUpdated]];
                                       if (dateOrder == NSOrderedSame) {
                                           return [[item2 name] compare:[item1 name]];
                                       }
                                       return dateOrder;
                                   }]];
    [self setItemIDs:sortedItemIDs];
}

#pragma mark load items

- (NSMutableDictionary *)getLoadParams
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:4];
    [params setObject:[[GOTActiveUser activeUser] userID] forKey:@"userID"];
    [params setObject:[NSNumber numberWithInteger:[GOTConstants itemRequestLimit]] forKey:@"limit"];
    if ([self distance]) {
        [params setObject:[self distance] forKey:@"distance"];
    }
    if ([self searchText]) {
        [params setObject:[self searchText] forKey:@"q"];
    }
    if ([self ownedByID]) {
        [params setObject:[self ownedByID] forKey:@"ownedBy"];
    }
    [params setObject:[NSNumber numberWithBool:[self showMyItems]] forKey:@"showMyItems"];
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
    [params setObject:[NSNumber numberWithInteger:[self itemCount]]
               forKey:@"offset"];
    [[GOTItemsStore sharedStore] fetchItemsWithParams:params
                                        forRootObject:self
                                       withCompletion:block];
}

- (void)loadSingleItem:(NSNumber *)singleItemID
{
    NSDictionary *params = [NSDictionary dictionaryWithObject:singleItemID forKey:@"itemID"];
    [[GOTItemsStore sharedStore] fetchItemsWithParams:params forRootObject:self withCompletion:^(GOTItemList *list, NSError *err) {
        if (err) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Failed to load item" message:[err localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        } else {
            self->isAllDataLoaded = YES;
        }
    }];
}

#pragma mark -
#pragma mark GetItem

- (GOTItem *)getItemAtIndex:(NSUInteger)idx
{
    int count = [self itemCount];
    if (count == 0 || idx > (count - 1)) {
        [[NSException exceptionWithName:@"Index Error" reason:@"Index requested is beyond item list size." userInfo:nil] raise];
    }
    NSNumber *itemID = [[self itemIDs] objectAtIndex:idx];
    return [[GOTItemsStore sharedStore] itemWithID:itemID];
}

- (void)fetchItemAtIndex:(NSUInteger)idx
             withCompletion:(void (^)(id item, NSError *))block
{
    NSLog(@"Fetching item at index: %d", idx);
    if (idx < [self itemCount]) {
        GOTItem *item = [self getItemAtIndex:idx];
        if (block) {
            block(item, nil);
        }
        return;
    } else if (self->isAllDataLoaded) {
        // No item for that index
        if (block) {
            block(nil, nil);
        }
        return;
    }
    
    void (^handler)(id list, NSError *err) = ^(id list, NSError *err){
        if (err) {
            if (block) {
                block(nil, err);
            }
            return;
        }
        GOTItemList *myList = (GOTItemList *)list;
        if ([[myList itemIDs] count] <= idx) {
            if (block) {
                block(nil, nil);
            }
            return;
        }
        NSLog(@"Getting item from mylist");
        GOTItem *item = [myList getItemAtIndex:idx];
        if (block) {
            block(item, nil);
        }
    };
    [self loadMoreItemsWithCompletion:handler];
}

// Returns the count of the currently loaded items
- (NSUInteger)itemCount
{
    return [[self itemIDs] count];
}

- (void)removeItemAtIndex:(NSUInteger)idx
{
    int count = [self itemCount];
    if (count == 0 || idx > (count - 1)) {
        [[NSException exceptionWithName:@"Index Error" reason:@"Index requested is beyond item list size." userInfo:nil] raise];
    }
    GOTItem *deleteItem = [self getItemAtIndex:idx];
     [[self itemIDs] removeObjectAtIndex:idx];
    [[GOTItemsStore sharedStore] deleteItem:deleteItem];
    // Trigger update
    [self setItemIDs:[self itemIDs]];
}

- (void)insertItem:(GOTItem *)item atIndex:(NSUInteger)idx
{
    [[GOTItemsStore sharedStore] addItem:item];
    // TODO, what if no ID yet?
    [[self itemIDs] insertObject:[item itemID] atIndex:idx];
}

- (void)refilterItems
{
    // Filter for items that may have changed in Offers and should no longer show up in FreeItems
    NSMutableArray *filteredItemIDs = [[NSMutableArray alloc] init];
    [[self itemIDs] enumerateObjectsUsingBlock:^(NSNumber *itemID, NSUInteger idx, BOOL *stop) {
        GOTItem *item = [[GOTItemsStore sharedStore] itemWithID:itemID];
        if (!item ||
            ![item matchesText:[self searchText]]) {
            return;
        }
        [filteredItemIDs addObject:itemID];
    }];
    [self setItemIDs:filteredItemIDs];
}

- (void)refreshItems
{
    // Ensure a refresh of the controllers
    [self setItemIDs:[self itemIDs]];
}

@end
