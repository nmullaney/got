//
//  GOTImageStore.h
//  GiveOrTake
//
//  Created by Nora Mullaney on 2/22/13.
//  Copyright (c) 2013 Nora Mullaney. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GOTItem;

@interface GOTImageStore : NSObject
{
    NSMutableDictionary *imageCache;
}

+ (GOTImageStore *)sharedStore;
+ (NSString *)createImageKey;

- (void)setImage:(UIImage *)i forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;
- (void)clearCache:(NSNotification *)note;

- (void)uploadImageForKey:(NSString *)s withItemID:(NSNumber *)itemID;
- (void)fetchImageForItem:(GOTItem *)item withCompletion:(void (^)(id image, NSError *err))block;

@end
