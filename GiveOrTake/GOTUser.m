//
//  GOTUser.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/4/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTUser.h"

@implementation GOTUser

@dynamic userID;
@dynamic facebookID;
@dynamic username;
@dynamic emailAddress;
@dynamic latitude;
@dynamic longitude;
@dynamic karma;

- (NSDictionary *)uploadDictionary
{
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    if ([self userID] && [[self userID] intValue] != 0) {
        NSLog(@"Setting userID to %@", [self userID]);
        [objs addObject:[self userID]];
        [keys addObject:@"id"];
    }
    if ([self facebookID]) {
        [objs addObject:[self facebookID]];
        [keys addObject:@"facebook_id"];
    }
    if ([self username]) {
        [objs addObject:[self username]];
        [keys addObject:@"username"];
    }
    if ([self emailAddress]) {
        [objs addObject:[self emailAddress]];
        [keys addObject:@"email"];
    }
    // TODO: figure out a better way to determine these are unset
    if ([self latitude] && [[self latitude] intValue] != 0) {
        NSLog(@"Setting latitude to %@", [self latitude]);
        [objs addObject:[self latitude]];
        [keys addObject:@"latitude"];
    }
    if ([self longitude] && [[self longitude] intValue] != 0) {
        [objs addObject:[self longitude]];
        [keys addObject:@"longitude"];
    }
    return [NSDictionary dictionaryWithObjects:objs forKeys:keys];
}

- (void)readFromJSONDictionary:(NSDictionary *)dict
{
    // Objects that are "null" in JSON, will be [NSNull null], instead of
    // nil.  We'll strip thes all out before we parse, so we don't have
    // to check each time
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:dict];
    NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == (id)[NSNull null]) {
            [keysToRemove addObject:key];
        }
    }];
    [d removeObjectsForKeys:keysToRemove];
    
    int userID = [[d objectForKey:@"id"] intValue];
    [self setUserID:[NSNumber numberWithInt:userID]];
    [self setFacebookID:[d objectForKey:@"facebook_id"]];
    [self setUsername:[d objectForKey:@"username"]];
    [self setEmailAddress:[d objectForKey:@"email"]];

    float latitude = [[d objectForKey:@"latitude"] floatValue];
    [self setLatitude:[NSNumber numberWithFloat:latitude]];
    
    float longitude = [[d objectForKey:@"longitude"] floatValue];
    [self setLongitude:[NSNumber numberWithFloat:longitude]];
    
    int karma = [[d objectForKey:@"karma"] intValue];
    [self setKarma:[NSNumber numberWithInt:karma]];
}

@end
