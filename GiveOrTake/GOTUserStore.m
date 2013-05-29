//
//  GOTUserStore.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/4/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTUserStore.h"

#import <FacebookSDK/FacebookSDK.h>

#import "GOTUser.h"
#import "GOTActiveUser.h"
#import "GOTMutableURLPostRequest.h"
#import "GOTConnection.h"
#import "GOTSettings.h"
#import "GOTConstants.h"
#import "JSONUtil.h"

#import "User.h"

@implementation GOTUserStore

+ (GOTUserStore *)sharedStore
{
    static GOTUserStore *store = nil;
    if (!store) {
        store = [[GOTUserStore alloc] init];
    }
    return store;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize the model, context, etc.
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSURL *storeURL = [NSURL fileURLWithPath:[self sqlStorePath]];
        
        NSError *err = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&err]) {
            NSLog(@"Open database failed");
            [NSException raise:@"Open database failed"
                        format:@"Reason: %@", err];
        } else {
            NSLog(@"Open database succeeded");
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        
        [context setUndoManager:nil];
        
    }
    return self;
}

- (NSString *)sqlStorePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    // There is only one document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"GOTData.sql3"];
    return path;
}

- (void)updateUserWithParams:(NSDictionary *)params
    withCompletion:(void (^)(id, NSError *))block
{
    NSLog(@"Updating user with values: %@", params);
    
    NSURL *url = [NSURL URLWithString:@"/user.php" relativeToURL:[GOTConstants baseURL]];
    NSLog(@"Updating user at: %@", url);
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:params
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:^(NSDictionary *updatedUserDict, NSError *error) {
        GOTActiveUser *updatedUser = nil;
        if (error) {
            NSLog(@"Error updating user: %@", [error localizedDescription]);
        } else {
            updatedUser = [GOTActiveUser activeUserFromDictionary:updatedUserDict];
            NSLog(@"saving block user: %@", updatedUser);
            [self saveChanges];
        }
        if (block) {
            block(updatedUser, error);
        }
    }];
    [conn start];
}

- (void)addPendingEmail:(NSString *)email withCompletion:(void (^)(id, NSError *))block
{
    GOTActiveUser *user = [GOTActiveUser activeUser];
    NSArray *keys = [NSArray arrayWithObjects:@"user_id", @"email", nil];
    NSArray *values = [NSArray arrayWithObjects:[user userID], email, nil];
    NSMutableDictionary *formData = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    NSURL *url = [NSURL URLWithString:@"/user/email.php" relativeToURL:[GOTConstants baseURL]];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:formData
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

- (void)removePendingEmailWithCompletion:(void (^)(id, NSError *))block
{
    GOTActiveUser *user = [GOTActiveUser activeUser];
    NSArray *keys = [NSArray arrayWithObjects:@"user_id", @"cancel_pending", nil];
    NSNumber *cancel = [NSNumber numberWithBool:YES];
    NSArray *values = [NSArray arrayWithObjects:[user userID], cancel, nil];
    NSMutableDictionary *formData = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    NSURL *url = [NSURL URLWithString:@"/user/email.php" relativeToURL:[GOTConstants baseURL]];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:formData
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

- (void)verifyPendingEmailCode:(NSString *)code withCompletion:(void (^)(id, NSError *))block
{
    GOTActiveUser *user = [GOTActiveUser activeUser];
    NSArray *keys = [NSArray arrayWithObjects:@"user_id", @"code", nil];
    NSArray *values = [NSArray arrayWithObjects:[user userID], code, nil];
    NSMutableDictionary *formData = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    NSURL *url = [NSURL URLWithString:@"/user/email.php" relativeToURL:[GOTConstants baseURL]];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:formData
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

#pragma mark public user fetch functions

- (void)fetchActiveUserWithExtraFields:(NSArray *)extraFields
                        withCompletion:(void (^)(GOTActiveUser *, NSError *))block
{
    NSNumber *activeUserID = [[GOTActiveUser activeUser] userID];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:activeUserID forKey:@"user_id"];
    if (extraFields) {
        [params setObject:extraFields forKey:@"extra"];
    }
    [self fetchUserFromWebWithParams:params withRootObject:[GOTActiveUser activeUser] withCompletion:block];
}

- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID withCompletion:(void (^)(id, NSError *))block
{
    if (!userID) {
        [[NSException exceptionWithName:@"Cannot fetch user"
                                 reason:@"No userID specified"
                               userInfo:nil] raise];
    }
    
    GOTUser *user = [self fetchLocalUserWithUserID:userID];
    if (user) {
        NSLog(@"Fetched user from local storage");
        if (block) {
            block(user, nil);
        }
        return user;
    }
    
    NSLog(@"Fetching user from the web");
    NSDictionary *params = [NSDictionary dictionaryWithObject:userID forKey:@"user_id"];
    NSLog(@"Creating a new user for %@ because could not find in local storage", userID);
    GOTUser *newUser = [self createNewUser];
    [self fetchUserFromWebWithParams:params withRootObject:newUser withCompletion:block];
    
    return nil;
}

- (GOTUser *)fetchLocalUserWithUserID:(NSNumber *)userID
{
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userID = %@"
                                                    argumentArray:[NSArray arrayWithObject:userID]];
    return [self fetchUserFromDBWithPredicate:userPredicate];
}

- (void)fetchUserFromWebWithParams:(NSDictionary *)params
                    withRootObject:(id<User>)rootObject
                    withCompletion:(void (^)(id user, NSError *err))block
{
    NSMutableString *stringURL = [NSMutableString stringWithString:@"/user.php?"];
    NSMutableArray *paramStrs = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^void(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)obj;
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [paramStrs addObject:[NSString stringWithFormat:@"%@[%d]=%@", key, idx, obj]];
            }];
        } else {
            [paramStrs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    [stringURL appendString:[paramStrs componentsJoinedByString:@"&"]];
    NSLog(@"Fetching user from %@", stringURL);
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringURL
                                                                   relativeToURL:[GOTConstants baseURL]]];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    [conn setJsonRootObject:rootObject];
    [conn setCompletionBlock:^(id<User> user, NSError *err) {
        NSLog(@"Got user id:%@", [user userID]);
        if ([user isKindOfClass:[GOTUser class]]) {
            // Make sure the user is now saved
            NSLog(@"Saving user: %@", user);
            if ([GOTActiveUser isActiveUser:user]) {
                // update the active user
                [[GOTActiveUser activeUser] setUser:user];
            }
            
        }
        [self saveChanges];
        block(user, err);
    }];
    [conn start];
}

