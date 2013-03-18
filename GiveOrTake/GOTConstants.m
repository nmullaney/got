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
    //return [NSURL URLWithString:@"http://ec2-107-21-148-60.compute-1.amazonaws.com"];
    return [NSURL URLWithString:@"http://nmullaney.dev"];
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
