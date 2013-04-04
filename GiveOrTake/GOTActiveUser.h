//
//  GOTActiveUser.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/2/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerializable.h"
#import "User.h"

@class GOTUser;

@interface GOTActiveUser : NSObject <User, NSCoding, JSONSerializable>

+ (GOTActiveUser *)activeUser;
+ (void)logout;
+ (BOOL)isActiveUser:(GOTUser *)user;

+ (NSString *)archivePath;
+ (BOOL)save;

@property (nonatomic, retain) GOTUser *user;
@property (nonatomic, copy) NSString *facebookID;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *pendingEmail;

@end
