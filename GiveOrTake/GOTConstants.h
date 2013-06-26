//
//  GOTConstants.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/7/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTConstants : NSObject

+ (NSURL *)baseURL;
+ (NSURL *)baseWebURL;
+ (NSArray *)trustedHosts;

+ (NSInteger)itemRequestLimit;

+ (UIFont *)defaultSmallFont;
+ (UIFont *)defaultMediumFont;
+ (UIFont *)defaultLargeFont;
+ (UIFont *)defaultVeryLargeFont;
+ (UIFont *)defaultBoldMediumFont;
+ (UIFont *)defaultBoldLargeFont;
+ (UIFont *)defaultBoldVeryLargeFont;
+ (UIFont *)defaultBold16Font;
+ (UIFont *)defaultBold18Font;
+ (UIFont *)defaultBold0Font;
+ (UIFont *)barButtonItemFont;

+ (NSDictionary *)navDefaultTitleAttributes;
+ (NSDictionary *)freeItemTitleAttributes;

+ (UIColor *)defaultBackgroundColor;
+ (UIColor *)colorBackground;
+ (UIColor *)defaultGrayTextColor;

+ (UIColor *)defaultNavBarColor;
+ (UIColor *)navTextColor;
+ (UIColor *)navTextShadowColor;
+ (UIColor *)navButtonTextColor;
+ (UIColor *)actionButtonColor;
+ (UIColor *)iconLightGreen;
+ (UIColor *)iconMediumGreen;
+ (UIColor *)iconDarkGreen;
+ (UIColor *)iconLightPink;
+ (UIColor *)iconMediumPink;
+ (UIColor *)iconDarkPink;
+ (UIColor *)defaultDarkBlueColor;

+ (UIColor *)colorWith255Red:(float)red  with255Green:(float)green with255Blue:(float)blue;

+ (NSString *)admobPublisherID;

@end
