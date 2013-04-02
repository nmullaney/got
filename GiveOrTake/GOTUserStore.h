//
//  GOTUserStore.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/4/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class GOTUser;

@interface GOTUserStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (GOTUserStore *)sharedStore;

- (NSString *)sqlStorePath;
- (void)createActiveUserFromFBUser:(id<FBGraphUser>)user
                        withParams:(NSMutableDictionary *)params
                    withCompletion:(void (^)(id user, NSError *err))block;
- (GOTUser *)fetchUserWithFacebookID:(NSString *)facebookID
                  withCompletion:(void (^)(id user, NSError *err))block;
- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID
                  withCompletion:(void (^)(id user, NSError *err))block;
- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID
                 withExtraFields:(NSArray *)extraFields
                  withCompletion:(void (^)(id user, NSError *err))block;
- (void)updateUser:(GOTUser *)user
        withParams:(NSMutableDictionary *)params
    withCompletion:(void (^)(id user, NSError *err))block;
- (void)addPendingEmail:(NSString *)email withCompletion:(void (^)(id result, NSError *err))block;
- (void)verifyPendingEmailCode:(NSString *)code withCompletion:(void (^)(id result, NSError *err))block;
- (void)loadActiveUserWithCompletion:(void (^)(id user, NSError *err))block;

- (NSNumber *)activeUserID;
- (NSString *)activeUserToken;

- (void)discardChanges;
- (BOOL)saveChanges;

@property (nonatomic, strong) GOTUser *activeUser;

@end
