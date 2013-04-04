//
//  GOTUser.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/4/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTUser.h"

#import "JSONUtil.h"

@implementation GOTUser

@dynamic userID;
@dynamic username;
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
        [keys addObject:@"user_id"];
    }
    if ([self username]) {
        [objs addObject:[self username]];
        [keys addObject:@"username"];
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
    if ([dict objectForKey:@"id"])
        [self setUserID:[JSONUtil normalizeJSONValue:[dict objectForKey:@"id"]
                                             toClass:[NSNumber class]]];
    if ([dict objectForKey:@"username"])
        [self setUsername:[JSONUtil normalizeJSONValue:[dict objectForKey:@"username"]
                                               toClass:[NSString class]]];
    if ([dict objectForKey:@"latitude"])
        [self setLatitude:[JSONUtil normalizeJSONValue:[dict objectForKey:@"latitude"]
                                               toClass:[NSNumber class]]];
    if ([dict objectForKey:@"longitude"])
        [self setLongitude:[JSONUtil normalizeJSONValue:[dict objectForKey:@"longitude"]
                                                toClass:[NSNumber class]]];
    if ([dict objectForKey:@"karma"])
        [self setKarma:[JSONUtil normalizeJSONValue:[dict objectForKey:@"karma"]
                                            toClass:[NSNumber class]]];
}

@end
