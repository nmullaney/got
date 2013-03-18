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

@end
