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

- (NSDictionary *)uploadDictionary
{
    NSMutableArray *objs = [[NSMutableArray alloc] init];
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    if ([self userID]) {
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
    if ([self latitude] != 0) {
        [objs addObject:[self latitude]];
        [keys addObject:@"latitude"];
    }
    if ([self longitude] != 0) {
        [objs addObject:[self longitude]];
        [keys addObject:@"longitude"];
    }
    return [NSDictionary dictionaryWithObjects:objs forKeys:keys];
}

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    int userID = [[d objectForKey:@"id"] intValue];
    [self setUserID:[NSNumber numberWithInt:userID]];
    [self setFacebookID:[d objectForKey:@"facebook_id"]];
    [self setUsername:[d objectForKey:@"username"]];
    [self setEmailAddress:[d objectForKey:@"email"]];
    
    id lat = [d objectForKey:@"latitude"];
    if (lat != (id)[NSNull null]) {
        float latitude = [[d objectForKey:@"latitude"] floatValue];
        [self setLatitude:[NSNumber numberWithFloat:latitude]];
    }
    id longt = [d objectForKey:@"longitude"];
    if (longt != (id)[NSNull null]) {
        float longitude = [[d objectForKey:@"longitude"] floatValue];
        [self setLongitude:[NSNumber numberWithFloat:longitude]];
    }
}

@end
