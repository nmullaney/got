//
//  JSONUtil.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 4/3/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "JSONUtil.h"

@implementation JSONUtil

+ (id)normalizeJSONValue:(id)value toClass:(Class)class
{
    // if the value is NULL, we should always return nil
    if ([value isEqual:[NSNull null]]) {
        return nil;
    }
    if ([NSNumber class] == class) {
        return [NSNumber numberWithFloat:[value floatValue]];
    }
    if ([NSString class] == class) {
        return value;
    }
    return nil;
}

@end
