//
//  GOTItemState.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 3/27/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOTItemState : NSString

+ (GOTItemState *)DRAFT;
+ (GOTItemState *)AVAILABLE;
+ (GOTItemState *)PENDING;
+ (GOTItemState *)TAKEN;
+ (GOTItemState *)DELETED;

+ (NSArray *)values;
+ (NSUInteger)count;
+ (NSArray *)pickableValues;
+ (NSUInteger)pickableCount;
+ (GOTItemState *)getValue:(NSString *)str;
+ (UIImage *)imageForState:(GOTItemState *)state;

@end
