//
//  GOTItem.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItem.h"

@implementation GOTItem

@synthesize name, desc, image;

- (id)initWithName:(NSString *)itemName
       description:(NSString *)itemDescription
{
    self = [super init];
    if (self) {
        [self setName:itemName];
        [self setDesc:itemDescription];
        [self setDatePosted:[NSDate date]];
    }
    return self;
}

// This is just for generating test data
+ (NSArray *)randomItems:(int) count;
{
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        GOTItem *item = [GOTItem createRandomItem];
        [items addObject:item];
    }
    return items;
}

+(id)createRandomItem
{
    NSArray *nouns = [[NSArray alloc] initWithObjects:@"Lamp", @"Table", @"Hat", @"Plant", nil];
    NSArray *adjs = [[NSArray alloc] initWithObjects:@"Fuzzy", @"Blue", @"Broken", @"Silly", @"Fluffy", nil];
    int nounIdx = rand() % [nouns count];
    int adjIdx = rand() % [adjs count];
    
    NSString *noun = [nouns objectAtIndex:nounIdx];
    NSString *adj = [adjs objectAtIndex:adjIdx];
    
    NSString *randomName = [[NSString alloc] initWithFormat:@"%@ %@", adj, noun];
    
    NSString *randomDesc = [[NSString alloc] initWithFormat:@"This %@ is %@", noun, adj];
    
    return [[GOTItem alloc] initWithName:randomName
                             description:randomDesc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name:%@, Desc:%@", [self name], [self desc]];
}

@end
