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
#import "GOTMutableURLPostRequest.h"
#import "GOTConnection.h"
#import "GOTSettings.h"
#import "GOTConstants.h"

@implementation GOTUserStore

@synthesize activeUser;

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
        
        [context setUndoManager:nil];
        
    }
    return self;
}

- (void)setActiveUser:(GOTUser *)user
{
    NSString *currentToken = [self activeUserToken];
    if (![user token] && [[self activeUserID] integerValue] == [[user userID] integerValue]) {
        [user setToken:currentToken];
    }
    activeUser = user;
    [[GOTSettings instance] setActiveFacebookUserID:[user facebookID]];
}

- (NSNumber *)activeUserID
{
    if ([self activeUser]) {
        return [[self activeUser] userID];
    } else {
        return nil;
    }
}

- (NSString *)activeUserToken
{
    if ([self activeUser]) {
        return [[self activeUser] token];
    } else {
        return nil;
    }
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
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr fileExistsAtPath:path]) {
        [fileMgr removeItemAtPath:path error:nil];
    }
    return path;
}

// If the user exists locally, we only need to set that user as active
// If the user is not in local storage, they may be a brand new user,
// so we should push up their data to the web
- (void)createActiveUserFromFBUser:(id<FBGraphUser>)user
                        withParams:(NSMutableDictionary *)params
                    withCompletion:(void (^)(id, NSError *))block
{
    NSPredicate *userPredicate =
        [NSPredicate predicateWithFormat:@"facebookID = %@"
                           argumentArray:[NSArray arrayWithObject:[user objectForKey:@"id"]]];
    
    GOTUser *newUser = [self fetchUserFromDBWithPredicate:userPredicate];
    if (!newUser) {
        // If we did not find a user, we'll need to create a new one
        newUser = [NSEntityDescription
                            insertNewObjectForEntityForName:@"GOTUser"
                            inManagedObjectContext:context];
    }
    
    [newUser setFacebookID:[user objectForKey:@"id"]];
    [newUser setEmailAddress:[user objectForKey:@"email"]];
    [newUser setUsername:[user objectForKey:@"username"]];
    
    [self updateUser:newUser withParams:params withCompletion:^(id user, NSError *err) {
        if (!err) {
            [self setActiveUser:user];
        } else {
            NSLog(@"Got error while trying to create new user: %@", [err localizedDescription]);
        }
        if (block) {
            block(user, err);
        }
    }];
}

