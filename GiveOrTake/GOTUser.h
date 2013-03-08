//
//  GOTUser.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/4/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "JSONSerializable.h"


@interface GOTUser : NSManagedObject <JSONSerializable>

@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

- (NSDictionary *)uploadDictionary;

@end
