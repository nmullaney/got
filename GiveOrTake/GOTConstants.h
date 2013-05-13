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
+ (NSArray *)trustedHosts;

+ (NSInteger)itemRequestLimit;

+ (UIFont *)defaultSmallFont;
+ (UIFont *)defaultMediumFont;
+ (UIFont *)defaultLargeFont;
+ (UIFont *)defaultVeryLargeFont;
+ (UIFont *)defaultBoldVeryLargeFont;

+ (UIColor *)defaultBackgroundColor;
+ (UIColor *)greenBackgroundColor;
+ (UIColor *)defaultGrayTextColor;

@end
