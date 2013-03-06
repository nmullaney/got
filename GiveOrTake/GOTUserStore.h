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
- (void)createActiveUserFromFBUser:(id<FBGraphUser>)user withCompletion:(void (^)(id user, NSError *err))block;
- (GOTUser *)fetchUserWithUserID:(NSNumber *)userID
                  withFacebookID:(NSString *)facebookID
                  withCompletion:(void (^)(id user, NSError *err))block;
- (void)loadActiveUser;
- (BOOL)saveChanges;

@property (nonatomic, strong) GOTUser *activeUser;

@end
