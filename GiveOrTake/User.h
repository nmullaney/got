//
//  User.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/3/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSONSerializable.h"

@protocol User <NSObject, JSONSerializable>

- (NSNumber *)userID;
- (void)setUserID:(NSNumber *)userID;
- (NSString *)username;
- (void)setUsername:(NSString *)username;
- (NSNumber *)latitude;
- (void)setLatitude:(NSNumber *)latitude;
- (NSNumber *)longitude;
- (void)setLongitude:(NSNumber *)longitude;
- (NSNumber *)karma;
- (void)setKarma:(NSNumber *)karma;


@end
