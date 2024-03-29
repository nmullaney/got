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
@class GOTActiveUser;

@interface GOTUserStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (GOTUserStore *)sharedStore;

- (NSString *)sqlStorePath;
- (GOTUser *)createNewUser;
- (GOTUser *)createOrFetchUserWithID:(NSNumber *)userID;
- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID
                  withCompletion:(void (^)(id user, NSError *err))block;
- (GOTUser *)fetchLocalUserWithUserID:(NSNumber *)userID;
- (void)fetchActiveUserWithExtraFields:(NSArray *)extraFields
                                   withCompletion:(void (^)(GOTActiveUser *, NSError *err))block;
- (GOTUser *)fetchUserFromDBWithPredicate:(NSPredicate *)userPredicate;
- (void)updateUserWithParams:(NSDictionary *)params
    withCompletion:(void (^)(id user, NSError *err))block;
- (void)addPendingEmail:(NSString *)email withCompletion:(void (^)(id result, NSError *err))block;
- (void)removePendingEmailWithCompletion:(void (^)(id result, NSError *err))block;
- (void)verifyPendingEmailCode:(NSString *)code withCompletion:(void (^)(id result, NSError *err))block;

- (void)fetchUsersWhoRequestedItemID:(NSNumber *)itemID
                 withCompletion:(void (^)(NSArray *users, NSError *err))block;

- (void)updateActiveUserKarma:(NSDictionary *)karmaDict;

- (void)discardChanges;
- (BOOL)saveChanges;

@end
