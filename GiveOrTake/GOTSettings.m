//
//  GOTSettings.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/20/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTSettings.h"

@implementation GOTSettings

+ (GOTSettings *)instance
{
    static GOTSettings *instance;
    if (!instance) {
        instance = [[GOTSettings alloc] init];
    }
    return instance;
}

+ (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)distanceKey
{
    return @"defaultDistance";
}

+ (NSString *)showMyItemsKey
{
    return @"showMyItems";
}

// Register any default values here.  This will give an initial value the
// first time the app starts.
- (void)setupDefaults
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:15], [GOTSettings distanceKey],
                              [NSNumber numberWithBool:YES], [GOTSettings showMyItemsKey],
                              nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (int)getIntValueForKey:(NSString *)s
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:s];
}

- (void)setIntValue:(int)v forKey:(NSString *)s
{
    [[NSUserDefaults standardUserDefaults] setInteger:v
                                               forKey:s];
}

- (BOOL)getBoolValueForKey:(NSString *)s
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:s];
}

- (void)setBoolValue:(BOOL)v forKey:(NSString *)s
{
    [[NSUserDefaults standardUserDefaults] setBool:v forKey:s];
}

@end
