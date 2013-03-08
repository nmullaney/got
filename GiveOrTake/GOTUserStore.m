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
            [NSException raise:@"Open database failed"
                        format:@"Reason: %@", err];
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        [context setUndoManager:nil];
        
    }
    return self;
}

- (void)setActiveUser:(GOTUser *)user
{
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

// If the user exists locally, we only need to set that user as active
// If the user is not in local storage, they may be a brand new user,
// so we should push up their data to the web
- (void)createActiveUserFromFBUser:(id<FBGraphUser>)user withCompletion:(void (^)(id, NSError *))block
{
    NSPredicate *userPredicate =
        [NSPredicate predicateWithFormat:@"facebookID = %@"
                           argumentArray:[NSArray arrayWithObject:[user objectForKey:@"id"]]];
    GOTUser *localUser = [self fetchUserFromDBWithPredicate:userPredicate];
    if (localUser) {
        NSLog(@"Found active user locally after login");
        [self setActiveUser:localUser];
        block(localUser, nil);
        return;
    }
    
    // If we did not find a user, we'll need to create a new one
    GOTUser *newUser = [NSEntityDescription
                        insertNewObjectForEntityForName:@"GOTUser"
                        inManagedObjectContext:context];
    
    [newUser setFacebookID:[user objectForKey:@"id"]];
    [newUser setEmailAddress:[user objectForKey:@"email"]];
    [newUser setUsername:[user objectForKey:@"username"]];
    
    [self updateUser:newUser withCompletion:^(id user, NSError *err) {
        if (!err) {
            [self setActiveUser:user];
        }
        if (block) {
            block(user, err);
        }
    }];
}

- (void)updateUser:(GOTUser *)user withCompletion:(void (^)(id, NSError *))block
{
    // We can only update the logged in user, so if we have an active user
    // make sure it matches (if not, this is likely the login step).
    if ([self activeUser] && ![[self activeUser] isEqual:user]) {
        [NSException raise:@"Failed to update user" format:@"Only the current user can be updated"];
    }
    
    NSURL *url = [NSURL URLWithString:@"/api/user.php" relativeToURL:[GOTConstants baseURL]];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:[user uploadDictionary]
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setJsonRootObject:user];
    [conn setCompletionBlock:^(id updatedUser, NSError *error) {
        if (error) {
            NSLog(@"Error updating user: %@", [error localizedDescription]);
        } else {
            NSLog(@"block user: %@", updatedUser);
            [self saveChanges];
        }
        if (block) {
            block(updatedUser, error);
        }
        
    }];
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
    
    [self fetchUserWithUserID:nil withFacebookID:fbid withCompletion:^(id user, NSError *err) {
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

/**
 * Try to load the user from local storage.  If not found,
 * hit the web.  Local storage will return a user immediately.
 * If it hits the web, nil will be returned for the user.
 * Either userID or facebookID must be specified.
 */
- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID
                  withFacebookID:(NSString *)facebookID
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
    
    GOTUser *user = nil;
    //GOTUser *user = [self fetchUserFromDBWithPredicate:userPredicate];
    if (user) {
        NSLog(@"Fetched user from local storage");
        if (block) {
            block(user, nil);
        }
        return user;
    }
    
    // If no user is found, we'll need to hit the web
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (userID) {
        [params setObject:userID forKey:@"id"];
    }
    if (facebookID) {
        [params setObject:facebookID forKey:@"facebook_id"];
    }
    NSLog(@"Fetching user from the web");
    [self fetchUserFromWebWithParams:params withCompletion:block];
    
    return nil;
}

- (void)fetchUserFromWebWithParams:(NSDictionary *)params withCompletion:(void (^)(id user, NSError *err))block
{
    NSMutableString *stringURL = [NSMutableString stringWithString:@"/api/user.php?"];
    NSMutableArray *paramStrs = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^void(id key, id obj, BOOL *stop) {
        [paramStrs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    [stringURL appendString:[paramStrs componentsJoinedByString:@"%"]];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL
                                                            relativeToURL:[GOTConstants baseURL]]];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    
    GOTUser *newUser = [NSEntityDescription
                        insertNewObjectForEntityForName:@"GOTUser"
                        inManagedObjectContext:context];
    [conn setJsonRootObject:newUser];
    [conn setCompletionBlock:^(id user, NSError *err) {
        NSLog(@"Got user with username:%@, id:%@", [(GOTUser *)user username], [(GOTUser *)user userID]);
        if (user) {
            // Make sure the user is now saved
            [self saveChanges];
        }
        block(user, err);
    }];
    [conn start];
}

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
