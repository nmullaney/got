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

@implementation GOTItemsStore

+ (GOTItemsStore *)sharedStore
{
    static GOTItemsStore *store = nil;
    if (!store) {
        store = [[GOTItemsStore alloc] init];
    }
    return store;
}

// TODO: distance should be a real distance, this
// should return real data
- (GOTItemList *)fetchItemsAtDistance:(int)distance
                   withCompletion:(void (^)(GOTItemList *, NSError *))block
{
    //return [GOTItem randomItems:distance];
    NSURL *url = [NSURL URLWithString:@"http://nmullaney.dev/api/items.php"];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    [conn setCompletionBlock:block];
    
    GOTItemList *list = [[GOTItemList alloc] init];
    [conn setJsonRootObject:list];
    [conn start];
    
    return list;
}

@end