- (void)updateUser:(GOTUser *)user
        withParams:(NSMutableDictionary *)params
    withCompletion:(void (^)(id, NSError *))block
{
    // We can only update the logged in user, so if we have an active user
    // make sure it matches (if not, this is likely the login step).
    if ([self activeUser] && ![[self activeUser] isEqual:user]) {
        [NSException raise:@"Failed to update user" format:@"Only the current user can be updated"];
        return;
    }
    
    if (!params) {
        params = [NSMutableDictionary dictionaryWithDictionary:[user uploadDictionary]];
    } else {
        [params addEntriesFromDictionary:[user uploadDictionary]];
    }
    NSLog(@"Updating user with values: %@", params);
    
    NSURL *url = [NSURL URLWithString:@"/api/user.php" relativeToURL:[GOTConstants baseURL]];
    NSLog(@"Updating user at: %@", url);
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:params
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setJsonRootObject:user];
    [conn setCompletionBlock:^(id updatedUser, NSError *error) {
        GOTUser *user = updatedUser;
        if (error) {
            NSLog(@"Error updating user: %@", [error localizedDescription]);
        } else if([[user userID] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            NSLog(@"Error: server did not return a valid user");
            NSDictionary *info = [NSDictionary dictionaryWithObject:@"Invalid user returned from server"
                                                            forKey:NSLocalizedDescriptionKey];
            NSError *err = [NSError errorWithDomain:NSURLErrorDomain
                                      code:NSURLErrorBadServerResponse
                                  userInfo:info];
            block(nil, err);
            return;
        } else {
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
    GOTUser *user = [self activeUser];
    NSArray *keys = [NSArray arrayWithObjects:@"id", @"email", nil];
    NSArray *values = [NSArray arrayWithObjects:[user userID], email, nil];
    NSMutableDictionary *formData = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    NSURL *url = [NSURL URLWithString:@"/api/user/email.php" relativeToURL:[GOTConstants baseURL]];
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
    GOTUser *user = [self activeUser];
    NSArray *keys = [NSArray arrayWithObjects:@"id", @"code", nil];
    NSArray *values = [NSArray arrayWithObjects:[user userID], code, nil];
    NSMutableDictionary *formData = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
    NSURL *url = [NSURL URLWithString:@"/api/user/email.php" relativeToURL:[GOTConstants baseURL]];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:formData
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setDataType:JSON];
    [conn setCompletionBlock:block];
    [conn start];
}

// Load the active user from the local storage or the web
- (void)loadActiveUserWithCompletion:(void (^)(id, NSError *))block
{
     NSString *fbid = [[GOTSettings instance] activeFacebookUserID];
    if (!fbid) {
        NSLog(@"Cannot load active user: no active facebookID");
        // TODO this should call block with error
    }
    
    [self fetchUserWithFacebookID:fbid withCompletion:^(id user, NSError *err) {
        if (err) {
            NSLog(@"Error fetching  user to set as active: %@", [err localizedDescription]);
        }
        if (user) {
            [self setActiveUser:user];
        }
        if (block) {
            block(user, err);
        }
    }];
}

#pragma mark public user fetch functions

/**
 * Try to load the user from local storage.  If not found,
 * hit the web.  Local storage will return a user immediately.
 * If it hits the web, nil will be returned for the user.
 * Either userID or facebookID must be specified.
 */
- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID
                  withFacebookID:(NSString *)facebookID
                 withExtraFields:(NSArray *)extraFields
                  withCompletion:(void (^)(id, NSError *))block
{
    NSPredicate *userPredicate = nil;
    if (userID) {
        userPredicate = [NSPredicate predicateWithFormat:@"userID = %@"
                                           argumentArray:[NSArray arrayWithObject:userID]];
    } else if (facebookID) {
        userPredicate = [NSPredicate predicateWithFormat:@"facebookID = %@" argumentArray:[NSArray arrayWithObject:facebookID]];
    } else {
        NSException *exception = [NSException exceptionWithName:@"Cannot fetch user"
                                                         reason:@"No userID or facebookID specified"
                                                       userInfo:nil];
        [exception raise];
    }
    
    if (!extraFields) {
        GOTUser *user = [self fetchUserFromDBWithPredicate:userPredicate];
        if (user) {
            NSLog(@"Fetched user from local storage");
            if (block) {
                block(user, nil);
            }
            return user;
        }
    }
    
    // If no user is found, we'll need to hit the web
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userID) {
        [params setObject:userID forKey:@"id"];
    }
    if (facebookID) {
        [params setObject:facebookID forKey:@"facebook_id"];
    }
    if (extraFields) {
        [params setObject:extraFields forKey:@"extra"];
    }
    NSLog(@"Fetching user from the web");
    [self fetchUserFromWebWithParams:params withCompletion:block];
    
    return nil;
}

// The following methods are wrappers around the one above

- (GOTUser *)fetchUserWithFacebookID:(NSString *)facebookID withCompletion:(void (^)(id, NSError *))block
{
    return [self fetchUserWithUserID:nil withFacebookID:facebookID withExtraFields:nil withCompletion:block];
}

- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID withCompletion:(void (^)(id, NSError *))block
{
    return [self fetchUserWithUserID:userID withFacebookID:nil withExtraFields:nil withCompletion:block];
}

- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID withExtraFields:(NSArray *)extraFields withCompletion:(void (^)(id, NSError *))block
{
    return [self fetchUserWithUserID:userID withFacebookID:nil withExtraFields:extraFields withCompletion:block];
}

- (void)fetchUserFromWebWithParams:(NSDictionary *)params withCompletion:(void (^)(id user, NSError *err))block
{
    NSMutableString *stringURL = [NSMutableString stringWithString:@"/api/user.php?"];
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
    
    GOTUser *newUser = [NSEntityDescription
                        insertNewObjectForEntityForName:@"GOTUser"
                        inManagedObjectContext:context];
    [conn setJsonRootObject:newUser];
    [conn setCompletionBlock:^(id user, NSError *err) {
        NSLog(@"Got user with username:%@, id:%@, pending_email:%@", [(GOTUser *)user username], [(GOTUser *)user userID], [(GOTUser *)user pendingEmail]);
        if (user) {
            // Make sure the user is now saved
            NSLog(@"Saving user: %@", user);
            if ([[user userID] intValue] == [[self activeUserID] intValue]) {
                // update the active user
                [self setActiveUser:user];
            }
            [self saveChanges];
        }
        block(user, err);
    }];
    [conn start];
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

@end
