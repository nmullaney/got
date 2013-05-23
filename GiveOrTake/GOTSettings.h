//
//  GOTSettings.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTSettings : NSObject

+ (GOTSettings *)instance;

+ (void)synchronize;

// Keys for different values
+ (NSString *)distanceKey;
+ (NSString *)showMyItemsKey;

- (void)setupDefaults;

- (int)getIntValueForKey:(NSString *)s;
- (void)setIntValue:(int)v forKey:(NSString*)s;

- (BOOL)getBoolValueForKey:(NSString *)s;
- (void)setBoolValue:(BOOL)v forKey:(NSString *)s;

@end