- (GOTUser *)createNewUser
{
    return [NSEntityDescription
            insertNewObjectForEntityForName:@"GOTUser"
            inManagedObjectContext:context];
}

- (GOTUser *)createOrFetchUserWithID:(NSNumber *)userID
{
    // If a user exists with this ID in the DB, return that user.
    // Otherwise, create a new DB object for this user.
    NSPredicate *userIDPredicate = [NSPredicate predicateWithFormat:@"userID = %@"
                                                      argumentArray:[NSArray arrayWithObject:userID]];
    GOTUser *user = [self fetchUserFromDBWithPredicate:userIDPredicate];
    if (!user) {
        NSLog(@"Creating a new user in createOrFetchUser with userID: %@", userID);
        user = [self createNewUser];
    }
    return user;
}

#pragma mark -

- (GOTUser *)fetchUserFromDBWithPredicate:(NSPredicate *)userPredicate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GOTUser"];
    [request setPredicate:userPredicate];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Failed to load user from DB: %@", [error localizedDescription]);
    }
    if ([result count] == 0) {
        return nil;
    } else if ([result count] > 1) {
        NSLog(@"Storing more copies of users than we need to");
    }
    return [result objectAtIndex:0];
}

- (void)updateActiveUserKarma:(NSDictionary *)karmaDict
{
    NSNumber *karmaValue = [karmaDict objectForKey:@"updatedKarma"];
    [[GOTActiveUser activeUser] setKarma:[JSONUtil normalizeJSONValue:karmaValue
                                                              toClass:[NSNumber class]]];
    [self saveChanges];
}

- (void)discardChanges
{
    [context rollback];
}

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

#pragma mark Users who want items

- (void)fetchUsersWhoRequestedItemID:(NSNumber *)itemID withCompletion:(void (^)(NSArray *, NSError *))block
{
    NSString *stringURL = [NSString stringWithFormat:@"users.php?wantItemID=%@&minMessages=1", itemID];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringURL
                                                                          relativeToURL:[GOTConstants baseURL]]];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:^(NSDictionary *dict, NSError *err) {
        NSLog(@"Dict of users who want item: %@", dict);
        if (dict) {
            NSArray *usersDictArray = [dict objectForKey:@"users"];
            NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:[usersDictArray count]];
            [usersDictArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger index, BOOL *stop) {
                GOTUser *user = [self createOrFetchUserWithID:[obj objectForKey:@"id"]];
                [user readFromJSONDictionary:obj];
                [users addObject:user];
            }];
            [self saveChanges];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
    [conn start];
}

#pragma mark -

@end
