//
//  GOTItemList.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/25/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemList.h"

#import "GOTItem.h"

@implementation GOTItemList

@synthesize items;

- (id)init
{
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    NSArray *dits = [d objectForKey:@"items"];
    //NSLog(@"Items: %@", dits);
    NSLog(@"Item dict keys: %@", [d allKeys]);
    for (NSDictionary *dit in dits) {
        GOTItem *it = [[GOTItem alloc] init];
        [it readFromJSONDictionary:dit];
        [[self items] addObject:it];
    }
}

@end
