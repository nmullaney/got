//
//  GOTItemsStore.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/13/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class GOTItemList;

@interface GOTItemsStore : NSObject
{
    NSURLConnection *connection;
}
+ (GOTItemsStore *)sharedStore;

- (GOTItemList *)fetchItemsAtDistance:(int)distance withCompletion:(void (^)(GOTItemList *list, NSError *err))block;

@end
