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

// Register any default values here.  This will give an initial value the
// first time the app starts.
- (void)setupDefaults
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:15]
                                                         forKey:[GOTSettings distanceKey]];
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

- (CFStringRef)activeFacebookUserKey
{
    return (CFStringRef)@"facebookID";
}

- (CFStringRef)applicationID
{
    return kCFPreferencesCurrentApplication;
}

- (void)setActiveFacebookUserID:(NSString *)fbid
{
    CFDataRef data = (__bridge CFDataRef)[fbid dataUsingEncoding:NSUTF8StringEncoding];
    CFPreferencesSetValue([self activeFacebookUserKey],
                          data,
                          [self applicationID],
                          kCFPreferencesCurrentUser,
                          kCFPreferencesCurrentHost);
    CFPreferencesSynchronize([self applicationID], kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
}

- (NSString *)activeFacebookUserID
{
    CFDataRef data = CFPreferencesCopyValue([self activeFacebookUserKey], [self applicationID], kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
    
    if (data) {
        NSString *fbid = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
        NSLog(@"fbid = %@", fbid);
        return fbid;
    } else {
        return nil;
    }
}

@end
