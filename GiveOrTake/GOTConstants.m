//
//  GOTConstants.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTConstants.h"

@implementation GOTConstants

#pragma mark network constants

+ (NSURL *)baseURL
{
    return [NSURL URLWithString:@"https://api.giveortakeapp.com"];
    //return [NSURL URLWithString:@"https://nmullaney.dev"];
}

+ (NSURL *)baseWebURL
{
    return [NSURL URLWithString:@"http://www.giveortakeapp.com"];
}

+ (NSArray *)trustedHosts
{
    return [NSArray arrayWithObjects:
            @"localhost",
            @"api.giveortakeapp.com",
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

#pragma mark -
#pragma mark fonts

+ (NSString *)defaultFontName
{
    return @"HelveticaNeue-Light";
}

+ (NSString *)defaultBoldFontName
{
    return @"HelveticaNeue-Bold";
}

+ (UIFont *)defaultSmallFont
{
    return [UIFont fontWithName:[self defaultFontName] size:13.0];
}

+ (UIFont *)defaultMediumFont
{
    return [UIFont fontWithName:[self defaultFontName] size:15.0];
}

+ (UIFont *)defaultLargeFont
{
    return [UIFont fontWithName:[self defaultFontName] size:17.0];
}

+ (UIFont *)defaultVeryLargeFont
{
    return [UIFont fontWithName:[self defaultFontName] size:19.0];
}

+ (UIFont *)defaultBoldMediumFont
{
    return [UIFont fontWithName:[self defaultBoldFontName] size:15.0];
}

+ (UIFont *)defaultBoldLargeFont
{
    return [UIFont fontWithName:[self defaultBoldFontName] size:17.0];
}

+ (UIFont *)defaultBoldVeryLargeFont
{
    return [UIFont fontWithName:[self defaultBoldFontName] size:19.0];
}

+ (UIFont *)defaultBold16Font {
    return [UIFont fontWithName:[self defaultBoldFontName] size:16.0];
}

+ (UIFont *)defaultBold18Font {
    return [UIFont fontWithName:[self defaultBoldFontName] size:18.0];
}

+ (UIFont *)defaultBold0Font {
    return [UIFont fontWithName:[self defaultBoldFontName] size:0.0];
}

+ (UIFont *)barButtonItemFont {
    return [UIFont fontWithName:[self defaultBoldFontName] size:15.0];
}

#pragma mark -
#pragma mark title text attributes

+ (NSDictionary *)navDefaultTitleAttributes
{
    return @{UITextAttributeFont: [GOTConstants defaultVeryLargeFont],
             UITextAttributeTextColor: [GOTConstants navTextColor],
             UITextAttributeTextShadowOffset: @0};
}

+ (NSDictionary *)freeItemTitleAttributes
{
    return @{UITextAttributeFont: [GOTConstants defaultLargeFont],
             UITextAttributeTextColor: [GOTConstants navTextColor],
             UITextAttributeTextShadowOffset: @0};
}

#pragma mark -
#pragma mark colors

// This returns a light gray, partially translucent color
+ (UIColor *)defaultBackgroundColor
{
    return [UIColor colorWithWhite:0.5 alpha:0.25];
}

// This returns a non-gray color
+ (UIColor *)colorBackground
{
    return [GOTConstants colorWith255Red:170 with255Green:212 with255Blue:191];
}

// This is the steel crayon color
+ (UIColor *)defaultGrayTextColor
{
    return [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
}

#pragma mark -
#pragma mark navigation header constants

// This is the blue for the fb share
+ (UIColor *)defaultDarkBlueColor
{
    return [UIColor colorWithRed:0.29 green:0.396 blue:0.616 alpha:1.0];
}

+ (UIColor *)defaultNavBarColor
{
    return [GOTConstants blueishGreen];
}

+ (UIColor *)navTextColor
{
    return [UIColor blackColor];
}

+ (UIColor *)navTextShadowColor
{
    return [UIColor clearColor];
}

+ (UIColor *)navButtonTextColor
{
    return [GOTConstants colorWith255Red:71 with255Green:151 with255Blue:249];
}

+ (UIColor *)actionButtonColor
{
    return [GOTConstants iconDarkPink];
}

+ (UIColor *)blueishGreen
{
    return [GOTConstants colorWith255Red:129 with255Green:219 with255Blue:171];
}

+ (UIColor *)iconLightGreen
{
    return [GOTConstants colorWith255Red:107 with255Green:218 with255Blue:113];
}

+ (UIColor *)iconMediumGreen
{
    return [GOTConstants colorWith255Red:21.0f with255Green:151.0f with255Blue:43.0f];
}

+ (UIColor *)iconDarkGreen
{
    return [GOTConstants colorWith255Red:51.0f with255Green:96.0f with255Blue:55.0f];
}

+ (UIColor *)iconLightPink;
{
    return [GOTConstants colorWith255Red:238 with255Green:164 with255Blue:201];
}

+ (UIColor *)iconMediumPink
{
    return [GOTConstants colorWith255Red:231 with255Green:128 with255Blue:184];
}

+ (UIColor *)iconDarkPink
{
    return [GOTConstants colorWith255Red:182 with255Green:39 with255Blue:157];
}

+ (UIColor *)colorWith255Red:(float)red  with255Green:(float)green with255Blue:(float)blue
{
    float normRed = red / 255.0f;
    float normGreen = green / 255.0f;
    float normBlue = blue / 255.0f;
    return [UIColor colorWithRed:normRed green:normGreen blue:normBlue alpha:1.0];
}

#pragma mark -
#pragma mark ad constants

+ (NSString *)admobPublisherID
{
    return @"a1519a5dc401ede";
}

#pragma mark -

@end
