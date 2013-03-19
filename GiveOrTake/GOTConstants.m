//
//  GOTConstants.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTConstants.h"

@implementation GOTConstants

+ (NSURL *)baseURL
{
    //return [NSURL URLWithString:@"https:/www.giveortakeapp.com"];
    return [NSURL URLWithString:@"https://nmullaney.dev"];
}

+ (NSArray *)trustedHosts
{
    return [NSArray arrayWithObjects:
            @"localhost",
            @"www.giveortakeapp.com",
            @"ec2-107-21-148-60.compute-1.amazonaws.com",
            @"nmullaney.dev",
            nil];
}

// This is the limit of how many items we request from the web
// on a single call
+ (int)itemRequestLimit
{
    return 15;
}

+ (UIFont *)defaultSmallFont
{
    return [UIFont systemFontOfSize:13.0];
}

+ (UIFont *)defaultMediumFont
{
    return [UIFont systemFontOfSize:15.0];
}

+ (UIFont *)defaultLargeFont
{
    return [UIFont systemFontOfSize:17.0];
}

+ (UIFont *)defaultVeryLargeFont
{
    return [UIFont systemFontOfSize:19.0];
}

// This returns a light gray, partially translucent color
+ (UIColor *)defaultBackgroundColor
{
    return [UIColor colorWithWhite:0.5 alpha:0.25];
}

@end
