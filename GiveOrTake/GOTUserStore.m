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

- (NSString *)sqlStorePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    // There is only one document directory
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"GOTData.sql3"];
    // TODO remove this
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    return path;
}

- (void)createActiveUserFromFBUser:(id<FBGraphUser>)user
{
    
    GOTUser *newUser = [NSEntityDescription
                        insertNewObjectForEntityForName:@"GOTUser"
                        inManagedObjectContext:context];
    
    [newUser setFacebookID:[user objectForKey:@"id"]];
    [newUser setEmailAddress:[user objectForKey:@"email"]];
    [newUser setUsername:[user objectForKey:@"username"]];
    
    [self registerOrLoginUser:newUser];
}

- (void)registerOrLoginUser:(GOTUser *)user
{
    NSURL *url = [NSURL URLWithString:@"http://nmullaney.dev/api/user.php"];
    GOTMutableURLPostRequest *req = [[GOTMutableURLPostRequest alloc] initWithURL:url
                                                                         formData:[user uploadDictionary]
                                                                        imageData:nil];
    GOTConnection *conn = [[GOTConnection alloc] initWithRequest:req];
    [conn setJsonRootObject:user];
    [conn setCompletionBlock:^(id updatedUser, NSError *error) {
        if (error) {
            NSLog(@"Error logging in: %@", [error localizedDescription]);
        } else {
            NSLog(@"block user: %@", updatedUser);
            GOTUser *user = updatedUser;
            [self saveChanges];        
            [self setActiveUser:user];
        }
    }];
    [conn start];
}
                          
- (void)fetchActiveUserFromFB
{
    if (!FBSession.activeSession.isOpen) {
        NSLog(@"Error: cannot fetch user while no active session");
        return;
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                                           id<FBGraphUser> user,
                                                           NSError *error) {
        if (error) {
            NSLog(@"Error: failed to get facebook user: %@", [error localizedDescription]);
        }
        [self createActiveUserFromFBUser:user];
    }];
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
