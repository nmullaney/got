//
//  GOTItemID.m
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/27/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import "GOTItemID.h"

@implementation GOTItemID

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    [self setItemID:[d valueForKey:@"id"]];
}

@end
