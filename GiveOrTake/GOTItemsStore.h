//
//  GOTItemsStore.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GOTItemsStore : NSObject

+ (GOTItemsStore *)sharedStore;

- (NSArray *)itemsAtDistance:(int) distance;

@end
