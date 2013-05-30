//
//  GOTItemState.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/27/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemState.h"

/**
 * This is basically an enum class.  I wanted more functionality than a typical enum
 * provides.
 */
@implementation GOTItemState

static NSString *DRAFT = @"Draft";
static NSString *AVAILABLE = @"Available";
static NSString *PENDING = @"Promised";
static NSString *TAKEN = @"Taken";
static NSString *DELETED = @"Deleted";

+ (GOTItemState *)DRAFT
{
    return (GOTItemState *)DRAFT;
}

+ (GOTItemState *)AVAILABLE
{
    return (GOTItemState *)AVAILABLE;
}

+ (GOTItemState *)PENDING
{
    return (GOTItemState *)PENDING;
}

+ (GOTItemState *)TAKEN
{
    return (GOTItemState *)TAKEN;
}

+ (GOTItemState *)DELETED
{
    return (GOTItemState *)DELETED;
}

+ (NSArray *)values
{
    return [NSArray arrayWithObjects:DRAFT, AVAILABLE, PENDING, TAKEN, DELETED, nil];
}

+ (NSArray *)pickableValues
{
    return [NSArray arrayWithObjects:AVAILABLE, PENDING, TAKEN, nil];
}

+ (NSUInteger)pickableCount
{
    return [[self pickableValues] count];
}

+ (NSUInteger)count
{
    return [[self values] count];
}

+ (GOTItemState *)getValue:(NSString *)str
{
    __block GOTItemState *match = nil;
    [[self values] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:str]) {
            match = (GOTItemState *)obj;
            *stop = YES;
        }
    }];
    if (!match) {
        [[NSException
          exceptionWithName:@"Invalid GOTItemState"
          reason:[NSString stringWithFormat:@"String '%@' does not match a valid GOTItemState.",str]
          userInfo:nil]
         raise];
    }
    return match;
}

+ (UIImage *)imageForState:(GOTItemState *)state
{
    if (state == [GOTItemState AVAILABLE]) {
       return [UIImage imageNamed:@"available"];
    } else if (state == [GOTItemState DRAFT]) {
       return [UIImage imageNamed:@"draft"];
    } else if (state == [GOTItemState PENDING]) {
        return [UIImage imageNamed:@"promised"];
    } else if (state == [GOTItemState TAKEN]) {
        return [UIImage imageNamed:@"taken"];
    } else {
        return nil;
    }
}

@end
