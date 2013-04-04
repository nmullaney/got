//
//  GOTActiveUser.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/2/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTActiveUser.h"

#import "GOTUser.h"
#import "GOTUserStore.h"
#import "JSONUtil.h"

@implementation GOTActiveUser

@synthesize user, facebookID, token, email, pendingEmail;

static GOTActiveUser *activeUser = nil;

+ (GOTActiveUser *)activeUser
{
    if (!activeUser) {
        // Try to load activeUser data from file archive
        NSString *path = [GOTActiveUser archivePath];
        activeUser = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!activeUser) {
            activeUser = [[GOTActiveUser alloc] init];
            GOTUser *user = [[GOTUserStore sharedStore] createNewUser];
            [activeUser setUser:user];
        }
    }
    return activeUser;
}

+ (void)logout
{
    activeUser = nil;
    // Make sure the archived version of the user is also deleted
    [[NSFileManager defaultManager] removeItemAtPath:[GOTActiveUser archivePath] error:nil];
}

+ (BOOL)isActiveUser:(GOTUser *)user
{
    NSInteger userID = [[user userID] integerValue];
    if ([[activeUser userID] integerValue] == userID) {
        return TRUE;
    } else {
        return FALSE;
    }
}


- (void)readFromJSONDictionary:(NSDictionary *)d
{
    if ([d objectForKey:@"token"]) {
        [self setToken:[JSONUtil normalizeJSONValue:[d objectForKey:@"token"]
                                            toClass:[NSString class]]];
    }
    
    if ([d objectForKey:@"email"]) {
        [self setEmail:[JSONUtil normalizeJSONValue:[d objectForKey:@"email"] toClass:[NSString class]]];
    }
    if ([d objectForKey:@"pending_email"]) {
        [self setPendingEmail:[JSONUtil normalizeJSONValue:[d objectForKey:@"pending_email"] toClass:[NSString class]]];
    }
    
    [[self user] readFromJSONDictionary:d];
}

#pragma mark archiving methods

+ (NSString *)archivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    // There is only one document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"activeUser.archive"];
}

+ (BOOL)save
{
    NSString *path = [GOTActiveUser archivePath];
    return [NSKeyedArchiver archiveRootObject:[GOTActiveUser activeUser] toFile:path];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self userID] forKey:@"userID"];
    [aCoder encodeObject:facebookID forKey:@"facebookID"];
    [aCoder encodeObject:token forKey:@"token"];
    [aCoder encodeObject:email forKey:@"email"];
    [aCoder encodeObject:pendingEmail forKey:@"pendingEmail"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // activeUser needs to be initialized before this is called
    NSNumber *userID = [aDecoder decodeObjectForKey:@"userID"];
    if (userID) {
        NSPredicate *userPredicate = [NSPredicate
                                  predicateWithFormat:@"userID = %@"
                                  argumentArray:[NSArray arrayWithObject:userID]];
        GOTUser *dbUser = [[GOTUserStore sharedStore] fetchUserFromDBWithPredicate:userPredicate];
        if (dbUser) {
            [self setUser:dbUser];
        } else {
            [self setUser:[[GOTUserStore sharedStore] createNewUser]];
        }
    }
    
    [self setFacebookID:[aDecoder decodeObjectForKey:@"facebookID"]];
    [self setToken:[aDecoder decodeObjectForKey:@"token"]];
    [self setEmail:[aDecoder decodeObjectForKey:@"email"]];
    [self setPendingEmail:[aDecoder decodeObjectForKey:@"pendingEmail"]];
    return self;
}

#pragma mark -
#pragma mark GOTUser wrapped methods

- (NSNumber *)userID
{
    return [[self user] userID];
}

- (void)setUserID:(NSNumber *)userID
{
    [[self user] setUserID:userID];
}

- (NSString *)username
{
    return [[self user] username];
}

- (void)setUsername:(NSString *)username
{
    [[self user] setUsername:username];
}

- (NSNumber *)latitude
{
    return [[self user] latitude];
}

- (void)setLatitude:(NSNumber *)latitude
{
    [[self user] setLatitude:latitude];
}

- (NSNumber *)longitude
{
    return [[self user] longitude];
}

- (void)setLongitude:(NSNumber *)longitude
{
    [[self user] setLongitude:longitude];
}

- (NSNumber *)karma
{
    return [[self user] karma];
}

- (void)setKarma:(NSNumber *)karma
{
    [[self user] setKarma:karma];
}

#pragma mark -

@end
